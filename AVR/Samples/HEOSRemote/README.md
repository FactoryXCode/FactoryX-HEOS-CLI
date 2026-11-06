# HEOS Remote AVR sample 1.1.13

Minimum suported Delphi version: XE7.

This is the complete Delphi VCL HEOS Remote application, including its DFM forms, custom controls, playlist editor, RDJ-derived library support, native audio streaming and AVR control code. It is copied from the working application; the original project is unchanged. Receiver databases, INI files, credentials, compiled output and local IDE settings are not included.

The existing file/Windows-audio and AVR controls use their original `HEOSTransport.pas` and `Heos.pas` adapters. The new Internet Radio window uses `THeosClient` and `THeosCommands` directly from the API at `D:\GitHub\FactoryX-HEOS-CLI`. The reusable APIs are in `AVR/Source` and the repository's top-level `Source`; this source snapshot has not been silently migrated to them. `AVR/Samples/AvrCliDemo.dpr` demonstrates the new AVR API directly.

The API-based copy is available in [Examples/HEOSRemoteApi](../../../Examples/HEOSRemoteApi/README.md), using `THeosClient` and `TAvrClient`.

## Internet radio (version 1.1)

Click **Radio** on the main toolbar. The receiver's advertised radio services
(including TuneIn and HEOS Favorites where available) are listed. Double-click
categories, use Home/Back or page buttons, and select a station with **Play
station**. Search uses the criteria advertised by the selected service; it is
disabled for services without supported search criteria. Configure service
accounts in the official HEOS app if a service requires them.

Stations play directly on the receiver, so the PC's HTTP audio server and
Windows capture are not used. Browsing alone keeps the current source playing.
Starting a station cancels local file/playlist/Windows streaming. The main Stop
button or **Stop radio** stops the station; Pause and seeking are unavailable
for live radio. If a file is selected, **Play file** switches back to that file.
Closing the Radio window keeps the station playing. Closing the
application does not explicitly stop receiver-direct radio playback.

Radio requests run asynchronously through the reusable API; network errors are
shown in the Radio status label. Source availability depends on receiver
firmware, region and service accounts. Only playable `station` entries are sent
to `PlayStation`; folders and non-station favorites cannot be played as radio.
No network credentials or station catalogue are bundled.

See [RADIO.md](RADIO.md) for design and verification notes.

## Floating Radio window and station logos (version 1.1.11)

The **Radio** window is modeless: leave it open while adjusting volume, balance,
zones and other controls on the main console. Closing Radio hides the window;
receiver playback and pending commands continue. Reopening it restores the same
browser. Console source changes and Stop are queued behind an outstanding Radio
play/stop command to preserve their order.

Selecting a station displays its receiver-supplied artwork/logo beside the list.
The picture is centred and scaled proportionally. Downloads and decoding run in
a background worker, with a short debounce for fast selection changes. An old
download cannot replace the logo for a newer selection. Missing/unavailable
logos show a text placeholder without affecting playback. PNG, JPEG, GIF and BMP
are supported; the URL need not have a filename extension. The artwork controls
and layout are editable in `HEOSRadioForm.dfm`.

## Receiver address and startup (version 1.1.1)

Startup follows this route:

1. Read the last confirmed receiver IP from the INI.
2. If it is a valid IPv4 address, check its HEOS control port 1255 in the background.
3. If reachable, continue without a network scan. AVR port 23 is checked separately
   for receiver settings; its absence does not prevent HEOS radio.
4. If the saved address is missing, malformed or unreachable, discover HEOS
   devices. Match the saved device ID where available, or select a unique device.
   Multiple ambiguous results require selection in the device list.
5. Update `edHost` and the INI with the confirmed IP. If no device is found,
   report it in the status and log; no radio commands are sent to the old address.

Settings are stored per user at
`%LOCALAPPDATA%\FactoryX\HEOSRemote\Receiver.ini`:

```ini
[Receiver]
Host=<last confirmed receiver IPv4 address>
DeviceId=<device UDN obtained during discovery>
```

