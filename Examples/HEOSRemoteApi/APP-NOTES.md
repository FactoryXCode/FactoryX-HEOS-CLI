# HEOS Remote - Delphi VCL application

Receiver controls, music-file playback and live Windows sound for
Denon and Marantz devices that supports HEOS / AVR protocols. 
No Indy, BASS, FFmpeg or extra audio DLLs are needed.

## Main volume

The main-volume slider replaces the two step buttons. Its displayed number
follows the receiver's absolute 0.0–98.0 scale, using the requested `%` label:
`MV475` displays as **47.5%**, and `MV48` as **48.0%**. The value is not
converted to relative dB or rescaled to a different percentage.

The slider moves in 0.5 steps. Changes are combined over 150 ms and sent as
direct volume commands. Only the most recent value is retained while a request
is in flight. The slider stays usable, and the volume request finishes as soon
as the receiver reports a numeric volume; it does not collect the full
2.5-second status window. Receiver-reported limits are reflected in the slider.
Status refresh synchronizes the slider without sending another volume command.

All controls and the timer are editable VCL designer components in MainForm.dfm.
`Tests\VolumeSliderTests.dpr` verifies scaling, command encoding, rapid changes,
status synchronization, fast replies and receiver limits against a localhost
simulator. Tests do not change the physical receiver's volume.

## Main-zone and ZONE2 power

**Main zone on / Main zone standby** control the main zone independently.
**ZONE2 on / ZONE2 standby** control the second zone independently. Standby
keeps the receiver connected to mains power; configure Network Control as
Always On to retain remote access while both zones are in standby.

**Read status** refreshes both zones. Status values come from receiver replies;
an unanswered power command is reported as unconfirmed. Main-zone standby
does not send a ZONE2 standby command, and ZONE2 controls do not cancel the
main-zone playlist queue.

The controls use Denon's TCP AVR interface on port 23: `ZMON`, `ZMOFF`,
`Z2ON`, `Z2OFF`, and the `ZM?` / `Z2?` status queries. Read-only queries to
the actual receiver returned `ZMOFF` and `Z2OFF` while it was in standby.
No physical power changes were made during validation. `Tests\ZonePowerTests.dpr`
tests the VCL buttons against a localhost receiver simulator on port 23.

## Playlist editor, fast file browser and Denon discovery

Click **Find HEOS device** to discover receivers on the local IPv4 interfaces using
SSDP. A device's UPnP description is checked for Denon before accepting it.
A single result fills `MainForm.edHost.Text` automatically. When several
devices reply, choose one from the list at the top; the current receiver is
retained if found. Discovery runs on a background thread. It does not turn on
the receiver or change settings. Manual IP entry remains available.
Live discovery was verified against `192.168.50.103`, which identified itself
as `Denon AVR-X2700H`.

**Browse** on MainForm and **Open File** in the playlist editor both use
RDJ Pro's `LWFileBrowserExDlg`, including its network browser. Its standard
VCL controls and layout are editable in `LWFileBrowserExDlg.dfm`.
MainForm's browser starts in the folder of the currently selected music file.
Cancel keeps the existing selection.

**Playlist editor** now uses the actual MfRdj Pro editor and its SQLite,
track-library, playlist-manager, scanner, metadata and tag-editor units.
Its layout is copied from `frmPlaylistEditor.dfm` into `DenonPlaylistForm.dfm`.
Custom `TMPxpButton` controls are replaced with `TButton`.

1. Use **Scan Folder** to populate the database in the background.
2. The library grid stays empty until you enter a search and press **Search**.
   It fetches only matching summary rows using Pro's `SearchTrackSummaries`.
   **Clear**, an empty search and a whitespace search leave it empty.
3. Create/select a named playlist. Add library rows, remove them or move them
   up/down. Changes save automatically to the SQLite database.
4. Right-click a playlist for Pro's load/play actions. Channel 1 routes to the
   Denon receiver. Loading prepares the main-form queue; playing starts it.
