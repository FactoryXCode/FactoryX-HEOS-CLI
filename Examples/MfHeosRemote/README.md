# MfPack HEOS CLI Remote sample

Open `MfHeosRemote.dproj` in Delphi XE7 and build Win32 or Win64. The form layout and all event bindings are stored in `frmHeosRemote.dfm`, using standard VCL controls. The code follows the MfPack sample format. The remote uses the repository's HEOS CLI units directly; a Media Foundation session is not needed for receiver control.

1. Enter the receiver's IPv4 address and click **Connect**.
2. Select a player from the list. The sample reads its state, volume, mute and now-playing information.
3. Use Play, Pause, Stop, Previous, Next, the volume slider and Mute to control that player.
4. Click **Refresh** to reload the player list and selected-player status. **Disconnect** releases the CLI client.

Play resumes the player's existing media/queue. This sample does not host audio files or upload music. Progress follows the receiver's events and is display-only. HEOS volume uses the CLI's 0–100 scale. Zone power and AVR tone controls use a different protocol and are outside this example.

`DispatchTimer` calls `THeosClient.Dispatch` every 50 ms, so replies and event handlers run on the VCL thread. Volume writes are delayed for 200 ms and coalesced while a previous write is outstanding. IDs are stored as signed `Int64` values. Incoming player events are filtered by the selected ID. The log clears after 300 lines. Timers are disabled before freeing the client, outside any callback.

From the repository root, `Build.ps1 -RunTests` builds this sample, the console demo and the simulator tests on both platforms. Source and license notices remain in the original FactoryX headers.