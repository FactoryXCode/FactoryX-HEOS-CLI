// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: Media Foundation - MFPack - Samples
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HeosPlaybackButtonTests.dpr
// Kind: Pascal Unit
// Release date: 30-10-2026
// Language: ENU
//
// Revision Version: 1.1.0.0
// Description: Regression checks for playlist button states during HEOS polling.
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
program HeosPlaybackButtonTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.SyncObjs, WinApi.Windows, Vcl.Forms, MainForm, Heos;

type
  TPendingRequest = class(THeosRequest)
  protected
    procedure Execute; override;
  end;

var
  ReleaseRequest: TEvent;

procedure TPendingRequest.Execute;
begin
  // Hold a request in flight without contacting a receiver.
  ReleaseRequest.WaitFor(INFINITE);
end;

procedure Require(Value: Boolean; const Text: string);
begin
  if not Value then
    raise Exception.Create(Text);
end;

procedure CheckButtons;
var
  Main: THEOSForm;
  Action: THeosAction;
  Cycle: Integer;
begin
  ReleaseRequest := TEvent.Create(nil, True, False, '');
  Main := THEOSForm.Create(nil);
  try
    Main.FQueue.Add('first.wav');
    Main.FQueue.Add('second.wav');
    Main.FQueueIndex := 0;
    Main.FQueueActive := True;
    Main.FPlaybackState := 'play';
    Main.UpdateStreamButtons;
    Require(Main.btnStreamWinAudio.Enabled and Main.btnNext.Enabled, 'Playlist controls initially disabled');
    for Cycle := 1 to 5 do
      for Action := Low(THeosAction) to High(THeosAction) do
        begin
          ReleaseRequest.ResetEvent;
          Main.FHeos := TPendingRequest.Create('127.0.0.1', Action);
          Main.FLastHeosAction := Action;
          Main.FHeos.Start;
          try
            Main.UpdateStreamButtons;
            if (Action = haGetState) then
              begin
                Require(Main.btnStreamWinAudio.Enabled and Main.btnNext.Enabled,
                        'Status polling disabled playlist buttons');
                Main.FQueueIndex := 1;
                Main.UpdateStreamButtons;
                Require(not Main.btnNext.Enabled, 'Next enabled at end of playlist');
                Main.btnLoop.Checked := True;
                Main.UpdateStreamButtons;
                Require(Main.btnNext.Enabled, 'Looping playlist cannot advance');
                Main.btnLoop.Checked := False;
                Main.FQueueIndex := 0;
                Main.FWaitingForCapture := True;
                Main.UpdateStreamButtons;
                Require(not Main.btnStreamWinAudio.Enabled and not Main.btnNext.Enabled,
                        'Capture startup no longer disables playback controls');
                Main.FWaitingForCapture := False;
                Main.StartStreamAction(2);
                Require(Main.FStreamActions.Count = 1, 'Click during poll was not queued');
                Main.FStreamActions.Clear;
                Main.FDesiredPlaybackState := '';
                Main.StreamActionTimer.Enabled := False;
              end
            else
              Require(not Main.btnStreamWinAudio.Enabled and not Main.btnNext.Enabled,
                      'Playback command no longer disables buttons');
          finally
            ReleaseRequest.SetEvent;
            Main.FHeos.WaitFor;
            FreeAndNil(Main.FHeos);
          end;
          Main.UpdateStreamButtons;
          Require(Main.btnStreamWinAudio.Enabled and Main.btnNext.Enabled,
                  'Playlist buttons not restored after request');
        end;
    Writeln('PASS repeated status polls preserve buttons; playback commands, capture, queue boundaries, loop and queued clicks remain correct.');
  finally
    ReleaseRequest.SetEvent;
    Main.Free;
    ReleaseRequest.Free;
  end;
end;

begin
  try
    CheckButtons;
  except
    on E: Exception do
      begin
        Writeln(E.ClassName + ': ' + E.Message);
        Halt(1);
      end;
  end;
end.