5. Use Pro's library context menu or **Tag Editor** for metadata editing.

The database is `Data\RDJLibrary.db` beside the executable. It is created on
first editor use. This update does not copy the RDJ Pro application's database
or import older M3U files. Existing M3U files remain available on disk.
Search, database and playlist-manager behavior are retained from Pro; host
integration is isolated in `DenonRdjBridge.pas`. Local lifecycle adjustments
detach/wait for worker threads when closing forms and clean up queued progress.

Auto-next is enabled by the checkbox on MainForm. It polls HEOS and advances
after observing playback change from play to stop. Use Stop streaming in this
app to cancel the playlist; a stop from another controller can be interpreted
as the end of a track. Tracks too short to be observed playing may require Next.
Auto-next and audible sequential playback still need a live receiver check.
No automatic changes are made to the Denon's stored HEOS queue.

The existing main-form edits and `edHost` component name are preserved.

## Open and build

Open `DenonRemote.dproj` in Delphi XE7. Both Win32 and Win64 are supported;
the existing project selects Win64 by default.
Open `MainForm.pas` and press F12 for the editable VCL form. Use Ctrl+F9 to
compile and F9 to run. Reopen the project if it was already open during this update.

The project uses the existing MfPack headers in `..\MfPack\src`, which resolves
to `D:\PROJECTS\MfPack\src` from `D:\PROJECTS\Denon`.
The `MfPackRoot` project property can override that location. New DCUs go into
the platform/configuration folder to avoid mixing them with older root DCUs.
The compiled executable uses Windows audio and Media Foundation services;
it does not require MfPack to be installed as a runtime package.
The playlist database requires `sqlite3.dll` beside the executable. The project
copies the matching DLL from `Runtime\Win32` or `Runtime\Win64` after building.
Keep that DLL alongside the EXE when distributing the application.

`Tests\RdjEditorTests.dpr` verifies a separate 5,000-track fixture database,
empty initial/cleared searches, matching summaries, playlist editing and
persistence, Denon routing and VCL streaming of the three copied forms.
It passed on both Win32 and Win64. It does not play audio or edit production data.

## Play a music file

1. Confirm the receiver IP at the top (default `192.168.50.103`).
2. Click Browse and choose an MP3, FLAC, WAV, AAC, M4A or WMA file.
3. Leave PC IP blank for automatic network-interface detection.
4. Click Play music file. Allow the app through Windows Firewall on your
   private home network if Windows prompts.
5. Wait for HEOS to buffer and begin playing. Start with MP3 for the first check.

The PC serves only the selected file, at a generated URL, on TCP port 8890 by
default. It does not share a folder or transcode the file. Codec support and
the file's sample rate/bit depth must match the receiver's capabilities.
HTTP HEAD and single byte-range requests are supported.

Pause file and Resume file send HEOS playback commands. Support for pausing
and resuming a particular URL depends on the receiver/format. This version
does not implement a seek slider; playlist editing is described above.

## Stream Windows sound

1. Keep the PC's normal speakers/headphones as its Windows playback device.
2. Click Stream Windows sound.
3. Play audio in your browser, media player or another Windows application.
4. Click Stop streaming to end capture and request that HEOS stop playback.

The app captures the **default multimedia playback device** through WASAPI
loopback, converts to stereo PCM at 44.1 kHz, encodes AAC-LC at 192 kbps using
the Windows Media Foundation encoder, and serves a continuous ADTS AAC URL.
The receiver retrieves this stream through HEOS. No microphone is selected.
Capture starts only when you click the button and ends when stopped or closed.
No audio is saved to a recording file.

Audio routed by another app to a different output device is outside this
capture. Stop and restart streaming after changing the default device.
Protected audio or exclusive-mode playback can be unavailable to loopback.
Live streaming has receiver/network buffering delay, so it is for listening
rather than synchronized games or video. Windows sound is stereo, not 7.2.
The local speakers may still play; this app does not change Windows device
volume or route audio away from them. Loopback silence can result if you mute
the source/output in Windows. Adjust listening volume on the Denon instead.

