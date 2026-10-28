# FactoryX HEOS CLI for Delphi

FactoryX HEOS CLI is a Delphi translation of the Harman HEOS Cli.
HEOS (Home Entertainment Operating System) is a proprietary, wireless multi-room audio and streaming platform developed by Denon.
It allows you to connect, stream, and synchronize music across multiple audio devices throughout your home using your existing Wi-Fi network.
HEOS supports small wireless speakers to high-end home theater systems from Denon and Marantz. 

Supported products are:
# Receivers
  
• Denon AV Receivers: Look for models with an "H" in the name (e.g., AVR-X1800H, AVC-X3900H, AVC-X6800H).
• Marantz AV Receivers & Preamps: Integrated into the Marantz Cinema series (Cinema 30, 40, 50, 60, 70s) and their flagship AV preamplifiers.
• Stereo Amplifiers & Mini-Systems: Devices like the Denon CEOL RCD-N12, Denon PMA-900HNE, Denon Home Amp, and Marantz Model M1/Stereo 70s.
  
# Hi-Fi Components & Adaptors
  
• Network Audio & CD Players: Premium network source players, such as the Marantz CD50n or Link 10N.
• HEOS Link / HEOS Amp: Legacy or standalone pre-amplifiers that allow you to connect old, non-smart passive speakers or traditional stereo systems into the modern HEOS Wi-Fi network.
  
# Supported Delphi versions
  
Delphi XE7 up to and including Delphi 13.1
The Delphi HEOS CLI API use the native Windows sockets; no Indy or third-party JSON libraries are needed.
  
# Suported Windows versions
Windows 10 22H2 onwards. 
  
The command layer covers **all 57 command paths in the official published HEOS CLI specification 1.17**, with 63 typed builders, including convenience builders for playlists, history and favorites.
Support on a particular product or music service is determined by its firmware.
Quick Select commands are documented for HEOS AVR/HEOS Bar products.

