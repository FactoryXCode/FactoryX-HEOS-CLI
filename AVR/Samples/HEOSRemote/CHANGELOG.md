# HEOS Remote sample changes

## 1.1.13 — 1 November 2026

- Return expected stream connection and HTTP errors without raising debugger exceptions.
- Preserve WinINet error numbers and load their messages from wininet.dll.
- Retire unfinished URL checks off the UI thread when stopping, switching receiver or closing.

## 1.1.12 — 1 November 2026

- Add a DFM station popup for removing custom stations and setting logo URLs.
- Persist custom station artwork URLs and fit logos proportionally.
- Check custom HTTP URLs asynchronously before changing the current source.
- Reject webpages and HTTP errors with an explanation instead of waiting for HEOS playback.
- Discover a published site icon when a webpage is mistakenly entered as a stream.

## 1.1.11 — 31 October 2026

- Add background AVR capability discovery through `Avr.Capabilities` from the canonical API repository.
- Restore capabilities from an identity-based INI cache, refresh after receiver verification and retain cached data on errors.
- Keep unsupported features separate from temporary connection and tone-mode availability.
- Apply support flags and explanatory hints to zones, volume, mute, balance, tone, bass and treble.
- Filter unsupported AVR commands and finish single-zone status reads without waiting for Zone 2.
- Add Win32/Win64 parser, cache, delayed/error reply, source-change and VCL regression tests.

## 1.1.10 — 31 October 2026

- Serialize file, Windows audio, custom URL and catalog radio source changes in MainForm.
- Stop receiver playback and release the previous local stream before starting another source.
- Keep the selected station and receiver with the queued command; cancel pending starts on Stop.
- Loading another file stops the current source; a failed Stop prevents the next source starting.

## 1.1.9 — 31 October 2026

- Use a separate HEOS connection for read-only playback status.
- Reconnect that status client after unknown replies or query failures without replaying playback commands.
- Add a mock receiver that retains unknown state on the connection that sent Play.
- Validate the selected receiver's raw and parsed play state with a read-only live Delphi probe.

## 1.1.8 — 31 October 2026

- Continue checking after the initial 15-second buffering window; unknown state no longer clears radio mode or disables Stop.
- Confirm playback that starts later, and keep monitoring the receiver afterward.
- Reflect receiver-reported Stop and retain protection against stale status replies.
- Add late-start and continuous-monitoring regression checks.

## 1.1.7 — 31 October 2026

- Check receiver play state after station command acceptance, without disabling controls during status checks.
- Show separate accepted/loading, receiver-reported playing, and unconfirmed/error states.
- Report missing playback confirmation after 15 seconds, including unknown receiver state.
- Ignore late playback status replies after Stop or switching sources.
- Add confirmation, unknown-state timeout and stale-reply regression coverage.

## 1.1.6 — 31 October 2026

- Set Radio panel backgrounds explicitly in the DFM so Windows themes cannot paint light panels beneath white labels.
- Preserve the Name/URL fields, feedback, artwork and navigation contrast at runtime.
- Check loaded panel properties, field hit-testing and the exact reported HTTPS URL.

## 1.1.5 — 30 October 2026

- Show persistent Add station confirmation/error feedback directly below its Name and URL fields.
- Explain missing station names, invalid URLs, duplicate names and save failures without clearing the input.
- Confirm saving separately from testing playback; keep the feedback controls in the VCL DFM.
- Verify missing-name, invalid-URL, duplicate-name and success feedback in both architectures.

## 1.1.4 — 30 October 2026

- Add named custom radio stations using direct HTTP/HTTPS stream URLs.
- Save stations in a UTF-8 RadioStations.ini and show them under My stations.
- Play custom stations directly through the HEOS CLI API; remove saved entries without stopping playback.
- Keep manual station controls in the editable Radio VCL DFM.

## 1.1.3 — 30 October 2026

- Keep radio services visible when the HEOS account flag `available` is false.
- Restore anonymous TuneIn browsing/search and explain why Favorites search is disabled.
- Retain search-criteria errors in the browser status after root browsing.
- Add a regression for TuneIn returning `available=false`.

## 1.1.2 — 30 October 2026

- Made Radio modeless so the main console remains available for volume and AVR settings.
- Kept pending radio commands active when the browser is hidden.
- Serialized console source changes/Stop with in-flight Radio playback commands.
- Added the selected station's artwork/logo in a DFM-designed preview panel.
- Download and decode images off the GUI thread, with stale-selection protection and placeholders.
- Added modeless/volume/queued-Stop and localhost artwork regression tests for Win32/Win64.

## 1.1.1 — 30 October 2026

- Restore and verify the last confirmed IP from a per-user Receiver.ini.
- Scan for HEOS only if the cached address is missing, invalid or unreachable.
- Save the discovered current IP and device UDN, and match that device after DHCP changes.
- Defer Radio until startup address validation/recovery finishes.
- Allow HEOS radio when AVR port 23 is unavailable.
- Return expected initial connect failures as API status messages without first-chance socket exceptions.
- Add startup/DHCP/INI and first-chance-exception regression checks for both architectures.

## 1.1.0 — 30 October 2026

- Added the DFM-designed Internet Radio window and main toolbar Radio button.
- Added receiver-advertised services, category browsing, search and paging.
- Added direct station playback and Stop using THeosClient/THeosCommands from
  `D:\GitHub\FactoryX-HEOS-CLI`, with background requests and visible errors.
- Coordinated radio playback with local file, playlist and Windows streaming.
- Added live radio elapsed time and a Play file action to return to a selection.
- Added mock-receiver regression checks for both Win32 and Win64.
- Added a configurable HeosCliRoot build property for the new API dependency.

The existing standalone file/playlist and AVR features are retained. This update
does not change the separate RDJ Pro integration or the GitHub sample copy.