The file and live modes replace one another; they are not mixed together.
Live mode has Stop rather than Pause, so a resumed connection cannot play a
growing backlog of old Windows audio. Queued encoded data is bounded.

## Network and diagnostics

- AVR control: outbound TCP 23; HEOS control: outbound TCP 1255.
- Receiver fetches audio: inbound TCP 8890 on the selected PC interface.
- Change HTTP port if 8890 is already in use; change PC IP to a local LAN
  address if automatic detection chooses the wrong interface (for example VPN).
- Set Denon Network Control to Always On for standby access.
- PC and receiver must be able to communicate on the same LAN. Guest Wi-Fi
  isolation or firewall rules may block audio even when AVR commands work.
- HEOS accepting a URL is not proof that the receiver fetched or decoded it.
  The form shows HTTP request count and a log with the URL and HEOS errors.
  Zero requests generally points to a routing/firewall or HEOS playback issue;
  requests with no sound may indicate buffering, file/codec support or silence.
- The HTTP server serves one receiver connection at a time. The generated URL
  is local and temporary; stop streaming when finished.
- No firewall settings or router settings are modified by the app.
- Closing shuts down local capture and serving; Stop streaming also sends
  the receiver's explicit HEOS stop command.

## Implementation and reused source

- `DenonSockets.pas`: native Windows sockets and bounded receiver connections.
- `DenonTransport.pas`: existing AVR commands, with Indy removed.
- `DenonHeos.pas`: HEOS player discovery, URL playback and playback state.
- `DenonAudioServer.pas`: selected-file HTTP and bounded live AAC delivery.
- `DenonLoopback.pas`: dedicated capture thread using the WASAPI pattern from
  MfPack's `Samples\MfCaptureVideoFromGPU II\WasapiLoopbackCapture.pas`.
- `DenonAacEncoder.pas`: adapted from
  `Samples\MFRDJ Samples\MfRdjJ\MfBroadcastEncoderAac.pas`. Removes RDJ UI/setup
  dependencies and enables ADTS framing for HTTP audio playback.

Original FactoryX/MfPack/RDJ copyright and license headers are retained in
adapted units. The source MfPack tree is read only; it is not changed by this project.

## Validation

Built the application with your Delphi Win32/Win64 compiler.
Automated checks passed for:

- VCL DFM loading and streaming event bindings without starting capture;
- default Windows output initialization in the requested stereo PCM format,
  exiting before capture starts;
- 100 valid ADTS frames from a synthesized tone through the Windows AAC encoder;
- local HTTP file data, HEAD, byte ranges, invalid ranges and unregistered paths;
- stopping/restarting the listener on the same port;
- continuous live HTTP delivery of synthetic AAC;
- simulated HEOS discovery with multiple players, event filtering, correct player
  selection, CR/LF framing, URL playback and rejected-command error handling.

The test source is in `Tests\StreamingTests.dpr`. Its listeners bind to localhost
on ports 18890 and 21255. It does not capture Windows audio or contact the Denon.
It writes and removes a temporary `fixture.mp3` in its working directory.

Actual Windows audio capture and audible playback on your receiver still need
a live check using the new buttons. Your existing receiver controls remain present.

References:

- Denon model manual: https://manuals.denon.com/AVRX2700H/EU/EN/
- HEOS CLI (Play URL): https://assets.denon.com/documentmaster/us/heos_cli_protocolspecification-version.pdf
- Windows loopback: https://learn.microsoft.com/en-us/windows/win32/coreaudio/loopback-recording
- Windows AAC encoder: https://learn.microsoft.com/en-us/windows/win32/medfound/aac-encoder

Project: FactoryX - HEOS-CLI 
Project location: FactoryXCode  
  
https://github.com/FactoryXCode/FactoryX-HEOS-CLI  
  
First release date: 13/08/2026  
Final release date: 29/10/2026  
  
Copyright © FactoryX. All rights reserved.