Only confirmed addresses are saved. Radio waits for an outstanding startup check
or discovery to finish. Initial socket connection failures are returned by the
API as error messages, without raising a first-chance socket exception. Use
**Find HEOS** to retry discovery if the receiver moves or becomes available later.

## Build

This application requires MfPack's `src` folder as well as Delphi XE7 or higher up to 13.1. Its custom `TDn` controls are included under `Controls`. For form editing, install the included `Controls/HEOSControls.dproj` package in the Win32 Delphi IDE if these classes are not installed already.

```powershell
.\Build.ps1 -MfPackRoot 'D:\PROJECTS\MfPack' -Platform Win32
.\Build.ps1 -MfPackRoot 'D:\PROJECTS\MfPack' -Platform Win64
```

Executables and DCUs go under the repository's `Build` directory. For IDE builds, set the `MfPackRoot` environment variable before starting Delphi, or set that MSBuild property when invoking `HEOSRemote.dproj`. Its search path uses `Controls`, `$(MfPackRoot)\src` and `$(HeosCliRoot)\Source`. The HEOS API root defaults to `D:\GitHub\FactoryX-HEOS-CLI`; override `-HeosCliRoot` in Build.ps1 or that MSBuild property if you move it. Both Debug and Release use these paths.

The application's longer development notes are preserved in `APP-NOTES.md` and `RDJ-SOURCE-NOTES.md`. Main Zone and Zone 2, tone controls and channel levels use the AVR protocol; HEOS playback uses its separate CLI. Availability depends on the receiver's settings and firmware. No receiver is contacted by building the project.

## Custom radio stations

Enter a Name and the complete direct HTTP/HTTPS audio stream URL in Radio,
then click **Add station**. The **My stations** service lists saved stations;
select one and click **Play station**. The receiver fetches the audio directly.
A website or hostname alone is not necessarily an audio stream; include the
stream port/path when needed. The receiver must support the stream format.

Stations persist in `%LOCALAPPDATA%\FactoryX\HEOSRemote\RadioStations.ini`
(UTF-8), separately from receiver settings. **Remove station** deletes the
selected custom entry; playback continues until stopped. These are personal
application entries, not public TuneIn listings or receiver HEOS Favorites.
No custom artwork is supplied. Existing receiver service artwork still works.

Add station displays persistent confirmation or error text below its fields.
Both Name and URL are required. Saving does not test reachability or audio:
use Play station to ask the receiver to play the saved stream.

After a station command is accepted, Radio checks `player/get_play_state` in
the background. The console shows loading until HEOS reports `state=play`.
After 15 seconds without confirmation, it shows Still waiting and keeps
checking; radio mode and Stop remain available. Controls remain available during the checks; Stop
cancels monitoring, and late replies cannot restore the old playback display.
Receiver-reported play does not itself verify audible speaker output.

Playback monitoring continues after confirmation and reflects a receiver-reported
Stop. Unknown status never proves that audio has stopped; late playback is
confirmed without requiring the station to be started again.

Radio uses a separate THeosClient for playback status. An unknown reply or
query error reconnects that read-only client before its next poll. Playback
commands and browsing retain their own connection; status refresh never
replays Play/Stop. The regression receiver holds unknown status on the
connection which sent Play, while a fresh status connection reports play.

## Receiver capabilities (1.1.11)

The console uses `Avr.Capabilities.pas` from `D:\GitHub\FactoryX-HEOS-CLI\AVR\Source`.
Both the API `Source` and `AVR/Source` folders are included by the project and build script.
On startup it restores cached capabilities, then refreshes `/goform/Deviceinfo.xml`
in a background worker after the receiver is confirmed. No zone is powered on.

The cache is `Capabilities.ini` beside `Receiver.ini` in the user's
`%LOCALAPPDATA%\FactoryX\HEOSRemote` directory. It is keyed by the discovery device ID,
so a DHCP address change does not discard the same receiver's capabilities.
A different receiver does not inherit its cached flags. Devices without a confirmed
identity are refreshed without persisting a cache.

