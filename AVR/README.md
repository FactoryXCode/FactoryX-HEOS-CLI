# FactoryX AVR control API

`Avr.Client.pas` and `Avr.Commands.pas` provide the Denon/Marantz AVR text control protocol over TCP port 23, alongside the separate HEOS CLI on port 1255.
The socket transport is shared with the HEOS library (`Source/Heos.Sockets.pas`).
**Note**
This API covers the receiver controls used by the HEOS Remote application. It is not a claim to implement every command supported by every AVR.
Unknown response lines are preserved, and a raw command builder supports model-specific extensions.
Commands, inputs, tone and surround features depend on the product, firmware and current operating mode.

## Files

| File | Purpose |
|---|---|
| `Source/Avr.Commands.pas` | Typed command builders, validation and typed reply parser |
| `Source/Avr.Client.pas` | Persistent asynchronous connection, serialized request queue and event delivery |
| `Samples/AvrCliDemo.dpr` | Read-only console example using the new AVR API |
| `Samples/HEOSRemote/HEOSRemote.dproj` | Complete original HEOS Remote VCL application, controls and forms |
| `Tests/AvrApiTests.dpr` | Validation and simulator checks |
| `Tests/RunAvrSimulator.py` | Local TCP simulator using Python's standard library |

Add the repository's `Source` and `AVR/Source` directories to your Delphi unit search path.
The projects use relative paths.
  
The full application sample requires MfPack separately; see [its build instructions](Samples/HEOSRemote/README.md).
That app preserves its original transport adapters and layouts; it has not been migrated to the new API.

## Basic use

```pascal
uses Avr.Client, Avr.Commands;

FAvr := TAvrClient.Create('192.168.1.100');
FAvr.OnReply := AvrReply;
FAvr.OnEvent := AvrEvent;
FAvr.OnError := AvrError;
FAvr.Enqueue(TAvrCommands.GetMainZonePower());
FAvr.Enqueue(TAvrCommands.GetVolume());
```

Create the client from your form's `OnCreate` or a Connect button.
Creating it alone sends no commands and never activates a zone. `Connect()` queues the read-only power query `PW?`.
`Enqueue` connects as needed and returns a request ID immediately.

Use a standard, IDE-designed VCL timer to dispatch notifications:

```pascal
procedure TMyForm.ApiTimerTimer(Sender: TObject);
begin

  FAvr.Dispatch();
end;


procedure TMyForm.AvrReply(Sender: TObject;
                             AMessage: TAvrMessage);
begin

  case AMessage.Value.Kind of
    avMainZonePower: chkMainZone.Checked := AMessage.Value.Enabled;
    avZone2Power: chkZone2.Checked := AMessage.Value.Enabled;
    avVolume: lblVolume.Caption := FloatToStr(AMessage.Value.Number);
    avBass: lblBass.Caption := FloatToStr(AMessage.Value.Number) + ' dB';
  end;
end;
```

`OnReply` receives confirmed request completions. `OnEvent` receives each incoming line, including typed updates and unknown model-specific text.
`OnError` reports connection failures, command rejection, cancellation and unconfirmed commands.
`OnConnection` carries `Connected`.
All callbacks run on the thread calling `Dispatch`; there are no worker-thread VCL callbacks.

Alternatively, poll `TakeMessage` and free each returned message in `finally`.
Callback messages are owned by the client and freed after the callback.
Copy data that must outlive the callback.
Never free the client from inside a callback; disable your dispatch timer and free it after `Dispatch` returns.

## Typed commands

| Builders | Protocol |
|---|---|
| `GetPower`, `SetPower` | `PW?`, `PWON`, `PWSTANDBY` |
| `GetMainZonePower`, `SetMainZonePower` | `ZM?`, `ZMON`, `ZMOFF` |
| `GetZone2Power`, `SetZone2Power` | `Z2?`, `Z2ON`, `Z2OFF` |
| `GetVolume`, `SetVolume`, `ChangeVolume` | `MV` or Zone 2 `Z2` |
| `GetMute`, `SetMute` | `MU` or `Z2MU` |
| `GetInput`, `SetInput` | `SI` or Zone 2 `Z2` |
| `GetFrontLeft`, `GetFrontRight` | `CV?`, filtered by channel |
| `SetFrontLeft`, `SetFrontRight`, `SetBalance` | `CVFL`, `CVFR` |
| `GetToneControl`, `SetToneControl` | `PSTONE CTRL` |
| `GetBass`, `SetBass` | `PSBAS` |
| `GetTreble`, `SetTreble` | `PSTRE` |
| `GetSurroundMode`, `SetSurroundMode` | `MS` |
| `GetDynamicEq`, `SetDynamicEq` | `PSDYNEQ` |

Commands with an optional `AZone2` argument target Main Zone by default. Pass `True` for Zone 2. Input and surround strings are native protocol tokens, such as `NET`, `TV`, `DVD`, `STEREO` or `DIRECT`, rather than display names from the receiver's web interface.

```pascal
FAvr.Enqueue(TAvrCommands.SetMainZonePower(True));
FAvr.Enqueue(TAvrCommands.SetVolume(47.5));
FAvr.Enqueue(TAvrCommands.SetMute(False));
FAvr.Enqueue(TAvrCommands.SetInput('NET'));
FAvr.Enqueue(TAvrCommands.SetZone2Power(True));
FAvr.Enqueue(TAvrCommands.SetVolume(30, True));
FAvr.Enqueue(TAvrCommands.SetToneControl(True));
FAvr.Enqueue(TAvrCommands.SetBass(2));
FAvr.Enqueue(TAvrCommands.SetTreble(-1));
```

