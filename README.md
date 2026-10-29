# FactoryX HEOS CLI for Delphi

**HEOS CLI**

FactoryX HEOS CLI provides Delphi APIs for controlling HEOS-enabled audio devices from Denon and Marantz.
It supports player control, volume and mute, music browsing, queues, playlists, grouping and receiver events.
The APIs use native Windows sockets; no Indy or third-party JSON libraries are needed.

**AVR control**

The AVR API adds receiver power, Main Zone and Zone 2 activation, input selection, volume, mute, balance and tone controls.
It also provides surround mode and Dynamic EQ commands.
HEOS playback and AVR settings use separate protocols, with availability depending on the receiver, firmware and music service.

**Remote samples**

The API's have the following samples:
- A simple HEOS remote demonstrates the CLI with standard Delphi VCL components.
- The complete HEOS Remote application adds playlist editing, RDJ Pro playlist import, file streaming and Windows audio streaming.
Its controls and form layouts are included for editing in the Delphi IDE.

.[](https://github.com/FactoryXCode/FactoryX-HEOS-CLI/blob/main/Pic/HEOSRemote_s.png)

**Note:**
Before opening the complete HEOS Remote application in the form designer, install its included custom controls and configure the MfPack source path.
See the [API application build instructions](Examples/HEOSRemoteApi/README.md).

## Dependencies for Delphi development

- Delphi XE7 up to and including Delphi 13.1.
- Windows 10 22H2 or higher; Win32 and Win64 targets.
- The reusable APIs and standard VCL sample require no MfPack installation.
- [**MfPack**](https://github.com/FactoryXCode/MfPack) is required for the complete HEOS Remote application sample.

## What's included

- **HEOS CLI API** — asynchronous commands, replies and events in `Source`.
- **AVR API** — receiver and zone controls in `AVR/Source`.
- **Standard VCL remote** — [MfHeosRemote](Examples/MfHeosRemote/README.md).
- **Complete HEOS Remote app using the APIs** — [HEOSRemoteApi](Examples/HEOSRemoteApi/README.md).
- **Original application snapshot** — [AVR sample](AVR/Samples/HEOSRemote/README.md).
- **Console examples and tests** — read-only examples and local receiver simulators.

## Documentation

- [Technical paper](TECHNICAL-PAPER.md) — architecture, API examples, protocols, build instructions and validation.
- [HEOS command catalog](COMMANDS.md).
- [AVR API documentation](AVR/README.md).
- [License](LICENSE) and the FactoryX notices in each source file.

---

**(c) FactoryX. All rights reserved. **