Unsupported controls are disabled with a hint. Unknown support retains standard AVR
control as a compatibility fallback. Connection failures preserve cached support;
current connection availability is shown separately. Tone still depends on Main Zone,
sound mode and Dynamic EQ. Unsupported commands are omitted from receiver requests.
Use Read status to verify the receiver and refresh capabilities again.

Capability regression checks:

```powershell
python D:\GitHub\FactoryX-HEOS-CLI\AVR\Tests\RunCapabilitiesTests.py `
  --sample-root D:\PROJECTS\FactoryX-HEOS-CLI\AVR\Samples\HEOSRemote `
  --mfpack-root D:\PROJECTS\MfPack
```

These use local HTTP/TCP simulators and do not control the actual receiver.

## Custom stations (1.1.12)

Right-click a row in **My stations** to remove that saved station or set its
logo URL (PNG, JPEG, GIF or BMP). Removing a saved entry does not stop playback.
Logo URLs are stored in RadioStations.ini alongside the station name and stream.

Before playing a custom URL, the app checks its HTTP response in the background.
A webpage or HTTP error is reported without replacing the current audio source.
When a webpage publishes an icon, the app can save that icon as the station logo.
Passing the HTTP check does not prove receiver codec/TLS compatibility; playback
is still confirmed separately through HEOS.

Use a direct audio stream URL for radio. A website with an embedded browser/PWA
player is not itself an audio stream, and HEOS cannot run that page's JavaScript.
RDJ Pro can publish background AAC alongside its fragmented-MP4 browser broadcast.
For FactoryX Radio, use `https://factoryxradio.asuscomm.com/radio/live.aac` while
RDJ's public broadcast is active. HEOS Remote does not start the RDJ sender.

Custom stations also support local artwork: right-click a station in My stations,
choose **Choose station logo...**, and select a PNG, JPEG, GIF or BMP with the LW
file browser. The full file path is saved in RadioStations.ini; keep the image at
that location. **Station logo URL...** remains available for online images.

Closing the main HEOS Remote window stops its receiver playback before exiting.
Pending source starts are cancelled, and any playback request already in flight
finishes before the final Stop. If Stop fails, the remote stays open and reports
the error so closing can be retried. Hiding only the Radio window keeps playback
running. Closing an idle remote that has not controlled playback sends no Stop.

A custom station can use the website address, for example
`https://factoryxradio.asuscomm.com/`. When that URL returns HTML, Remote checks
`/radio/live.aac` on the same host and plays it only after a successful AAC
response. The saved address stays unchanged. Missing/non-AAC endpoints are
reported without interrupting current playback. Browser/PWA MP4 behavior is
unchanged; this lookup happens in HEOS Remote only.

To set custom station artwork without the popup, select the station in My
stations and click **Logo**. The LW image browser fills the logo field with the
full file path and saves it with that station. You can also type an image URL
or existing PNG/JPEG/GIF/BMP path and press Enter or leave the field to save.
Clear the field to remove the custom logo.

The Radio play control is a single toggle: checked while a station is active
or its URL is being checked; click again to stop or cancel the URL check.
Receiver Stop and console Stop clear it. The separate Stop radio button was
removed; choosing another station for playback remains available by double-click.

## Windows-audio AAC settings

The existing Setup bit-rate and channel controls select 96, 128, 160 or 192 kbps and stereo or mono for **Stream Windows audio**. Defaults are 192 kbps stereo. Choices are saved in the `[AAC]` section of `Receiver.ini`, even without a connected receiver. Stop Windows streaming to edit them; they apply on the next start. Capture stays at 44.1 kHz stereo, with mono averaging left and right before AAC-LC/ADTS encoding. File playback and receiver-direct radio keep their original formats.

## Live error handling

Live HEOS operations report expected network, receiver, capture and encoder failures through status/log results. They do not raise Delphi exceptions or open modal error dialogs. Checked socket methods distinguish an ordinary polling timeout from disconnect/error; playback commands are never replayed after an uncertain send. INI writes use checked OS I/O and replace the previous file only after a complete save.
