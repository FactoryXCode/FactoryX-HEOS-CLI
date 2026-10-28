# FactoryX HEOS CLI for Delphi

Delphi XE7, Windows Win32 and Win64. Native Windows sockets; no Indy or third-party JSON library.

The command layer covers **all 57 command paths in Denon's published HEOS CLI specification 1.17**, with 63 typed builders, including convenience builders for playlists, history and favorites. Support on a particular product or music service is determined by its firmware. Quick Select commands are documented for HEOS AVR/HEOS Bar products, and should not be assumed to work on the AVR-X2700H. `GetServiceOptions` is retained for compatibility although the specification marks it obsolete.

Specification: [Denon HEOS CLI 1.17](https://rn.dmglobal.com/usmodel/HEOS_CLI_ProtocolSpecification-Version-1.17.pdf).

## Files

| File | Purpose |
|---|---|
| `Source/Heos.Cli.pas` | Connection worker, command queue, framing, responses, events and encoding |
| `Source/Heos.Commands.pas` | Typed command builders and parameter validation |
| `Examples/HeosCliDemo.dpr` | Console example that reads players, sources and groups; optional event watch |
| `COMMANDS.md` | Complete method-to-command catalog |
| `Tests/HeosApiTests.dpr` | Local simulator regression tests; does not control the receiver |

The repository is self-contained. `Source/Heos.Sockets.pas` supplies the native Windows socket transport; MfPack, the HEOS Remote application, Indy and third-party libraries are not required. Add `Source` to your application's Delphi unit search path. Public socket types are `THeosConnection` and `EHeosSocket`.

## Build and test

Open `Examples/HeosCliDemo.dpr` or `Tests/HeosApiTests.dpr` directly in Delphi XE7. Both projects use relative source paths. For command-line builds, run this script from PowerShell:

```powershell
.\Build.ps1 -RunTests
```

The script builds the demo and simulator tests for both Win32 and Win64 into `Build/Win32` and `Build/Win64`. It finds Delphi XE7 using `BDS`, the installed registry settings, or the usual installation directory. You can specify another installation or a single target explicitly:

```powershell
.\Build.ps1 -DelphiRoot 'C:\Program Files (x86)\Embarcadero\Studio\15.0' -Platform Win64 -RunTests
```

The simulator tests use loopback sockets and do not require a receiver. Compiled executables and IDE-generated files are excluded from Git.

## Basic use

```pascal
uses Heos.Cli, Heos.Commands;

Client := THeosClient.Create('192.168.1.100');
RequestId := Client.Enqueue(THeosCommands.GetPlayers());
```

`Enqueue` returns immediately with a unique request ID. The worker connects automatically, sends requests in order and keeps the connection open. IDs returned by HEOS can be negative; player and group IDs are `Int64` throughout the API.

Choose one response-consumption style:

1. **VCL events:** assign `OnReply`, `OnEvent`, `OnProgress`, `OnError` and/or `OnConnection`. Call `Client.Dispatch()` from a normal IDE-designed VCL timer, for example every 50 ms. Callbacks run on the thread that calls `Dispatch`, so they can update controls when called by the VCL timer.
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
Client.Enqueue(THeosCommands.SetPlayState(PlayerId, hpsPlay));
Client.Enqueue(THeosCommands.SetPlayMode(PlayerId, hrAll, True));
Client.Enqueue(THeosCommands.PlayUrl(PlayerId, StreamUrl));
Client.Enqueue(THeosCommands.GetQueue(PlayerId, 0, 49));
Client.Enqueue(THeosCommands.Browse(1024, ContainerId, 0, 49));
Client.Enqueue(THeosCommands.Search(SourceId, SearchText, CriteriaId, 0, 49));
Client.Enqueue(THeosCommands.AddTrackToQueue(PlayerId, SourceId,
                                            ContainerId, MediaId, haPlayNext));
Client.Enqueue(THeosCommands.RegisterForChangeEvents(True));
```

Ranges are inclusive and zero based. Omitting both range arguments leaves paging to HEOS and its service-specific limits; use explicit pages for large libraries. The library does not load a complete music library automatically or choose a source/player on your behalf.

For grouping, `SetGroup([LeaderId, MemberId, ...])` uses the first ID as leader. Passing only the leader ID requests ungrouping. Queue item IDs, preset numbers and service option IDs must be positive.

HEOS volume is its own **integer 0–100 scale**. It is not the AVR `MV` 0–98 half-step scale. Bass, treble, balance, Main Zone and Zone 2 power belong to the separate AVR control protocol on port 23; those commands are outside this library.

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

`SetServiceOption` accepts an option ID and arbitrary `THeosParameter` values, so it supports all documented service option argument combinations and future additions. Account credentials are supplied by the caller; the library does not save them or log command text.

## Connection behavior

The default port is 1255 and the constructor requires an IPv4 address. A known receiver address works directly. SSDP device discovery is separate and is not included in this CLI library.

The default connection timeout is 2.5 seconds; the default request timeout is 15 seconds. `TimeoutMs` can be increased up to 300,000 ms for slow services. Idle connections send a heartbeat after 20 seconds without traffic. JSON framing supports compact and prettified responses, multiple frames per packet, split UTF-8 characters and individual frames up to 16 MB.

Only one request is outstanding on a socket at a time. This preserves response ordering without relying on optional browse-only `SEQUENCE` fields. Up to 256 unsent commands can be queued. Drain messages regularly; queued notifications remain owned by the client until dispatched, taken or destroyed. At 4,096 queued notifications, new event/progress/connection notifications are dropped and counted by `DroppedNotifications`; command completions are retained. Enqueueing new work is rejected until the backlog is drained. If the counter increases, refresh player/group status after draining.

A lost connection or timed-out request is **not replayed**. `DeliveryUnknown=True` means an attempted command might already have reached the receiver. The connection is discarded after a timeout so its late reply cannot complete a newer request. Future queued commands use a new connection. Event subscriptions are restored after connection loss, with retry delays capped at 30 seconds.

`Disconnect` asynchronously cancels queued requests and the active exchange, closes the socket and stops automatic subscription reconnection. Cancellation of unsent commands has `DeliveryUnknown=False`. An active exchange can have uncertain delivery. Wait for `Connected=False` before opening a new session. Disable VCL dispatch timers before freeing the client. Shutdown cancels reads without synchronizing worker callbacks with the GUI; a native connect/send already in progress is bounded by the connection/socket timeout.

## Console example

```text
HeosCliDemo.exe 192.168.1.100
HeosCliDemo.exe 192.168.1.100 30
```

The example does not change volume, start playback, sign in, reboot or modify queues. The second invocation watches events for 30 seconds using a connection-local event subscription.

## Validation

Built with the installed Delphi XE7 Win32 and Win64 compilers. Simulator tests cover wire encoding, signed IDs, paging, command confirmation, pretty/fragmented Unicode JSON, payloads larger than 64 KB, bounded event backlogs, HEOS/system errors, interleaved events, preliminary replies, callback thread affinity, timeout isolation, subscription restoration and cancellation/shutdown. Read-only GetPlayers, GetMusicSources and GetGroups were also verified against the AVR-X2700H during development. Music service availability and product-specific commands still depend on the receiver, its firmware and the associated service account.

## Scope and notices

This repository contains the HEOS TCP CLI library, a console example and its simulator tests. It does not include the HEOS Remote VCL application, audio streaming server or AVR control protocol. Original FactoryX source headers and notices are preserved. See `LICENSE` and the notices in each source file.