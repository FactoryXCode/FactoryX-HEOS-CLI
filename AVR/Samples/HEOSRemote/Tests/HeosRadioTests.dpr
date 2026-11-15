// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: Media Foundation - MFPack - Samples
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HeosRadioTests.dpr
// Kind: Pascal Unit
// Release date: 30-10-2026
// Language: ENU
//
// Revision Version: 1.1.0.0
// Description: Mock receiver regression checks for internet radio.
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
program HeosRadioTests;

{$APPTYPE CONSOLE}

uses

  System.SysUtils,
  System.Classes,
  System.Diagnostics,
  System.Types,
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Graphics,
  MainForm,
  Heos.Cli,
  Heos,
  HEOSRadioForm;

procedure Require(Value: Boolean; const Text: string);
begin

  if not Value then
    raise Exception.Create(Text);
end;

procedure Pump(Radio: THEOSRadioForm; Main: THEOSForm);
var
  Clock: TStopwatch;

begin

  Clock := TStopwatch.StartNew;
  repeat
    Radio.PollTick(nil);
    CheckSynchronize(0);
    if Assigned(Main) then
      Main.StreamTick(nil);
    Sleep(10);
  until ((Radio.FRequest = rrNone) and not Assigned(Radio.FStreamProbe) and
          (not Radio.FPlaybackChecking or Radio.PlaybackConfirmed) and
          (not Assigned(Main) or ((Main.FStreamActions.Count = 0) and
           (not Assigned(Main.FHeos) or Main.FHeos.Finished)))) or
        (Clock.ElapsedMilliseconds > 8000);
  Radio.PollTick(nil);
  Require(Radio.FRequest = rrNone, 'Radio request did not finish: ' + Radio.lblStatus.Caption);
end;

var
  Main: THEOSForm;
  Radio: THEOSRadioForm;
  Bad: THEOSRadioForm;
  Saved: THEOSRadioForm;
  StatusMessage: THeosMessage;
  CanClose: Boolean;
  Location: string;
  CloseClock: TStopwatch;
  LogoHandler: TNotifyEvent;
  LocalLogo: string;
  LogoBitmap: TBitmap;
  LogoKey: Word;

