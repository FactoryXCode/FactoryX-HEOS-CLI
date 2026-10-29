# HEOS Remote API sample

The complete HEOS Remote VCL application using the repository's HEOS CLI and AVR APIs. 
Copied from the working application with its DFM forms, TDn controls, playlist editor, RDJ Pro playlist import, file browser, file streaming and Windows audio streaming.

`Heos.pas` adapts the existing background playback requests and progress monitor to `THeosClient`, `THeosCommands` and parsed `THeosMessage` replies/events. 
It selects the player by receiver IP and uses the single-player fallback only when unambiguous. Commands use the API's parameter encoding and request IDs.

`HEOSTransport.pas` adapts receiver requests to `TAvrClient` and typed `TAvrCommands`, retaining the form's existing queue and confirmation handling. 
The channel-list query uses the API's raw extension and waits for `CVEND`. 
A failed command ends the request without sending its remaining commands.

Native sockets in the sample still serve audio, probe availability and perform SSDP discovery. 
Seeking uses UPnP AVTransport because HEOS CLI has no seek command. 
These functions are separate from the HEOS and AVR control APIs.

## Open and build

Requires Delphi XE7 or later, Windows 10 and later, and [MfPack](https://github.com/FactoryXCode/MfPack). 
Install the included `Controls/HEOSControls.dproj` in the Win32 IDE before opening the form designer, unless these TDn components are already installed. 
Set the `MfPackRoot` environment variable to your MfPack folder before starting Delphi, then open `HEOSRemote.dproj`.

```powershell
.\Build.ps1 -MfPackRoot 'D:\PROJECTS\MfPack' -Platform Win32
.\Build.ps1 -MfPackRoot 'D:\PROJECTS\MfPack' -Platform Win64
```

Output goes to `Build/<platform>/HEOSRemoteApi`. 
The project references `../../Source` and `../../AVR/Source` directly; it does not bundle private copies of the reusable APIs. 
The repository's main build remains independent of MfPack; use this sample's build script for the full app.

Enter your receiver IP. If startup cannot connect, the app searches for HEOS devices on the local network, checks AVR control availability, and asks you to select when several receivers are found. 
Starting the app reads settings and does not activate a zone. Configure the receiver's network control for access while in standby.

Your original application and the original [AVR sample snapshot](../../AVR/Samples/HEOSRemote/README.md) remain available. 
Longer inherited development notes are in `APP-NOTES.md` and `RDJ-SOURCE-NOTES.md`.

Project: FactoryX - HEOS-CLI 
Project location: FactoryXCode  
  
https://github.com/FactoryXCode/FactoryX-HEOS-CLI  
  
First release date: 13/08/2026  
Final release date: 29/10/2026  
  
Copyright © FactoryX. All rights reserved.
