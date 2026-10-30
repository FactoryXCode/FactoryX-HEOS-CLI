# MfPack HEOS CLI Remote sample

Open `MfHeosRemote.dproj` in Delphi XE7 and build Win32 or Win64. The form layout and all event bindings are stored in `frmHeosRemote.dfm`, using standard VCL controls. The code follows the MfPack sample format. The remote uses the repository's HEOS CLI units directly; a Media Foundation session is not needed for receiver control.

1. Click **Find HEOS**, or leave the IP empty and click **Connect**, to discover HEOS devices. A single device is connected automatically; select a device in the list when several are found. You can also enter the receiver's IPv4 address and click **Connect**. Failed connections try discovery once.
2. Select a player from the list. The sample reads its state, volume, mute and now-playing information.
3. Click **Browse...** to choose an audio file, then **Play** to stream it from your PC. **Pause** and **Play** pause/resume it; **Stop** stops it. Play after Stop starts the selected file again. Previous/Next control the receiver's existing queue.
4. Click **Refresh** to reload the player list and selected-player status. **Disconnect** releases the CLI client.

Without a selected file, Play resumes the player's existing media/queue. With a selected file, a native HTTP server serves only that file at a generated URL, and `THeosCommands.PlayUrl` starts it on the selected player. The PC address follows the route to that player; Windows allocates an available listening port. Keep the app open while streaming, and allow the app through Windows Firewall on your private network if the receiver cannot fetch the URL. Files are sent unchanged; supported codecs depend on the HEOS device. No transcoding, Indy or MfPack installation is required. Progress follows the receiver's events and is display-only. HEOS volume uses the CLI's 0–100 scale. Zone power and AVR tone controls use a different protocol and are outside this example.

`DispatchTimer` calls `THeosClient.Dispatch` every 50 ms, so replies and event handlers run on the VCL thread. Volume writes are delayed for 200 ms and coalesced while a previous write is outstanding. IDs are stored as signed `Int64` values. Incoming player events are filtered by the selected ID. The log clears after 300 lines. Timers are disabled before freeing the client, outside any callback.

From the repository root, `Build.ps1 -RunTests` builds this sample, the console demo and the simulator tests on both platforms. Source and license notices remain in the original FactoryX headers.
Discovery runs on a background thread using HEOS SSDP advertisements and checks CLI port 1255. It supports HEOS devices from Denon and Marantz, including speakers; AVR port 23 is not required. It searches the local IPv4 network interfaces. If multicast is blocked or the device is unavailable, enter its IP manually or retry Find HEOS. Disconnect cancels discovery.
