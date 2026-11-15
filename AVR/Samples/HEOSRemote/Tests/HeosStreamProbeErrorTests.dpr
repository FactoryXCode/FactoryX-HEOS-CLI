// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: Media Foundation - MFPack - Samples
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HeosStreamProbeErrorTests.dpr
// Kind: Pascal Unit
// Release date: 30-10-2026
// Language: ENU
//
// Revision Version: 1.1.2.0
// Description: Exception-free URL errors and asynchronous retirement checks.
//
// Company: FactoryX
// Intiator(s): Tony (maXcomX), Carmen (carmenh).
// Contributor(s): Tony Kalf (maXcomX), Carmen (carmenh).
//
//------------------------------------------------------------------------------
// CHANGE LOG
// Date       Person              Reason
// ---------- ------------------- ----------------------------------------------
// 24/08/2026 All                 Moby release  SDK 10.0.28000.2705  (Windows 11)
//------------------------------------------------------------------------------
//
// Remarks: Requires Windows 10 or higher.
//
// Related objects: RDJ Pro
// Related projects: MfPackX400
// Known Issues: -
//
// Compiler version: 23 up to 35
// SDK version: 10.0.28000.2705
//
// Todo: -
//
// =============================================================================
// Source: FactoryX.Code - RDJ Pro
// =============================================================================
//
// LICENSE
//
// The contents of this file are subject to the Mozilla Public License
// Version 2.0 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// https://www.mozilla.org/en-US/MPL/2.0/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//
// Non commercial users may distribute this sourcecode provided that this
// header is included in full at the top of the file.
// Commercial users are not allowed to distribute this sourcecode as part of
// their product.
//
//==============================================================================
program HeosStreamProbeErrorTests;

{$APPTYPE CONSOLE}

uses

  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.Diagnostics,
  HEOSRadioStreamProbe;

var
  RaisedExceptions: Integer;

function ObserveException(Info: Pointer): Longint; stdcall;
begin

  if (PDWORD(PPointer(Info)^)^ = $0EEDFADE) then
    InterlockedIncrement(RaisedExceptions);

  Result := 0;
end;

function InstallObserver(First: ULONG; Handler: Pointer): Pointer; stdcall;
  external 'kernel32.dll' name 'AddVectoredExceptionHandler';
function RemoveObserver(Handler: Pointer): ULONG; stdcall;
  external 'kernel32.dll' name 'RemoveVectoredExceptionHandler';

procedure Require(Value: Boolean; const Text: string);
begin

  if not Value then
    raise Exception.Create(Text);
end;

procedure CheckFailure(const Url: string; const Expected: string);
var
  Probe: THeosRadioStreamProbe;

begin

  Probe := THeosRadioStreamProbe.Create(Url);

  try
    Probe.Start();
    Probe.WaitFor();
    Require(Pos(Expected, Probe.ErrorText) > 0,
            'Expected ' + Expected + ', received: ' + Probe.ErrorText);
    Require(RaisedExceptions = 0,
            'An expected URL failure raised a first-chance Delphi exception');
  finally
    Probe.Free();
  end;
end;

procedure CheckResolved(const Url, ExpectedUrl, ExpectedLogo: string);
var
  Probe: THeosRadioStreamProbe;

begin

  Probe := THeosRadioStreamProbe.Create(Url);
  try
    Probe.Start();
    Probe.WaitFor();
    Require(Probe.ErrorText = '', 'Website audio lookup failed: ' + Probe.ErrorText);
    Require(Probe.ResolvedUrl = ExpectedUrl, 'Incorrect resolved audio URL: ' + Probe.ResolvedUrl);
    Require(Probe.LogoUrl = ExpectedLogo, 'Website logo was lost during audio lookup');
    Require(RaisedExceptions = 0, 'Website lookup raised a Delphi exception');
  finally
    Probe.Free();
  end;
end;

var
  Website: string;
  Base: string;
  Observer: Pointer;
  Probe: THeosRadioStreamProbe;
  Clock: TStopwatch;

begin

  Observer := InstallObserver(1, @ObserveException);

  try
    try
      Require(Assigned(Observer), 'Cannot install first-chance exception observer');
      Base := 'http://127.0.0.1:' + ParamStr(1);
      CheckFailure('http://127.0.0.1:' + ParamStr(2) + '/live', 'WinINet error');
      CheckFailure(Base + '/missing', 'HTTP 404');
      CheckFailure(Base + '/web', 'webpage');
      Writeln('PASS unreachable stream, HTTP 404 and webpage without first-chance Delphi exceptions');
      Website := 'http://127.0.0.1:' + ParamStr(3);
      CheckResolved(Website + '/', Website + '/radio/live.aac', Website + '/logo-small');
      CheckResolved(Website + '/redirect-site', Website + '/radio/live.aac', Website + '/logo-small');
      CheckFailure(Website + '/bad-type', 'did not return AAC');
      CheckFailure(Website + '/missing-aac', 'HTTP 404');
      CheckFailure(Website + '/html-aac', 'webpage');
      CheckResolved(Base + '/live?direct', Base + '/live?direct', '');
      Writeln('PASS website AAC resolution, redirect, icon preservation, missing AAC, wrong MIME and bounded HTML fallback');

      Probe := THeosRadioStreamProbe.Create(Base + '/slow-probe');
      Probe.Start();
      Sleep(50);
      Clock := TStopwatch.StartNew;
      THeosRadioStreamProbe.Release(Probe);
      Require(not Assigned(Probe), 'Retired probe remained attached');
      Require(Clock.ElapsedMilliseconds < 100, 'Retiring an unfinished request blocked the caller');
      Sleep(1200);
      Require(RaisedExceptions = 0, 'Retired probe raised a Delphi exception');
      Writeln('PASS nonblocking retirement of unfinished URL request');
    except
      on E: Exception do
        begin
          Writeln(E.ClassName + ': ' + E.Message);
          ExitCode := 1;
        end;
    end;
  finally
    RemoveObserver(Observer);
  end;
end.
