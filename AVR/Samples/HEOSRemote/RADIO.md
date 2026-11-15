# HEOS Remote 1.1.2: Internet radio

The new Radio form is an editable VCL DFM. Navigation and playback buttons use
the included TDn button; services/search use standard combo boxes and an edit,
and results use a standard VCL ListView. No controls are created or positioned
in Pascal code.

`HEOSRadioForm.pas` uses the reusable `Heos.Cli` and `Heos.Commands` units from
`D:\GitHub\FactoryX-HEOS-CLI\Source`. A TTimer drains asynchronous API messages
on the GUI thread. The API worker handles connections, JSON framing, timeouts
and command serialization. Refresh retries the selected receiver connection after an error; use the main
Settings / Find HEOS action to locate a receiver whose IP changed.

The selected receiver is matched by IPv4 address in `get_players`; a different
player is never selected merely because it is first in a multi-device list.
Radio services are drawn from `get_music_sources`, and unavailable services are
excluded. Browsing uses returned container/media IDs, including item-level
source IDs in Favorites. Search criteria come from `get_search_criteria` rather
than hardcoded search identifiers. Protocol-encoded payload names/IDs are
decoded exactly once before typed command builders encode them for transmission;
literal plus signs and percent sequences survive the round trip.

Results are paged in groups of 50. Unknown totals remain pageable until an
empty response; top-level service browsing omits ranges except for Favorites,
as required by the protocol. A failed navigation retains the current list and
Back history. Account and service errors are shown without storing credentials.

Only `type=station`, `playable=yes` items with a media ID may play. Station
playback calls `PlayStation`; stop calls `SetPlayState(hpsStop)`. The receiver
fetches the radio audio itself. The local file/Windows-audio producer is stopped
only when the user starts a station. Existing playback commands must finish
first; browsing does not interrupt them. The Radio window is modeless, so console volume, balance and AVR controls
remain usable. The console queues source changes and Stop until a pending radio
play/stop finishes; BeforeRadioPlay prevents overtaking an existing console
transport command. No GUI thread waits for a receiver response. Closing hides
the browser while playback and pending requests continue; the owned form is
freed only when the application closes.

The main form reports live radio duration/elapsed time and disables file
Pause, seeking and previous/next while radio is active. If a file is selected,
the main transport offers **Play file** to switch to it. Its existing Stop action
can stop the radio, and starting a local source restores normal file controls.

Protocol reference: [Denon HEOS CLI specification](https://assets.denon.com/documentmaster/us/heos_cli_protocolspecification-version.pdf),
music browsing/search and Play Station commands. Service/account availability
and actual station audibility require verification on a real receiver.

## Verification

Delphi XE7 Win32 and Win64 builds passed. Local mock-receiver tests cover DFM
creation, matching the selected receiver in a multi-player list, radio
service filtering regardless of the account flag, category browsing, search criteria, paging with known and
unknown totals, failure recovery, service/account errors, UTF-8 and encoded
station/container IDs, direct station playback, both Stop controls, handover
from the local queue, live time display and switching back to file controls.
No physical receiver playback or volume was changed by these tests.

To repeat with Python 3 and Delphi XE7 installed:

```powershell
python .\Tests\Run-RadioTests.py --mfpack-root D:\PROJECTS\MfPack --heos-cli-root D:\GitHub\FactoryX-HEOS-CLI
```

The script builds temporary fixture copies under the repository's
`Build\RadioTests`, and uses localhost port 1255 plus an automatically assigned
second port. Port 1255 must be free on the PC. It never opens the main form or
runs receiver discovery. Real service/account access and station audibility
still need a listening check on the selected receiver.

## Cached address and DHCP recovery

The main form reads `Receiver.ini` from
`%LOCALAPPDATA%\FactoryX\HEOSRemote`. It checks the saved IPv4 address on
HEOS port 1255 before deciding to scan. A reachable saved address bypasses SSDP
discovery; missing/invalid/unreachable addresses trigger one scan. A successful
scan matches the stored device UDN when available, updates the host edit and
saves the new IP/identity. A HEOS device is selectable even when AVR port 23 is
unavailable. Ambiguous/no-device results are shown in the status and log.

Radio is deferred until the receiver address is confirmed. It cannot use the
old DFM default while startup recovery runs. The API's socket TryConnect path
reports expected connection failures without throwing; the legacy constructor
retains its exception contract for direct callers.

`HeosReceiverRecoveryTests.dpr`, run by `Run-RadioTests.py`, checks INI restore,
the no-scan path, scan fallback, stable device identity after DHCP, saving the
new IP, and deferring Radio. Its discovery fixture never scans a real network.
It also observes first-chance Delphi exceptions in the process while connecting
to a closed localhost port: socket TryConnect and the async API return error
statuses with zero Delphi exceptions. Settings tests use an isolated test profile.

## Station artwork

Each browse/search station record retains the receiver's decoded `image_url`.
The DFM contains a right-hand artwork panel, TImage, selected-station label and
fallback status label. TImage uses proportional scaling, centring and stretch;
no layout is built in Pascal.

`HEOSRadioArtwork.pas` downloads HTTP/HTTPS URLs through WinInet using Windows
proxy/certificate handling. HTTP redirects are followed; HTTP failures do not
create a playback error. The worker bounds the response to 4 MiB, uses network
timeouts and a download time budget, and decodes PNG/JPEG/GIF/BMP by signature.
Graphic decoding runs off the GUI thread too. The GUI copies a completed graphic
only when it still belongs to the selected URL. Missing/unsupported artwork is
reported beside the empty preview. The worker never accesses a VCL control.

Selection requests are debounced for 150 ms. A single worker is active at a
time; selecting something else terminates the old work and retains only the
latest request. Hiding Radio leaves its timer running so completion and queued
console controls continue; application shutdown joins the bounded worker.

The delivered tests verify that Radio returns modelessly while the main console
and volume remain enabled, and that a console Stop waits for a pending station
request. `HeosRadioArtworkTests.dpr` uses a localhost HTTP fixture to check PNG
decoding without an extension, redirects, delayed responses, latest-selection
protection, missing artwork and HTTP failure. Win32 and Win64 checks passed.

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

The localhost regressions also verify URL validation, duplicate names, UTF-8
station persistence, service-refresh retention, exact URL transmission,
receiver-direct custom playback, removal without stopping and console Stop.

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

## Switching playback sources

MainForm queues each file, Windows audio, custom URL and catalog station request.
It sends HEOS Stop to the previous receiver and waits for the reply before starting
the selected source. The previous file server, capture and radio status monitor are
released during handover. Stop cancels pending starts. If Stop fails, the next
source is cancelled and the error appears in the console log.
Loading another file stops playback; press Play to start the selected file.
Browsing radio categories or selecting a station does not interrupt audio until Play.
