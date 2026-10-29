# HEOS CLI Remote sample

Open `MfHeosRemote.dproj` in Delphi and build Win32 or Win64. 
The form layout and all event bindings are stored in `frmHeosRemote.dfm`, using standard VCL controls. 
The remote uses the repository's HEOS CLI units directly. 

1. Enter the receiver's IPv4 address and click **Connect**. 
2. Select a player from the list. The sample reads its state, volume, mute and now-playing information.
3. Use Play, Pause, Stop, Previous, Next, the volume slider and Mute to control the player. 
4. Click **Refresh** to reload the player list and selected-player status. **Disconnect** releases the CLI client. 

Play resumes the player's existing media/queue. This sample does not host audio files or upload music. 
Progress follows the receiver's events and is display-only. HEOS volume uses the CLI's 0–100 scale. 
Zone power and AVR tone controls use a different protocol and are outside this example.

`DispatchTimer` calls `THeosClient.Dispatch` every 50 ms, so replies and event handlers run on the VCL thread. 
Volume writes are delayed for 200 ms and coalesced while a previous write is outstanding. 
IDs are stored as signed `Int64` values. Incoming player events are filtered by the selected ID. 
The log clears after 300 lines. Timers are disabled before freeing the client, outside any callback.

From the repository root, `Build.ps1 -RunTests` builds this sample, the console demo and the simulator tests on both platforms. 

NOTES:  

* This release is updated for compiler version 28.0 up to 37.0.
* SDK version 10.0.28000.2705 (Win 11)
* Requires Windows 10 or later.
* Minimum supported MfPack version: 4.0.0

&#x20; 

Project: FactoryX - HEOS CLI - Samples  

&#x20; 

Project location: https://github.com/FactoryXCode/FactoryX-HEOS-CLI  

&#x20; 

First release date: 13/08/2026  
Final release date: 28/10/2026  

&#x20; 

Copyright © FactoryX. All rights reserved.
