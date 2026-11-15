// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: Media Foundation - MFPack - Samples
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HeosToneRecoveryTests.dpr
// Kind: Pascal Unit
// Release date: 24-01-2026
// Language: ENU
//
// Revision Version: 1.1.0.0
// Description: Main remote GUI.
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
program HeosToneRecoveryTests;

{$APPTYPE CONSOLE}

uses

  System.SysUtils,
  System.Classes,
  System.Diagnostics,
  System.StrUtils,
  WinApi.Windows,
  Vcl.Forms,
  MainForm,
  HEOSTransport;

type

  TFailedToneRequest = class(TDenonRequest)
  protected
    procedure Execute(); override;
  end;


type

  PObservedRecord = ^TObservedRecord;
  TObservedRecord = record
    Code: Cardinal;
  end;

  PObservedPointers = ^TObservedPointers;
  TObservedPointers = record
    ExceptionRecord: PObservedRecord;
    ContextRecord: Pointer;
  end;

var
  RaisedExceptions: Integer;

function AddVectoredExceptionHandler(First: Cardinal; Handler: Pointer): Pointer; stdcall;
  external 'kernel32.dll';
function RemoveVectoredExceptionHandler(Handler: Pointer): Cardinal; stdcall;
  external 'kernel32.dll';

function ObserveException(Info: PObservedPointers): LongInt; stdcall;
begin

  if (Info.ExceptionRecord.Code = $0EEDFADE) then
    InterlockedIncrement(RaisedExceptions);

  Result := 0;
end;


procedure TFailedToneRequest.Execute();
begin

  FError := 'Connected, but no status reply was received.';
end;


procedure Require(Value: Boolean;
                  const Text: string);
begin

  if not Value then
    raise Exception.Create(Text);
end;


procedure WaitForZone(Main: THEOSForm);
var
  Clock: TStopwatch;

begin

  Clock := TStopwatch.StartNew();

  while Main.FZoneRequest do
    begin
      CheckSynchronize(0);
      Require(Clock.ElapsedMilliseconds < 6500, 'Zone request did not complete');
      Sleep(10);
    end;
end;


procedure WaitForTone(Main: THEOSForm);
var
  Clock: TStopwatch;

begin

  Clock := TStopwatch.StartNew();

  repeat
    CheckSynchronize(0);

    if Main.VolumeTimer.Enabled then
      Main.VolumeTick(nil);

    Require(Clock.ElapsedMilliseconds < 12000, 'Tone recovery did not complete');
    Sleep(10);
  until Main.FToneKnown and not Main.FToneRequest and
        not Main.FToneReadPending and not Main.FTonePending;
end;


procedure CheckRecovery();
var
  Main: THEOSForm;
  Worker: TDenonRequest;
  Attempt: Integer;

