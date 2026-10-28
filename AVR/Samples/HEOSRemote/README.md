# HEOS Remote AVR sample

Minimum suported Delphi version: XE7.

This is the complete Delphi VCL HEOS Remote application, including its DFM forms, custom controls, playlist editor, RDJ-derived library support, native audio streaming and AVR control code. It is copied from the working application; the original project is unchanged. Receiver databases, INI files, credentials, compiled output and local IDE settings are not included.

The original application currently uses its own `HEOSTransport.pas` and `Heos.pas` adapters. The reusable APIs are in `AVR/Source` and the repository's top-level `Source`; this source snapshot has not been silently migrated to them. `AVR/Samples/AvrCliDemo.dpr` demonstrates the new AVR API directly.

## Build

This application requires MfPack's `src` folder as well as Delphi XE7 or higher up to 13.1. Its custom `TDn` controls are included under `Controls`. For form editing, install the included `Controls/HEOSControls.dproj` package in the Win32 Delphi IDE if these classes are not installed already.

```powershell
.\Build.ps1 -MfPackRoot 'D:\PROJECTS\MfPack' -Platform Win32
.\Build.ps1 -MfPackRoot 'D:\PROJECTS\MfPack' -Platform Win64
```

Executables and DCUs go under the repository's `Build` directory. For IDE builds, set the `MfPackRoot` environment variable before starting Delphi, or set that MSBuild property when invoking `HEOSRemote.dproj`. Its search path uses `Controls` and `$(MfPackRoot)\src` and contains no machine-specific project paths.

The application's longer development notes are preserved in `APP-NOTES.md` and `RDJ-SOURCE-NOTES.md`. Main Zone and Zone 2, tone controls and channel levels use the AVR protocol; HEOS playback uses its separate CLI. Availability depends on the receiver's settings and firmware. No receiver is contacted by building the project.