AVR master/Zone 2 volume is an **absolute 0–98 scale in 0.5 steps**, separate from HEOS CLI's integer 0–100 scale.
For example; `47.5` encodes as `MV475`; relative master volume in dB is the absolute value minus, for example: 80.
The maximum allowed volume level set in the receiver can have any value up to 100. This is a user option in the receivers menu settings.
Front-channel levels are **-12 to +12 dB in 0.5 steps**, and bass/treble are **-6 to +6 dB in integer steps**.
Use the raw interface for product-specific ranges or legacy special values; these are retained as unknown text rather than silently interpreted as valid numeric volume.

`TAvrValue` preserves `RawText` and the native `Value` string. Check `HasNumber` before reading `Number`, and `HasSwitch` before reading `Enabled`. `Number` is absolute volume for `avVolume`/`avZone2Volume`, and actual dB for channel trims or bass/treble. `avVolumeLimit` distinguishes `MVMAX` from a master-volume response.

A master-volume write is confirmed against the requested value or an observed `MVMAX` cap. A stale value such as `MV30` does not confirm a request for `MV80`. If the receiver ignores a write in standby or tone controls are unavailable in the current sound mode, the request times out as unconfirmed. The API does not power on zones or change Dynamic EQ automatically.

## Balance and batches

There is no dedicated balance command used by this app. Balance is implemented through front-left/right trims. Positive balance attenuates the left channel; negative balance attenuates the right channel. Supply the previously read channel levels as baselines to preserve calibration:

```pascal
RequestIds := FAvr.EnqueueBatch(TAvrCommands.SetBalance(2.5, LeftBaseDb, RightBaseDb));
RequestIds := FAvr.EnqueueBatch(TAvrCommands.SetBalance(0, LeftBaseDb, RightBaseDb));
```

The default baselines are both 0 dB. A zero balance restores the supplied baselines. Do not repeatedly use the last already-attenuated values as the baseline. Invalid, out-of-range or non-half-step values are rejected.

`EnqueueBatch` validates and queues the whole array under one lock, so an invalid command or a full queue does not enqueue part of a batch. The AVR still applies commands individually: a failed second channel write does not roll back the first. Each request ID has its own completion.

## Raw extension

```pascal
RequestId := FAvr.Enqueue(TAvrCommand.Raw('ECO?', 'ECO'));
```

Supply a reply prefix and optionally the exact expected value after that prefix. CR, LF, other control characters and non-ASCII command text are rejected; the worker appends the required CR. A raw reply retains the line even if its typed `Kind` is unknown. The raw interface requires a reply; it is not a fire-and-forget transport.

## Connection behavior

Only one command is outstanding on the socket. Sends are paced at least 80 ms apart, with a 1-second interval after a power-on command. Default connect/reply timeouts are 2.5 seconds. `TimeoutMs` accepts 100–60,000 ms. Existing AVR control applications may compete for a receiver's limited control connections; use one AVR client per receiver in your application.

Buffered notifications are drained before sending the next command, and typed replies distinguish Zone 2 power, source, mute and volume. The AVR protocol has no request IDs on the wire, so a matching unsolicited value cannot always be distinguished from a direct reply. The API confirms observed state; it does not claim transport-level causality.

A timed-out or lost command is **never replayed**. The connection closes so a late reply cannot complete a later request. Later queued commands may open a new connection. `DeliveryUnknown=True` means transmission was attempted and the receiver may have applied the operation. `False` means the command was not transmitted. Receiver rejection is reported as an error too.

`Disconnect()` cancels active/queued requests and closes the connection asynchronously. Wait for `Connected=False` before starting another session. It does not schedule an automatic reconnect without new work. Shutdown cancels read waits; an in-progress connect/send remains bounded by the configured socket timeout.

There are at most 256 pending commands. At 4,096 queued notifications, new event/connection notices are dropped and counted by `DroppedNotifications`, while request completions are retained. New enqueue operations are rejected until the backlog is drained. Refresh needed state after a dropped-notification count increases.

## Build and validation

From the repository root:

```powershell
.\Build.ps1 -RunTests
python .\AVR\Tests\RunAvrSimulator.py
```

The build script compiles both APIs, examples and tests for Win32/Win64. `-RunTests` runs the HEOS simulator tests and AVR encoding/parser tests. The Python command additionally runs AVR TCP tests on both targets using loopback sockets and no receiver. It checks CR framing, split replies, unsolicited updates, volume caps, Zone 2 matching, raw commands, timeout isolation/no replay, rejection, caller-thread callbacks, cancellation, atomic batch validation, bounded notifications and shutdown.

The read-only AVR example was also verified against the AVR-X2700H DAB in standby, reading power, both zones, volume, mute, source, front levels, tone and surround settings without activating the receiver.

The full application is built separately with its sample-local `Build.ps1 -MfPackRoot ...`; its included controls and DFM layouts are preserved.

## References and notices

The common AVR command framing and level encoding are documented in Denon's [AVR/AVC control protocol](https://downloads.denon.com/documentmaster/us/avr987serialprotocol.pdf). The modern tone, zone and surround commands included here also follow the working AVR-X2700H application implementation. That older protocol document is not an exhaustive command list for newer models. HEOS commands remain documented separately in the main repository README and command catalog.

FactoryX source headers and notices are preserved. See the repository's `LICENSE` and individual source files.
