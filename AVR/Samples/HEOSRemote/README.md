# HEOS Remote AVR sample

Minimum suported Delphi version: XE7.  
  
This is the complete Delphi VCL HEOS Remote application, including playlist editor, RDJ-derived library support, native audio streaming and AVR control code. 
  
The API-based copy is available in [Examples/HEOSRemoteApi](../../../Examples/HEOSRemoteApi/README.md), using `THeosClient` and `TAvrClient`.  
  
## Build
  
This application requires MfPack's `src` folder and Delphi XE7 or higher up to 13.1 to compile.  
Its custom `TDn` controls are included under `Controls`.  
  
For IDE builds, set the `MfPackRoot` environment variable before starting Delphi, or set that MSBuild property when invoking `HEOSRemote.dproj`. 
Its search path uses `Controls` and `..\MfPack\src`. No machine-specific project paths are needed.

The application's longer development notes are preserved in `APP-NOTES.md` and `RDJ-SOURCE-NOTES.md`. 
Main Zone and Zone 2, tone controls and channel levels use the AVR protocol; HEOS playback uses its separate CLI. 
Please note that availability depends on the receiver's settings and firmware versions. 

**Test environment**  
A Denon AVR-X2700H DAB receiver has been used for building and testing the project.

Project: FactoryX - HEOS CLI  
Project location:  
https://github.com/FactoryXCode/FactoryX-HEOS-CLI  
https://github.com/FactoryXCode/MfPack  
  
First release date: 13/08/2026  
Final release date: 29/10/2026  
  
Copyright © FactoryX. All rights reserved.