begin

  Main := THEOSForm.Create(nil);

  try
    Main.edHost.Text := '127.0.0.1';
    Main.FPowerText := 'On';
    Main.FZone2PowerText := 'Standby';
    Main.FVolumeText := '50.0%';
    Main.FToneKnown := True;
    Main.FToneEnabled := False;
    Main.FToneMode := 'STEREO';
    Main.UpdateToneDisplay();
    Require(Main.chkTone.Enabled, 'Initial known tone state is unavailable');

    Main.QueueZoneChange(True, False);
    Require(not Main.chkTone.Enabled, 'Tone remained available while Main Zone was turning off');
    WaitForZone(Main);
    Require((Main.FPowerText = 'Standby') and not Main.FToneKnown,
            'Standby retained stale tone state');
    Require(not Main.chkTone.Enabled and not Main.chkTone.Checked,
            'Standby did not disable and clear the tone checkbox');

    Main.QueueZoneChange(True, True);
    WaitForZone(Main);
    Require((Main.FPowerText = 'On') and not Main.FToneKnown and Main.FToneReadPending,
            'Main Zone On reused the old tone state');
    Require(Main.FToneReadReadyAt > GetTickCount64,
            'Tone was queried immediately after Main Zone power acknowledgement');
    Require(not Main.chkTone.Enabled, 'Tone is available before a fresh read');

    Worker := Main.FWorker;
    Main.StartToneRequest();
    Require((Main.FWorker = Worker) and not Main.FToneRequest,
            'Warm-up deferral started a receiver request');
    Main.chkTone.Checked := True;
    Main.ToneClick(nil);
    Require(not Main.FTonePending, 'A click during warm-up queued an unsafe tone write');

    // The mock drops the first read to simulate a still-starting DSP.
    Main.FToneReadReadyAt := 0;
    WaitForTone(Main);
    Require(Main.chkTone.Enabled and not Main.chkTone.Checked,
            'Delayed receiver read did not restore the actual tone state');
    Require(Main.FToneReadAttempts = 0, 'Successful read did not reset retries');

    // The mock applies this write but drops its replies. Read back the state
    // instead of replaying the write after an uncertain result.
    Main.chkTone.Checked := True;
    Main.ToneClick(nil);
    Main.VolumeTick(nil);
    WaitForTone(Main);
    Require(Main.FToneEnabled and Main.chkTone.Checked and Main.tbBass.Enabled,
            'Read-back did not reconcile an uncertain Tone On request');

    Main.chkTone.Checked := False;
    Main.ToneClick(nil);
    Main.VolumeTick(nil);
    WaitForTone(Main);
    Require(not Main.FToneEnabled and not Main.chkTone.Checked and not Main.tbBass.Enabled,
            'Tone Off did not preserve the receiver-confirmed state');
    Writeln('PASS Main Zone cycle, warm-up gating, silent initial read, read-only recovery and tone toggle confirmation');

    // Exhaustion is tested without another series of network timeouts.
    Main.FToneKnown := False;
    Main.FTonePending := True;
    Main.FDesiredToneEnabled := True;

    for Attempt := 1 to 3 do
      begin
        FreeAndNil(Main.FWorker);
        Main.FWorker := TFailedToneRequest.Create('127.0.0.1', []);
        Main.FToneRequest := True;
        Main.FToneReadAttempts := Attempt;
        Main.FToneReadPending := False;
        Main.FWorker.Start();
        Main.FWorker.WaitFor();
        Main.RequestFinished(Main.FWorker);

        if (Attempt < 3) then
          Require(Main.FToneReadPending, 'Transient read failure was not retried')
        else
          Require(not Main.FToneReadPending and not Main.FTonePending,
                  'Failed reads continued beyond the retry limit');
      end;

    Require(not Main.chkTone.Enabled and ContainsText(Main.lblToneStatus.Caption, 'Read status'),
            'Exhausted recovery left tone enabled or claimed it was still reading');
    Main.FToneReadPending := True;
    Main.ParseStatus('ZMOFF');
    Require(not Main.FToneReadPending and not Main.FToneKnown,
            'Standby did not cancel scheduled tone recovery');
    Main.FPowerText := 'On';
    Main.FToneKnown := True;
    Main.FToneMode := 'PURE DIRECT';
    Main.UpdateToneDisplay();
    Require(not Main.chkTone.Enabled, 'Direct mode no longer blocks tone');
    Main.FToneMode := 'STEREO';
    Main.FDynamicEq := True;
    Main.UpdateToneDisplay();
    Require(not Main.chkTone.Enabled, 'Dynamic EQ no longer blocks tone');
    Main.FInputText := 'CD';
    Main.FToneReadAttempts := 3;
    Main.ParseStatus('SINET');
    Require(not Main.FToneKnown and Main.FToneReadPending and
            (Main.FToneReadAttempts = 0) and (Main.FToneMode = '') and not Main.FDynamicEq,
            'Input change did not invalidate old tone-mode state and reset recovery');
    Writeln('PASS bounded retries, pending-write cancellation, standby cancellation, Direct mode, Dynamic EQ and input-change recovery');

  finally
    Main.Free;
  end;
end;


var
  Observer: Pointer;

begin

  try
    Observer := AddVectoredExceptionHandler(1, @ObserveException);
    Require(Observer <> nil, 'Cannot install exception observer');

    try
      CheckRecovery();
      Require(RaisedExceptions = 0, 'Tone recovery raised Delphi exceptions');
      Writeln('PASS zero first-chance Delphi exceptions during Tone recovery');

    finally
      RemoveVectoredExceptionHandler(Observer);
    end;

  except
    on E: Exception do
      begin
        Writeln(E.ClassName + ': ' + E.Message);
        Halt(1);
      end;
  end;
end.