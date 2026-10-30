# RDJ Pro editor integration  
  
Source: `..\MfPack\Samples\MFRDJ Samples\MfRdjPro`.  
  
  
The following local units are byte-for-byte copies: `RDJ.PlaylistTypes`,
`RDJ.PlaylistDb`, `RDJ.TrackLibrary`, `RDJ.PlaylistManager`,
`RDJ.LibraryScanner`, `RDJ.TrackQuality`, `RDJ.TagReader`, `RDJ.TagWriter`,
`RDJ.FilenameParser`, `RDJ_Common`, `RDJ_NetWorkStationsScanner`.

`DenonPlaylistForm.pas/.dfm` comes from `frmPlaylistEditor.pas/.dfm`.
`RefreshLibraryGrid` is unchanged: an empty search exits before querying;
nonempty searches request matching summary rows. The editor has no calls to
`GetAllTracks` or `SearchTracks`.

Necessary local adaptations:

- Standard VCL `TButton` replaces `TMPxpButton` in the editor, tag editor and
  Pro file browser. Custom button styling/glyph properties are removed from
  their DFM files. Min/Max/Close text replaces glyph-only title-bar buttons.
  Original form layout, component names and event handlers are retained.
- The editor unit is named `HEOSPlaylistForm`; its actual form class is
  `THEOSPlaylistEditor`. The `PlaylistEditor` instance name agrees across
  Pascal, DFM and project metadata. No form class alias is used.
- `HEOSRdjBridge` replaces the Pro MDI/deck dependency and exposes one channel
  connected to the main form's existing file/playlist playback queue.
- The editor creates its bridge, supports a separate database path for tests,
  and exposes load/play callbacks and the main form's close/save check.
- Open File uses Pro's existing `BrowseLWFileEx` helper, which owns the dialog,
  instead of relying on the Pro application's auto-created global form.
- Form destruction detaches callbacks and waits for active scan workers before
  freeing their owners. Library progress queues are associated with their
  thread so destroying the thread removes pending callbacks.
- The application frees its main form before invoking Pro's FireDAC/SQLite
  shutdown helper. The Delphi project copies the platform's SQLite DLL on build.

Data stays in this application's `Data\RDJLibrary.db` beside its EXE.
No existing Pro database is copied or changed.

Validation: Win32 and Win64 MSBuild; existing playlist/discovery/browser checks;
5,000-track database fixture testing empty opening/clearing, matching searches,
playlist edits/order/persistence, Denon routing, and streaming the three DFM
forms with standard controls on both platforms. Receiver playback was not started
by these tests.
  
  
Project: FactoryX - HEOS CLI  
  
Project location:    
https://github.com/FactoryXCode/FactoryX-HEOS-CLI  
  
First release date: 13/08/2026  
Final release date: 29/10/2026  
  
Copyright © FactoryX. All rights reserved.