begin

  try
    Application.Initialize;
    Main := THEOSForm.Create(nil);
    try
      CanClose := False;
      Main.MainCloseQuery(nil, CanClose);
      Require(CanClose and not Main.FClosePending,
              'Opening and closing an idle remote tried to stop unrelated receiver playback');
      Main.edHost.Text := '127.0.0.1';
      Radio := THEOSRadioForm.Create(Main);
      Main.FRadioForm := Radio;
      Radio.OnBeforePlay := Main.BeforeRadioPlay;
      Radio.OnPlayback := Main.RadioPlayback;
      Radio.ConnectTo('127.0.0.1');
      Pump(Radio, Main);
      Require((Radio.cbService.Items.Count = 4) and (Radio.cbService.Text = 'TuneIn'),
              'Radio services with available=false were hidden');
      Require((Radio.cbCriteria.Text = 'Station') and Radio.btnSearch.Enabled,
              'Anonymous TuneIn search was not enabled');
      Require(Radio.lvStations.Items.Count = 2, 'Root categories not loaded');
      Require(not Assigned(Main.FAudioServer) and not Main.FRadioPlaying,
              'Browsing unexpectedly started audio');

      Radio.lvStations.Items[0].Selected := True;
      Radio.OpenItem(nil);
      Pump(Radio, Main);
      Require((Radio.lvStations.Items.Count = 2) and Radio.btnNextPage.Enabled,
              'Unknown-size category was not pageable');
      Radio.lvStations.Items[1].Selected := True;
      Radio.UpdateButtons();
      Require(not Radio.chkPlayStation.Enabled, 'Non-station item was playable');
      Radio.NavigationClick(Radio.btnNextPage);
      Pump(Radio, Main);
      Require((Radio.lvStations.Items.Count = 0) and not Radio.btnNextPage.Enabled,
              'Empty page did not terminate unknown-size browsing');
      Radio.NavigationClick(Radio.btnBack);
      Pump(Radio, Main);
      Require(Radio.lvStations.Items.Count = 2, 'Back did not restore root');
      Location := Radio.lblLocation.Caption;
      Radio.lvStations.Items[1].Selected := True;
      Radio.OpenItem(nil);
      Pump(Radio, Main);
      Require((Radio.lvStations.Items.Count = 2) and
              (Radio.lblLocation.Caption = Location) and Radio.btnHome.Enabled,
              'Failed navigation lost the visible list or left controls disabled');

      Radio.edSearch.Text := 'Jazz & '+#$65E5+#$672C+#$8A9E+' + %';
      Radio.SearchClick(nil);
      Pump(Radio, Main);
      Require((Radio.lvStations.Items.Count = 1) and not Radio.btnNextPage.Enabled,
              'Search results or known-size paging incorrect');
      Radio.lvStations.Items[0].Selected := True;
      Main.FWaitingForCapture := True;
      Radio.PlayClick(nil);
      Require((Radio.FRequest = rrNone) and not Main.FWaitingForCapture and
              (Main.FStreamActions.Count = 1),
              'Radio did not cancel capture and wait for receiver Stop');
      Main.FWaitingForCapture := False;
      Main.FQueueActive := True;
      Main.FQueueNextPending := True;
      Radio.PlayClick(nil);
      CanClose := True;
      Radio.RadioCloseQuery(nil, CanClose);
      Require(CanClose, 'Modeless Radio could not hide while playback was pending');
      Pump(Radio, Main);
      Require(Radio.PlaybackConfirmed and Main.FRadioPlaying and (Main.FPlaybackState = 'play') and
              not Main.FQueueActive and not Main.FQueueNextPending and
              not Assigned(Main.FAudioServer) and not Assigned(Main.FLoopback),
              'Receiver-direct station handover failed');
      Require(not Main.CanSeekPlayback() and not Main.btnPlayPause.Enabled,
              'Radio allowed file pause or seeking');
      Main.FSelectedFile := 'selected.mp3';
      Main.UpdateStreamButtons();
      Require(Main.btnPlayPause.Enabled and (Main.btnPlayPause.Caption = 'Play file'),
              'Radio did not allow switching back to a selected file');
      Main.FSelectedFile := '';
      Main.FRadioStartedTick := MainForm.GetTickCount64() - 65000;
      Main.UpdateProgressDisplay();
      Require((Main.lblDuration.Caption = 'Duration: Live radio') and
              (Main.lblPlayed.Caption = 'Played: 00:01:05') and
              (Main.pbProgress.Position = 0), 'Radio progress was treated as a file');
      CanClose := False;
      Radio.RadioCloseQuery(nil, CanClose);
      Require(CanClose and Main.FRadioPlaying, 'Closing browser stopped radio');
      Main.StartStreamAction(4);
      Pump(Radio, Main);
      Require(not Main.FRadioPlaying and not Radio.FPlaying and not Radio.chkPlayStation.Checked,
              'Main transport Stop did not stop radio');

      Radio.cbService.ItemIndex := 1;
      Radio.SourceChange(nil);
      Pump(Radio, Main);
      Require(not Radio.btnSearch.Enabled and
              (Pos('Favorites has no search', Radio.lblStatus.Caption) > 0),
              'Favorites search state was not explained');
      Radio.lvStations.Items[0].Selected := True;
      Radio.chkPlayStation.Click();
      Pump(Radio, Main);
      Require(Main.FRadioPlaying and Radio.chkPlayStation.Checked,
              'Playing station did not check the toggle');
      Require(Radio.FindComponent('btnStopRadio') = nil,
              'Obsolete Stop button remains in the DFM');
      Radio.lvStations.Selected := nil;
      Radio.UpdateButtons();
      Require(Radio.chkPlayStation.Enabled and Radio.chkPlayStation.Checked,
              'Clearing the station selection disabled the playback Stop toggle');
      Main.FReceiverVerified := True;
      Main.FVerifiedHost := '127.0.0.1';
      Main.RadioClick(nil);
      Require(Radio.Visible and Main.Enabled and not (fsModal in Radio.FormState),
              'Radio disabled the console or remained modal');
      Radio.Hide;
      Main.tbVolume.Position := 100;
      Main.VolumeChange(nil);
      Require(Main.tbVolume.Enabled and Main.FVolumePending,
              'Console volume was unavailable while radio was playing');
      Main.FVolumePending := False;
      Main.VolumeTimer.Enabled := False;

      Radio.chkPlayStation.Click();
      Pump(Radio, Main);
      Require(not Main.FRadioPlaying and not Radio.chkPlayStation.Checked,
              'API radio Stop failed');

      Radio.lvStations.Items[0].Selected := True;

      // A console Stop must wait for an in-flight station request.
      Radio.PlayClick(nil);
      Main.StartStreamAction(4);
      Require((Main.FStreamActions.Count = 1) and
              Assigned(Main.FHeos) and not Main.FHeos.Finished,
              'Console Stop raced the radio playback request');
      Pump(Radio, Main);
      Require(not Main.FRadioPlaying and (Main.FStreamActions.Count = 0),
              'Queued console Stop did not execute after radio completion');

      Radio.cbService.ItemIndex := Radio.cbService.Items.IndexOf('SiriusXM');
      Radio.SourceChange(nil);
      Pump(Radio, Main);
      Require((Radio.lvStations.Items.Count = 0) and not Radio.chkPlayStation.Enabled and
              Radio.btnRefresh.Enabled and (Pos('Login required', Radio.lblStatus.Caption) > 0),
              'Service account error left stale results or an unusable browser');

      Require(not Radio.pnlCustomStation.ParentBackground and
              (Radio.pnlCustomStation.Color = Radio.Color) and
              not Radio.pnlBrowse.ParentBackground,
              'Themed panel backgrounds can hide the white Radio labels');
      Radio.Show;
      Application.ProcessMessages;
      Require(Radio.edStationName.Visible and Radio.edStationName.Enabled and
              (ChildWindowFromPointEx(Radio.pnlCustomStation.Handle,
                 Point(Radio.edStationName.Left + 20, Radio.edStationName.Top + 10),
                 CWP_SKIPINVISIBLE or CWP_SKIPDISABLED) = Radio.edStationName.Handle) and
              (ChildWindowFromPointEx(Radio.Handle,
                 Point(Radio.pnlCustomStation.Left + Radio.edStationName.Left + 20,
                       Radio.pnlCustomStation.Top + Radio.edStationName.Top + 10),
                 CWP_SKIPINVISIBLE or CWP_SKIPDISABLED) = Radio.pnlCustomStation.Handle),
              'Name field is covered or clipped in the Radio form');
      Require(ChildWindowFromPointEx(Radio.pnlCustomStation.Handle,
                Point(Radio.edStationUrl.Left + 20, Radio.edStationUrl.Top + 10),
                CWP_SKIPINVISIBLE or CWP_SKIPDISABLED) = Radio.edStationUrl.Handle,
              'URL field is covered or clipped');
      Radio.Hide;
      Require(Radio.ValidStationUrl('https://factoryxradio.asuscomm.com'),
              'The exact user HTTPS address failed URL validation');
      Radio.edStationName.Clear;
      Radio.edStationUrl.Text := 'https://factoryxradio.asuscomm.com';
      Radio.AddStationClick(nil);
      Require((Radio.FCustomItems.Count = 0) and
              (Pos('enter a station name', Radio.lblStationFeedback.Caption) > 0) and
              (Radio.edStationUrl.Text = 'https://factoryxradio.asuscomm.com'),
              'Missing name feedback was absent or discarded the URL');
      Radio.edStationName.Text := 'FactoryX '+#$00E9;
      Radio.edStationUrl.Text := 'factoryxradio.asuscomm.com';
      Radio.AddStationClick(nil);
      Require((Radio.FCustomItems.Count = 0) and
              (Pos('Not saved:', Radio.lblStationFeedback.Caption) > 0),
              'Invalid URL was saved or its feedback was absent');
      Radio.edStationUrl.Text := 'file:///C:/audio.mp3';
      Radio.AddStationClick(nil);
      Require(Radio.FCustomItems.Count = 0, 'A non-HTTP stream was saved');
      Radio.edStationUrl.Text := 'http://';
      Radio.AddStationClick(nil);
      Require(Radio.FCustomItems.Count = 0, 'An empty HTTP host was saved');
      Radio.edStationUrl.Text := ParamStr(5) + '/live?token=a&b=100%25+test';
      Radio.AddStationClick(nil);
      Require((Radio.FCustomItems.Count = 1) and Radio.IsCustomService() and
              (Radio.lvStations.Items.Count = 1) and Radio.chkPlayStation.Enabled and
              not Radio.btnSearch.Enabled, 'Custom station was not saved/selected/playable');
      Require((Pos('Saved "FactoryX ', Radio.lblStationFeedback.Caption) = 1) and
              (Pos('Press Play station to test', Radio.lblStationFeedback.Caption) > 0),
              'Save success was not confirmed separately from playback');
      Radio.edStationName.Text := 'FactoryX '+#$00E9;
      Radio.edStationUrl.Text := 'http://127.0.0.1:8000/duplicate';
      Radio.AddStationClick(nil);
      Require((Radio.FCustomItems.Count = 1) and
              (Pos('already exists', Radio.lblStationFeedback.Caption) > 0),
              'Duplicate name was accepted or not explained');
      Radio.UpdateButtons();
      Require(Radio.btnAddLogoPath.Enabled and Radio.edLogoUrl.Enabled,
              'Logo controls are disabled for a selected custom station');
      LogoHandler := Radio.StationLogoFileClick;
      Require(TMethod(Radio.btnAddLogoPath.OnClick).Code = TMethod(LogoHandler).Code,
              'Logo button is not wired to the LW image picker');
      LocalLogo := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Station logo with spaces.bmp';
      LogoBitmap := TBitmap.Create;
      try
        LogoBitmap.SetSize(2, 3);
        LogoBitmap.SaveToFile(LocalLogo);
      finally
        LogoBitmap.Free;
      end;
      try
        Radio.edLogoUrl.Text := LocalLogo;
        LogoKey := VK_RETURN;
        Radio.LogoUrlKeyDown(nil, LogoKey, []);
        Require((LogoKey = 0) and (Radio.FCustomItems[0].ImageUrl = LocalLogo) and
                (Radio.edLogoUrl.Text = LocalLogo),
                'Entering a logo path did not save and display the full path');
        Saved := THEOSRadioForm.Create(nil);
        try
          Require(Saved.FCustomItems[0].ImageUrl = LocalLogo,
                  'Local logo path did not survive restarting the radio form');
        finally
          Saved.Free;
        end;
        Radio.edLogoUrl.Text := LocalLogo + '.missing';
        Radio.LogoUrlExit(nil);
        Require(Radio.FCustomItems[0].ImageUrl = LocalLogo,
                'A missing logo path replaced the saved image');
        Radio.edLogoUrl.Text := '';
        Radio.LogoUrlExit(nil);
        Require(Radio.FCustomItems[0].ImageUrl = '', 'Clearing the logo did not remove it');
      finally
        System.SysUtils.DeleteFile(LocalLogo);
      end;
      Radio.edLogoUrl.Text := ParamStr(5) + '/logo-small';
      Radio.LogoUrlExit(nil);
      Require((Radio.FCustomItems[0].ImageUrl = ParamStr(5) + '/logo-small') and
              (Radio.edLogoUrl.Text = ParamStr(5) + '/logo-small'),
              'Typed logo URL was not saved and displayed');
      Radio.StationPopup(nil);
      Require(Radio.miRemoveStation.Enabled and Radio.miStationLogo.Enabled and Radio.miStationLogoFile.Enabled,
              'Custom station popup actions are unavailable');
      Radio.lvStations.Selected := nil;
      Radio.UpdateButtons();
      Require(not Radio.btnAddLogoPath.Enabled and not Radio.edLogoUrl.Enabled,
              'Logo controls remain enabled without a custom station selection');
      Radio.StationPopup(nil);
      Require(not Radio.miRemoveStation.Enabled and not Radio.miStationLogo.Enabled and not Radio.miStationLogoFile.Enabled,
              'Popup actions remain enabled without a selected station');
      Radio.lvStations.Items[0].Selected := True;

      Saved := THEOSRadioForm.Create(nil);
      try
        Require((Saved.FCustomItems[0].ImageUrl = ParamStr(5) + '/logo-small'),
                'Custom station logo URL was not saved');
        Require((Saved.FCustomItems.Count = 1) and
                (Saved.FCustomItems[0].Name = 'FactoryX '+#$00E9) and
                (Saved.FCustomItems[0].StreamUrl = Radio.FCustomItems[0].StreamUrl),
                'UTF-8 custom station settings did not survive reloading');
      finally
        Saved.Free;
      end;
      Radio.RefreshClick(nil);
      Pump(Radio, Main);
      Radio.cbService.ItemIndex := Radio.FSourceIds.IndexOf(-1);
      Radio.SourceChange(nil);
      Require(Radio.lvStations.Items.Count = 1, 'Refreshing services lost custom stations');
      Radio.lvStations.Items[0].Selected := True;
      Radio.PlayClick(nil);
      Pump(Radio, Main);
      Require(Main.FRadioPlaying and Radio.FPlaying and not Assigned(Main.FAudioServer),
              'Custom URL was not played directly by HEOS');
      Radio.edStationName.Text := 'Website is not audio';
      Radio.edStationUrl.Text := ParamStr(5) + '/web';
      Radio.AddStationClick(nil);
      Radio.PlayClick(nil);
      Pump(Radio, Main);
      Require((Pos('webpage', Radio.lblStationFeedback.Caption) > 0) and
              Main.FRadioPlaying and (Radio.FStationName <> 'Website is not audio'),
              'HTML URL replaced playback or did not explain the problem');
      Require(Radio.FCustomItems[1].ImageUrl = ParamStr(5) + '/logo-small',
              'Website station icon was not discovered and saved');
      Radio.edStationName.Text := 'Website audio';
      Radio.edStationUrl.Text := ParamStr(6);
      Radio.AddStationClick(nil);
      Radio.PlayClick(nil);
      Pump(Radio, Main);
      Require(Main.FRadioPlaying and (Radio.FStationName = 'Website audio') and
              (Radio.FCustomItems[2].StreamUrl = ParamStr(6)),
              'Website-to-AAC handover failed or changed the saved website URL');
      Radio.StationPopup(nil);
      Radio.miRemoveStation.Click();
      Radio.lvStations.Items[1].Selected := True;
      Radio.StationPopup(nil);
      Radio.miRemoveStation.Click();
      Require(Radio.FCustomItems.Count = 1, 'Popup did not remove the selected custom station');
      Radio.lvStations.Items[0].Selected := True;
      // URL -> file -> file -> URL; each source needs its own completed Stop.
      Main.PcAddressEdit.Text := '127.0.0.1';
      Main.StreamPortEdit.Text := ParamStr(3);
      Main.SelectAudioFile(ParamStr(2));
      Main.StartStreamAction(0);
      Require(not Main.FRadioPlaying and not Radio.FPlaybackChecking and
              not Assigned(Main.FAudioServer), 'File started before Stop completed');
      Pump(Radio, Main);
      Require(Assigned(Main.FAudioServer) and not Main.FRadioPlaying and
              (Main.FPlaybackState = 'play'), 'URL to file handover failed');
      Main.StartStreamAction(0);
      Pump(Radio, Main);
      Require(Assigned(Main.FAudioServer) and (Main.FPlaybackState = 'play'),
              'File replacement failed');
      Radio.PlayClick(nil);
      Pump(Radio, Main);
      Require(Main.FRadioPlaying and Radio.PlaybackConfirmed and
              not Assigned(Main.FAudioServer), 'File to custom URL handover failed');

      // Switching during an in-flight Stop cancels the superseded file start.
      Main.StartStreamAction(0);
      Radio.PlayClick(nil);
      Pump(Radio, Main);
      Require(Main.FRadioPlaying and Radio.PlaybackConfirmed and
              not Assigned(Main.FAudioServer), 'Radio overtook an in-flight source change');

      // Windows capture can be replaced by the selected file from the console.
      Main.FWaitingForCapture := True;
      Main.UpdateStreamButtons();
      Require(Main.btnPlayPause.Enabled and (Main.btnPlayPause.Caption = 'Play file'),
              'Windows streaming prevented selecting file playback');
      Main.PlayPauseClick(nil);
      Require(not Main.FWaitingForCapture, 'File selection did not cancel pending capture');
      Main.StartStreamAction(4);
      Pump(Radio, Main);

      // Stop while waiting for handover must cancel the pending file start.
      Main.StartStreamAction(0);
      Main.StartStreamAction(4);
      Pump(Radio, Main);
      Require(not Assigned(Main.FAudioServer) and not Main.FRadioPlaying and
              (Main.FStreamActions.Count = 0), 'Stop did not cancel a pending source');

      // A receiver refusing Stop must prevent the next file from starting.
      with TStringList.Create do
        try
          Add('fail');
          SaveToFile(ParamStr(4));
        finally
          Free;
        end;
      Main.StartStreamAction(0);
      Pump(Radio, Main);
      Require(not Assigned(Main.FAudioServer) and (Main.FStreamActions.Count = 0) and
              (Pos('Mock Stop refused', Main.lblStreamInfo.Caption) > 0),
              'A failed Stop was followed by a file start');
      Radio.PlayClick(nil);
      Pump(Radio, Main);
      Radio.StationPopup(nil);
      Radio.miRemoveStation.Click();
      Require((Radio.FCustomItems.Count = 0) and (Radio.lvStations.Items.Count = 0) and
              Main.FRadioPlaying, 'Removing a saved station interrupted playback');
      Saved := THEOSRadioForm.Create(nil);
      try
        Require(Saved.FCustomItems.Count = 0, 'Removed station remained in the INI');
      finally
        Saved.Free;
      end;
      Main.StartStreamAction(4);
      Pump(Radio, Main);
      Require(not Main.FRadioPlaying, 'Console Stop did not stop a custom stream');

      // Closing cancels queued starts, waits for the active request and sends Stop.
      Main.SendHeos(haGetState);
      Main.StartStreamAction(0);
      with TStringList.Create do
        try
          Add('fail');
          SaveToFile(ParamStr(4));
        finally
          Free;
        end;
      CanClose := True;
      Main.MainCloseQuery(nil, CanClose);
      Require(not CanClose and Main.FClosePending and not Main.FCloseStopSent and
              (Main.FStreamActions.Count = 0),
              'Close did not wait for the active request or left a queued file start');
      CloseClock := TStopwatch.StartNew;
      repeat
        Radio.PollTick(nil);
        CheckSynchronize(0);
        Main.StreamTick(nil);
        Sleep(10);
      until not Main.FClosePending or Main.FCloseReady or (CloseClock.ElapsedMilliseconds > 8000);
      Require(not Main.FCloseReady and not Main.FClosePending and Main.Enabled and
              Radio.Enabled and (Pos('Cannot stop receiver before closing', Main.lblStreamInfo.Caption) > 0),
              'A failed shutdown Stop silently closed the app or left it disabled');
      Main.MainCloseQuery(nil, CanClose);
      Require(not CanClose and Main.FClosePending, 'Close retry did not send Stop');
      CloseClock := TStopwatch.StartNew;
      repeat
        Radio.PollTick(nil);
        CheckSynchronize(0);
        Main.StreamTick(nil);
        Sleep(10);
      until not Main.FClosePending or Main.FCloseReady or (CloseClock.ElapsedMilliseconds > 8000);
      Require(Main.FCloseReady and not Assigned(Main.FAudioServer),
              'Successful shutdown Stop did not release local streaming and permit closing');
      CanClose := False;
      Main.MainCloseQuery(nil, CanClose);
      Require(CanClose, 'Confirmed Stop did not allow closing');
      Writeln('PASS stop-before-close, idle close, active request ordering, queued-start cancellation, Stop failure and retry.');
    finally
      Main.Free;
    end;

    Bad := THEOSRadioForm.Create(nil);
    try
      Bad.ConnectTo('127.0.0.1', StrToInt(ParamStr(1)));
      Pump(Bad, nil);
      Require(not Bad.FPlayerFound and Bad.btnRefresh.Enabled and
              (Pos('not found', Bad.lblStatus.Caption) > 0),
              'Mismatched receiver was accepted or could not be retried');
    finally
      Bad.Free;
    end;
    Bad := THEOSRadioForm.Create(nil);
    try
      Bad.FStationName := 'Unavailable stream';
      Bad.FPlaybackStatus := 'Command accepted';
      Bad.FPlaybackChecking := True;
      Bad.ReportPlayback(True);
      StatusMessage := THeosMessage.Parse('{"heos":{"command":"player/get_play_state","result":"success","message":"state=unknown"}}');
      try
        Bad.PlaybackReply(StatusMessage);
      finally
        StatusMessage.Free;
      end;
      Require(not Bad.PlaybackConfirmed and Bad.FPlaybackChecking,
              'Unknown receiver state was reported as playing');
      Bad.FPlaybackDeadline := Heos.Cli.GetTickCount64();
      Bad.CheckPlayback();
      Require(Bad.FPlaying and Bad.FPlaybackChecking and not Bad.PlaybackConfirmed and
              (Pos('Still waiting', Bad.PlaybackStatus) > 0),
              'Slow buffering cleared radio mode or cancelled confirmation checks');
      StatusMessage := THeosMessage.Parse('{"heos":{"command":"player/get_play_state","result":"success","message":"state=play"}}');
      try
        Bad.PlaybackReply(StatusMessage);
      finally
        StatusMessage.Free;
      end;
      Require(Bad.FPlaying and Bad.PlaybackConfirmed and Bad.FPlaybackChecking,
              'Playback starting after the initial timeout was not confirmed');
      StatusMessage := THeosMessage.Parse('{"heos":{"command":"player/get_play_state","result":"success","message":"state=unknown"}}');
      try
        Bad.PlaybackReply(StatusMessage);
      finally
        StatusMessage.Free;
      end;
      Require(Bad.FPlaying and Bad.FPlaybackChecking,
              'Temporary unknown state incorrectly stopped radio mode');
      StatusMessage := THeosMessage.Parse('{"heos":{"command":"player/get_play_state","result":"success","message":"state=stop"}}');
      try
        Bad.PlaybackReply(StatusMessage);
      finally
        StatusMessage.Free;
      end;
      Require(not Bad.FPlaying and not Bad.FPlaybackChecking,
              'Receiver-reported Stop was not reflected in radio mode');
      Bad.NotifyStopped();
      StatusMessage := THeosMessage.Parse('{"heos":{"command":"player/get_play_state","result":"success","message":"state=play"}}');
      try
        Bad.PlaybackReply(StatusMessage);
      finally
        StatusMessage.Free;
      end;
      Require(not Bad.FPlaying, 'Late status reply restarted stopped radio UI');
    finally
      Bad.Free;
    end;
    Writeln('PASS receiver playback confirmation, late playback, continuous monitoring, receiver Stop and stale-reply protection.');
    Writeln('PASS radio DFM, service discovery, browse/search/paging, errors, receiver selection, direct playback, main Stop, API Stop, file-switch controls and custom station URL/UTF-8 INI persistence.');
  except
    on E: Exception do
      begin
        Writeln(E.ClassName + ': ' + E.Message);
        Halt(1);
      end;
  end;
end.
