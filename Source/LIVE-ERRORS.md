# Live HEOS failure handling

Use checked results for expected device and environment failures, as in the MfPack samples. Do not raise an exception to leave an ordinary connection, validation, capture or encoder error path.

- `THeosConnection.TryConnect` returns false, a nil connection and endpoint/error text on failure.
- `TrySend`, `TryReadLine`, `TrySocketReady`, `TryReadHeader` and `TryLocalAddressFor` return status and an error string. A normal `TryReadLine` polling timeout succeeds with an empty line and preserves partial input. A disconnect or invalid reply returns false.
- `THeosClient` and `TAvrClient` deliver runtime failures as their existing error messages. A timed-out or partially transmitted command is not replayed. `DeliveryUnknown` retains the send uncertainty.
- Queue saturation returns request ID zero (or an empty AVR batch). Check this before waiting for completion. A full notification queue can discard the uncorrelated queue-rejection message while preserving accepted command completions.
- `TRdjHeosOutput.Start` and `StartBroadcast` return an HRESULT. Check it before claiming startup succeeded and obtain details from `ErrorText`.
- `Heos.Files` loads and saves INI settings using checked OS I/O. A failed replacement leaves the previous settings file intact. RDJ's shared setup file is written as UTF-16 for compatibility with the Windows INI API.

Keep `try/finally` resource cleanup and protective handlers for unexpected library errors. The legacy throwing socket entry points and command-definition/configuration validation remain available for source compatibility; live operations in the supplied clients use the checked paths.

Run `Tests/Run-LiveFailureTests.ps1 -MfPackRoot <MfPack root>` to exercise local receiver failures, malformed responses, timeout/disconnect, port conflicts, capture setup failure, RDJ startup failure and locked settings files on Win32/Win64. The test observes first-chance Delphi exceptions and requires zero for those expected failure paths. It uses synthetic receivers and does not capture or play live audio.

**Copyright (c) FactoryX. All rights reserved.**