Specification: [Denon HEOS CLI 1.17](https://rn.dmglobal.com/usmodel/HEOS_CLI_ProtocolSpecification-Version-1.17.pdf).

## Files

| File | Purpose |
|---|---|
| `Source/Heos.Cli.pas` | Connection worker, command queue, framing, responses, events and encoding |
| `Source/Heos.Commands.pas` | Typed command builders and parameter validation |
| `Source/Heos.Sockets.pas` | Shared native Windows socket transport |
| `Examples/MfHeosRemote/MfHeosRemote.dproj` | IDE-designed VCL remote using standard controls |
| `AVR/Source/Avr.Client.pas` | Asynchronous AVR connection, command queue, replies and events |
| `AVR/Source/Avr.Commands.pas` | Typed AVR commands, validation and reply parser |
| `AVR/Samples/AvrCliDemo.dpr` | Read-only AVR status example |
| `AVR/Samples/HEOSRemote/HEOSRemote.dproj` | Full HEOS Remote VCL application with controls, playlists and audio streaming |
| `AVR/README.md` | AVR API usage, command reference and sample build instructions |
| `Examples/HeosCliDemo.dpr` | Console example that reads players, sources and groups; optional event watch |
| `COMMANDS.md` | Complete method-to-command catalog |
| `Tests/HeosApiTests.dpr` | Local HEOS simulator regression tests; does not control the receiver |
| `AVR/Tests/AvrApiTests.dpr` | AVR command validation and simulator checks |
| `AVR/Tests/RunAvrSimulator.py` | Local AVR TCP simulator using Python's standard library |

The reusable HEOS and AVR APIs are self-contained. `Source/Heos.Sockets.pas` supplies the native Windows socket transport; MfPack, Indy and third-party libraries are not required for these APIs.
The full HEOS Remote application sample requires MfPack; its custom controls and DFM forms are included.
Add `Source` to your application's Delphi unit search path. Public socket types are `THeosConnection` and `EHeosSocket`.
For AVR control, also add `AVR/Source` to the unit search path.

## Build and test

Open `Examples/HeosCliDemo.dpr`, `Examples/MfHeosRemote/MfHeosRemote.dproj` or `AVR/Samples/AvrCliDemo.dpr` in Delphi. These projects use relative source paths. For command-line builds, run this script from PowerShell:

```powershell
.\Build.ps1 -RunTests
```

The script builds the standard VCL remote, HEOS and AVR console examples, and tests for both Win32 and Win64 into `Build/Win32` and `Build/Win64`.
It uses `BDS` when set; otherwise, automatic discovery checks the Delphi XE7 registry settings and installation directory. For another Delphi installation, set `BDS` or supply `-DelphiRoot`.
You can specify another installation or a single target explicitly:

Example:
```powershell
.\Build.ps1 -DelphiRoot 'C:\Program Files (x86)\Embarcadero\Studio\15.0' -Platform Win64 -RunTests
```

`-RunTests` runs the HEOS simulator tests and AVR command/parser validation. The HEOS simulator tests use loopback sockets and do not require a receiver.
For the additional AVR TCP simulator tests, run the following after building (Python with its standard library is required only for this test runner):

```powershell
python .\AVR\Tests\RunAvrSimulator.py
```

The full HEOS Remote app is built separately because it depends on MfPack:

```powershell
.\AVR\Samples\HEOSRemote\Build.ps1 -MfPackRoot 'D:\PROJECTS\MfPack' -Platform Win64
```

See the [full app build instructions](AVR/Samples/HEOSRemote/README.md) for IDE setup and installing its controls.
Compiled executables and IDE-generated files are excluded from Git.

## Basic use

```pascal
uses Heos.Cli, Heos.Commands;

Client := THeosClient.Create('192.168.1.100');
RequestId := Client.Enqueue(THeosCommands.GetPlayers());
```

`Enqueue` returns immediately with a unique request ID. The worker connects automatically, sends requests in order and keeps the connection open. IDs returned by HEOS can be negative; player and group IDs are `Int64` throughout the API.

Choose one response-consumption style:

1. **VCL events:** assign `OnReply`, `OnEvent`, `OnProgress`, `OnError` and/or `OnConnection`. Call `Client.Dispatch()` from a normal IDE-designed VCL timer, for example every 50 ms.
   Callbacks run on the thread that calls `Dispatch`, so they can update controls when called by the VCL timer.
2. **Polling:** call `TakeMessage` from your application loop and free each returned `THeosMessage` in `finally`.

Example VCL timer and reply handler:

```pascal
procedure TMyForm.ApiTimerTimer(Sender: TObject);
begin

  FHeos.Dispatch();
end;


procedure TMyForm.HeosReply(Sender: TObject;
                              Message: THeosMessage);
begin

  if not Message.Success then
    begin
      memFLog.Lines.Add(Message.ErrorText);
      Exit;
    end;

  if (Message.Command = 'player/get_volume') then
    lblVolume.Caption := Message.Parameter('level');
end;
```

`OnReply` receives both successful replies and HEOS rejections. Check `Success`, `ErrorId`, `ErrorText`, and `IntegerParameter('syserrno')`. `OnError` reports local connection, timeout, cancellation or protocol errors. `OnProgress` receives preliminary “command under process” messages; these do not finish the request. `OnEvent` receives all current and future `event/...` messages; `EventKind` identifies the 13 documented event types.

`Root` owns the complete response, including unknown or service-specific fields. `Payload` borrows the original JSON array/object; callers do not free it. The message and its payload remain valid only during a callback, or until the polling caller frees the message. Copy data you need to retain. Do not destroy the client inside a callback; disable the timer and free it after `Dispatch` returns.

## Playback, queues and browsing

```pascal
Client.Enqueue(THeosCommands.SetPlayState(PlayerId,
                                          hpsPlay));

Client.Enqueue(THeosCommands.SetPlayMode(PlayerId,
                                         hrAll,
                                         True));

Client.Enqueue(THeosCommands.PlayUrl(PlayerId,
                                     StreamUrl));

Client.Enqueue(THeosCommands.GetQueue(PlayerId,
                                      0,
                                      49));

Client.Enqueue(THeosCommands.Browse(1024,
                                    ContainerId,
                                    0,
                                    49));

Client.Enqueue(THeosCommands.Search(SourceId,
                                    SearchText,
                                    CriteriaId,
                                    0,
                                    49));

Client.Enqueue(THeosCommands.AddTrackToQueue(PlayerId,
                                             SourceId,
                                             ContainerId,
                                             MediaId,
                                             haPlayNext));

Client.Enqueue(THeosCommands.RegisterForChangeEvents(True));
```

Ranges are inclusive and zero based.
Omitting both range arguments leaves paging to HEOS and its service-specific limits; use explicit pages for large libraries.
The library does not load a complete music library automatically or choose a source/player on your behalf.

For grouping, `SetGroup([LeaderId, MemberId, ...])` uses the first ID as leader.
Passing only the leader ID requests ungrouping.
Queue item IDs, preset numbers and service option IDs must be positive.

HEOS volume is its own **integer 0–100 scale**. 
It is not the AVR `MV` 0–98 half-step scale.
Bass, treble, balance, Main Zone and Zone 2 power use the separate AVR control protocol on port 23.
These controls are provided by the [AVR API](AVR/README.md) in this repository; they are separate from the HEOS CLI.

## Parameter encoding
  
Typed builders take **decoded** values. The command encoder escapes HEOS delimiters (`&`, `=`, `%`), control characters and non-ASCII UTF-8 bytes. Commas, input paths, plus signs and URL punctuation remain intact. A plus sign does not mean a space.
  
`Message.Parameter` returns a decoded value. Payload fields remain in their original JSON representation. For a payload `cid`, `mid` or name that HEOS has percent-encoded, call `HeosDecode` exactly once before passing it to a typed builder. Do not pre-encode decoded values or decode the entire `message` string before splitting its attributes.
  
For extensions or already-encoded payload tokens:
  
```pascal
Command := THeosCommand.Create('browse/set_service_option');
Command.Add('option', '19');
Command.Add('mid', EncodedMediaId, True);
Client.Enqueue(Command);
```
  
`SetServiceOption` accepts an option ID and arbitrary `THeosParameter` values, so it supports all documented service option argument combinations and future additions.
Account credentials are supplied by the caller; the library does not save them or log command text.
  
## Connection behavior

The default port is 1255 and the constructor requires an IPv4 address.
A known receiver address works directly. SSDP device discovery is separate and is not included in this CLI library.

The default connection timeout is 2.5 seconds; the default request timeout is 15 seconds. `TimeoutMs` can be increased up to 300,000 ms for slow services.
Idle connections send a heartbeat after 20 seconds without traffic.
JSON framing supports compact and prettified responses, multiple frames per packet, split UTF-8 characters and individual frames up to 16 MB.

Only one request is outstanding on a socket at a time.
This preserves response ordering without relying on optional browse-only `SEQUENCE` fields. Up to 256 unsent commands can be queued.
Drain messages regularly; queued notifications remain owned by the client until dispatched, taken or destroyed.
At 4,096 queued notifications, new event/progress/connection notifications are dropped and counted by `DroppedNotifications`; command completions are retained.
Enqueueing new work is rejected until the backlog is drained.
If the counter increases, refresh player/group status after draining.

A lost connection or timed-out request is **not replayed**. `DeliveryUnknown=True` means an attempted command might already have reached the receiver.
The connection is discarded after a timeout so its late reply cannot complete a newer request.
Future queued commands use a new connection.
Event subscriptions are restored after connection loss, with retry delays capped at 30 seconds.

`Disconnect` asynchronously cancels queued requests and the active exchange, closes the socket and stops automatic subscription reconnection.
Cancellation of unsent commands has `DeliveryUnknown=False`.
An active exchange can have uncertain delivery.
Wait for `Connected=False` before opening a new session.
Disable VCL dispatch timers before freeing the client.
Shutdown cancels reads without synchronizing worker callbacks with the GUI; a native connect/send already in progress is bounded by the connection/socket timeout.

## Console example

```text
HeosCliDemo.exe 192.168.1.100
HeosCliDemo.exe 192.168.1.100 30
```

The example does not change volume, start playback, sign in, reboot or modify queues.
The second invocation watches events for 30 seconds using a connection-local event subscription.

## VCL remote sample

Open `Examples/MfHeosRemote/MfHeosRemote.dproj` for a simple MfPack-style remote using standard VCL components.
Enter a receiver IP, connect and select a player. The sample provides playback controls, volume, mute, now-playing information, progress and a bounded log.
All controls and event bindings are defined in the DFM. Replies and events are dispatched by a VCL timer on the UI thread.
See the [VCL sample README](Examples/MfHeosRemote/README.md) for operation and callback handling.

## AVR API and full application sample

The AVR API complements HEOS playback control with receiver configuration and zone control over TCP port 23.
It uses `TAvrClient` and `TAvrCommands`, with an asynchronous queue, typed replies, unsolicited updates and a raw-command extension.
Connecting does not activate the receiver or either zone; power changes require an explicit command.

Supported controls include:

- Receiver power, Main Zone and Zone 2 activation.
- Volume, observed master-volume limits, mute and input selection.
- Front-left/right channel levels and balance using supplied calibration baselines.
- Tone control, bass, treble, surround mode and Dynamic EQ.

Basic read-only use:

```pascal
uses Avr.Client, Avr.Commands;

AvrClient := TAvrClient.Create('192.168.1.100');
RequestId := AvrClient.Enqueue(TAvrCommands.GetMainZonePower());
RequestId := AvrClient.Enqueue(TAvrCommands.GetVolume());
```

Call `AvrClient.Dispatch()` from a VCL timer, or poll `TakeMessage` and free returned messages, as described in the [AVR API documentation](AVR/README.md).
The AVR API covers the receiver functions used by the app; model-specific commands and availability depend on the receiver and firmware.
AVR volume uses a separate 0–98 scale in 0.5 steps, while bass and treble use -6 to +6 dB. Balance adjusts front-channel trims rather than a dedicated balance command.

`AVR/Samples/AvrCliDemo.dpr` demonstrates the new API directly with read-only status queries.

The complete HEOS Remote VCL application is included under `AVR/Samples/HEOSRemote`, with its custom controls, playlist editor, RDJ Pro playlist import, file streaming and Windows audio streaming.
It requires MfPack and preserves the original application's transport code and DFM layouts; this source snapshot has not been migrated to the new APIs.
See the [application sample README](AVR/Samples/HEOSRemote/README.md) for its dependencies and build instructions.

## Validation

Validated during development with the installed Delphi XE7 Win32 and Win64 compilers.
Simulator tests cover wire encoding, signed IDs, paging, command confirmation, pretty/fragmented Unicode JSON, payloads larger than 64 KB, bounded event backlogs, HEOS/system errors, interleaved events, preliminary replies, callback thread affinity, timeout isolation, subscription restoration and cancellation/shutdown.
Read-only GetPlayers, GetMusicSources and GetGroups were also verified against the tested AVR-X2700H during development.
AVR simulator checks also cover CR framing, split replies, volume limits, Zone 2 matching, rejection, timeout isolation, callbacks, cancellation, batch validation, bounded notifications and shutdown.
Read-only AVR queries were verified against the AVR-X2700H DAB in standby without activating the receiver.
Music service availability and product-specific commands still depend on the receiver, its firmware and the associated service account.

## Scope and notices

This repository contains the HEOS CLI library, the AVR control API, console examples, a standard VCL remote and their tests.
The full HEOS Remote application is included as a separate MfPack-dependent sample under `AVR/Samples/HEOSRemote`.
Original FactoryX source headers and notices are preserved. See `LICENSE` and the notices in each source file.
