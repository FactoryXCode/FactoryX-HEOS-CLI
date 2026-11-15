// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: Media Foundation - MFPack - Samples
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HeosPlaylistAdvanceTests.dpr
// Kind: Pascal Unit
// Release date: 30-10-2026
// Language: ENU
//
// Revision Version: 1.1.0.0
// Description: Regression checks for playlist advancement after failed HEOS status reads.
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
program HeosPlaylistAdvanceTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Vcl.Forms,
  MainForm,
  Heos;

type
  TCompletedRequest = class(THeosRequest)
  protected
    procedure Execute(); override;
  end;


procedure TCompletedRequest.Execute();
begin
  // Test replies are supplied directly, without connecting to a receiver.
end;


procedure Require(Value: Boolean;
                  const Text: string);
begin
  if not Value then
    begin
      Writeln('FAIL: ' + Text);
      Halt(1);
    end;
end;


procedure Reply(Main: THEOSForm;
                const State: string;
                const ErrorText: string);
begin
  FreeAndNil(Main.FHeos);
  Main.FHeos := TCompletedRequest.Create('127.0.0.1', haGetState);
  Main.FHeos.FPlayState := State;
  Main.FHeos.FError := ErrorText;
  Main.FLastHeosAction := haGetState;
  Main.FHeos.Start();
  Main.FHeos.WaitFor();
  Main.HeosFinished(Main.FHeos);
end;


procedure CheckAdvance(Shuffle: Boolean;
                       AutoNext: Boolean;
                       Loop: Boolean;
                       Index: Integer;
                       PollFailure: Boolean);
var
  Main: THEOSForm;
  I: Integer;
  NextIndex: Integer;
  NextFile: string;

begin
  Main := THEOSForm.Create(nil);
  try
    // Hold source commands in the normal action queue for inspection.
    Main.FProcessingStreamActions := True;
    for I := 1 to 4 do
      Main.FQueue.Add(IncludeTrailingPathDelimiter(ParamStr(1)) + IntToStr(I) + '.wav');
    Main.btnShuffle.Checked := Shuffle;
    Main.btnLoop.Checked := Loop;
    Main.chkPlayListAutoNext.Checked := AutoNext;
    if Shuffle then
      Main.ShuffleUpcoming(Index + 1);
    Main.FQueueIndex := Index;
    Main.FQueueActive := True;
    Main.FQueueIsPlaylist := True;

    Reply(Main, 'stop', '');
    Require(not Main.FQueueNextPending, 'Startup Stop advanced an unconfirmed track');
    Reply(Main, 'play', '');
    if PollFailure then
      begin
        Reply(Main, '', 'HEOS response timed out');
        Require(Main.FQueueActive, 'Status timeout disabled playlist advancement');
        Require(Main.FQueueSawPlaying, 'Status timeout lost confirmed playback');
        Require(Main.FPlaybackState = 'play', 'Status timeout changed playback state');
        Require(not Main.FQueueNextPending, 'Status timeout advanced the playlist');
      end;

    NextIndex := Index + 1;
    if Loop and (NextIndex = Main.FQueue.Count) then
      NextIndex := 0;
    if NextIndex < Main.FQueue.Count then
      NextFile := Main.FQueue[NextIndex];
    Reply(Main, 'stop', '');
    Require(Main.FQueueNextPending, 'Confirmed end did not schedule advancement');
    Main.StreamTick(nil);
    if not AutoNext then
      begin
        Require(Main.FQueueIndex = Index, 'Auto-next Off changed the track');
        Require(Main.FStreamActions.Count = 0, 'Auto-next Off started another track');
      end
    else
      if NextIndex = Main.FQueue.Count then
        begin
          Require(not Main.FQueueActive, 'Playlist did not finish');
          Require(Main.FStreamActions.Count = 0, 'Finished playlist restarted');
        end
      else
        begin
          Require(Main.FQueueIndex = NextIndex, 'Next track was not selected');
          Require(Main.FStreamActions.Count = 1, 'Next track was not queued to play');
          Require(Main.FStreamActions[0].QueueStarting, 'Next track lost playlist mode');
          Require(Main.FStreamActions[0].FileName = Main.FQueue[NextIndex], 'Wrong file queued');
          if not Loop then
            Require(Main.FSelectedFile = NextFile, 'Shuffled successor was not loaded');
          Require(not Main.FQueueSawPlaying, 'New track inherited old playback confirmation');
          Require(not Main.FQueueNextPending, 'New track inherited pending advancement');
          Main.StreamTick(nil);
          Require(Main.FStreamActions.Count = 1, 'Repeated tick duplicated the next track');
        end;
  finally
    Main.Free;
  end;
end;


var
  Shuffle: Boolean;
  PollFailure: Boolean;

begin
  Application.Initialize();
  for Shuffle := False to True do
    for PollFailure := False to True do
      begin
        CheckAdvance(Shuffle, True, False, 0, PollFailure);
        CheckAdvance(Shuffle, False, False, 0, PollFailure);
        CheckAdvance(Shuffle, True, False, 3, PollFailure);
        CheckAdvance(Shuffle, True, True, 3, PollFailure);
      end;
  Writeln('PASS shuffle/sequential auto-next, transient status errors, auto-next Off, playlist end and loop.');
end.
