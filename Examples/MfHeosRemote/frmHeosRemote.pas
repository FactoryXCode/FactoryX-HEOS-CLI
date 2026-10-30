// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: FactoryX HEOS CLI
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: frmHeosRemote.pas
// Kind: Pascal Unit
// Release date: 28-10-2026
// Language: ENU
//
// Revision Version: 1.0.0.1
// Description: Standard VCL remote sample for the HEOS CLI.
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
//         HARMAN International (HEOS_CLI_ProtocolSpecification-Version-1.17)
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
unit frmHeosRemote;

interface

uses

  {System}
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Generics.Collections,
  {Vcl}
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Dialogs,
  {Application}
  Heos.Cli,
  Heos.Commands,
  Heos.Discovery,
  Heos.Sockets,
  MfHeosAudioServer;

type

  TfrmHeosRemote = class(TForm)
    grpConnection: TGroupBox;
    lblHost: TLabel;
    edHost: TEdit;
    btnConnect: TButton;
    btnDisconnect: TButton;
    lblPlayer: TLabel;
    cbPlayers: TComboBox;
    btnRefresh: TButton;
    btnFind: TButton;
    lblConnection: TLabel;
    grpPlayback: TGroupBox;
    btnPrevious: TButton;
    btnPlay: TButton;
    btnPause: TButton;
    btnStop: TButton;
    btnNext: TButton;
    lblVolume: TLabel;
    tbVolume: TTrackBar;
    chkMute: TCheckBox;
    grpFile: TGroupBox;
    edAudioFile: TEdit;
    btnBrowse: TButton;
    dlgAudioFile: TOpenDialog;
    grpNowPlaying: TGroupBox;
    lblTitle: TLabel;
    lblArtist: TLabel;
    lblAlbum: TLabel;
    lblState: TLabel;
    pbProgress: TProgressBar;
    lblTime: TLabel;
    memLog: TMemo;
    btnClearLog: TButton;
    DispatchTimer: TTimer;
    VolumeTimer: TTimer;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure cbPlayersChange(Sender: TObject);
    procedure TransportClick(Sender: TObject);
    procedure tbVolumeChange(Sender: TObject);
    procedure chkMuteClick(Sender: TObject);
    procedure DispatchTimerTimer(Sender: TObject);
    procedure VolumeTimerTimer(Sender: TObject);
    procedure btnClearLogClick(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);

  private

    FClient: THeosClient;
    FPlayerIds: TList<Int64>;
    FPlayerAddresses: TList<string>;
    FAudioServer: THeosAudioServer;
    FFileRequest: UInt64;
    FServingFile: string;
    FFileNeedsStart: Boolean;
    FPlayState: string;
    FUpdating: Boolean;
    FVolumePending: Boolean;
    FDesiredVolume: Integer;
    FVolumeRequest: UInt64;
    FDiscovery: THeosDiscovery;
    FDevices: TArray<THeosDevice>;
    FSelectingDevice: Boolean;
    FDiscoverPending: Boolean;
    FAllowDiscovery: Boolean;

    procedure PlaySelectedFile();
    procedure StartDiscovery();
    procedure CompleteDiscovery();
    procedure ConnectToHost(AllowDiscovery: Boolean);

    function SelectedPlayer(out APlayerId: Int64): Boolean;
    procedure AddLog(const AText: string);
    procedure UpdateControls();
    procedure Disconnect();
    procedure RefreshPlayer();
    procedure LoadPlayers(APayload: TJSONValue);

    procedure HandleReply(Sender: TObject;
                          AMessage: THeosMessage);

    procedure HandleEvent(Sender: TObject;
                          AMessage: THeosMessage);
    procedure HandleConnection(Sender: TObject; AMessage: THeosMessage);

    procedure HandleError(Sender: TObject;
                          AMessage: THeosMessage);

    procedure ApplyVolume(ALevel: Integer);
  end;

var
  HeosRemoteFrm: TfrmHeosRemote;


implementation

{$R *.dfm}

function JsonText(AObject: TJSONObject;
                  const AName: string): string;
var
  Value: TJSONValue;

begin

  Result := '';
  if (AObject = nil) then
    Exit;

  Value := AObject.GetValue(AName);
  if (Value <> nil) then
    Result := Value.Value;
end;


function TimeText(AMilliseconds: Int64): string;
var
  Seconds: Int64;

begin

  if (AMilliseconds < 0) then
    AMilliseconds := 0;

  Seconds := AMilliseconds div 1000;
  Result := Format('%.2d:%.2d:%.2d',
                   [Seconds div 3600, (Seconds div 60) mod 60, Seconds mod 60]);
end;


procedure TfrmHeosRemote.FormCreate(Sender: TObject);
begin

  FPlayerIds := TList<Int64>.Create;
  FPlayerAddresses := TList<string>.Create;
  FFileNeedsStart := True;
  UpdateControls();
end;


procedure TfrmHeosRemote.FormDestroy(Sender: TObject);
begin

  Disconnect();
  FPlayerIds.Free;
  FPlayerAddresses.Free;
end;


function TfrmHeosRemote.SelectedPlayer(out APlayerId: Int64): Boolean;
begin

  APlayerId := 0;
  Result := (cbPlayers.ItemIndex >= 0) and
            (cbPlayers.ItemIndex < FPlayerIds.Count);

  if Result then
    APlayerId := FPlayerIds[cbPlayers.ItemIndex];
end;


procedure TfrmHeosRemote.AddLog(const AText: string);
begin

  if (memLog.Lines.Count >= 300) then
    memLog.Clear;

  memLog.Lines.Add(FormatDateTime('hh:nn:ss',
                                  Now) + '  ' + AText);
end;


procedure TfrmHeosRemote.UpdateControls();
var
  PlayerId: Int64;
  Ready: Boolean;

begin

  Ready := False;

  if Assigned(FClient) then
    Ready := FClient.Connected and SelectedPlayer(PlayerId);

  edHost.Enabled := not Assigned(FClient) and not Assigned(FDiscovery);
  btnConnect.Enabled := edHost.Enabled;

  btnFind.Enabled := not Assigned(FDiscovery);

  btnDisconnect.Enabled := Assigned(FClient) or Assigned(FDiscovery) or FSelectingDevice;

  btnRefresh.Enabled := Assigned(FClient);

  cbPlayers.Enabled := (Assigned(FClient) and (FPlayerIds.Count > 0)) or FSelectingDevice;

  grpPlayback.Enabled := Ready;
end;


procedure TfrmHeosRemote.Disconnect();
begin

  DispatchTimer.Enabled := False;
  VolumeTimer.Enabled := False;
  FVolumePending := False;
  FVolumeRequest := 0;
  FFileRequest := 0;
  FServingFile := '';
  FFileNeedsStart := True;
  FPlayState := '';
  FreeAndNil(FAudioServer);
  FDiscoverPending := False;
  FAllowDiscovery := False;
  FSelectingDevice := False;
  FDevices := nil;
  lblPlayer.Caption := 'Player:';

  if Assigned(FDiscovery) then
    begin

      FDiscovery.Terminate;
      FDiscovery.WaitFor;
      FreeAndNil(FDiscovery);
    end;

  // Free outside Dispatch: callbacks never destroy their own client.
  FreeAndNil(FClient);
  cbPlayers.Clear;
  FPlayerIds.Clear;
  FPlayerAddresses.Clear;
  lblConnection.Caption := 'Disconnected';
  lblTitle.Caption := 'Title: -';
  lblArtist.Caption := 'Artist: -';
  lblAlbum.Caption := 'Album: -';
  lblState.Caption := 'State: -';
  lblTime.Caption := '00:00:00 / 00:00:00';
  pbProgress.Position := 0;
  UpdateControls();
end;


procedure TfrmHeosRemote.btnConnectClick(Sender: TObject);
begin

  if not IPv4Valid(Trim(edHost.Text)) then
    StartDiscovery()
  else
    ConnectToHost(True);
end;


procedure TfrmHeosRemote.ConnectToHost(AllowDiscovery: Boolean);
begin

  Disconnect();
  FAllowDiscovery := AllowDiscovery;

  try

    FClient := THeosClient.Create(Trim(edHost.Text));
    FClient.OnReply := HandleReply;
    FClient.OnEvent := HandleEvent;
    FClient.OnConnection := HandleConnection;
    FClient.OnError := HandleError;
    lblConnection.Caption := 'Connecting...';
    FClient.Enqueue(THeosCommands.RegisterForChangeEvents(True));
    FClient.Enqueue(THeosCommands.GetPlayers());
    DispatchTimer.Enabled := True;
    UpdateControls();

  except

    on E: Exception do
      begin

        Disconnect();
        AddLog(E.Message);
      end;
  end;
end;


procedure TfrmHeosRemote.btnFindClick(Sender: TObject);
begin

  StartDiscovery();
end;


procedure TfrmHeosRemote.StartDiscovery();
begin

  if Assigned(FDiscovery) then
    Exit;

  Disconnect();
  FDiscovery := THeosDiscovery.Create;
  lblConnection.Caption := 'Searching for HEOS devices...';
  AddLog(lblConnection.Caption);
  FDiscovery.Start;
  DispatchTimer.Enabled := True;
  UpdateControls();
end;


procedure TfrmHeosRemote.CompleteDiscovery();
var
  Device: THeosDevice;
  ErrorText: string;

begin

  if not Assigned(FDiscovery) or not FDiscovery.Finished then
    Exit;

  FDevices := Copy(FDiscovery.Devices);
  ErrorText := FDiscovery.ErrorText;
  FreeAndNil(FDiscovery);
  DispatchTimer.Enabled := False;
  cbPlayers.Clear;

  for Device in FDevices do
    begin

      cbPlayers.Items.Add(Device.Name + ' (' + Device.Address + ')');
      AddLog('Found HEOS device: ' + Device.Name + ' - ' + Device.Address);
    end;

  if (Length(FDevices) = 1) then
    begin

      edHost.Text := FDevices[0].Address;
      // One retry after discovery; no endless connect/discover loop.
      ConnectToHost(False);
      Exit;
    end;

  FSelectingDevice := Length(FDevices) > 0;
  if FSelectingDevice then
    begin

      lblPlayer.Caption := 'Device:';
      lblConnection.Caption := 'Select a HEOS device below.';
    end
  else
    if (ErrorText <> '') then
      lblConnection.Caption := 'Discovery failed: ' + ErrorText
    else
      lblConnection.Caption := 'No HEOS device replied. Check power/network, or enter its IP.';

  AddLog(lblConnection.Caption);
  UpdateControls();
end;


procedure TfrmHeosRemote.btnDisconnectClick(Sender: TObject);
begin

  Disconnect();
end;


procedure TfrmHeosRemote.btnRefreshClick(Sender: TObject);
begin

  if not Assigned(FClient) then
    Exit;

  try

    FClient.Enqueue(THeosCommands.GetPlayers());
  except

    on E: Exception do
      AddLog(E.Message);
  end;
end;


procedure TfrmHeosRemote.RefreshPlayer();
var
  PlayerId: Int64;

begin

  if not Assigned(FClient) or not SelectedPlayer(PlayerId) then
    Exit;

  FClient.Enqueue(THeosCommands.GetPlayState(PlayerId));
  FClient.Enqueue(THeosCommands.GetPlayerVolume(PlayerId));
  FClient.Enqueue(THeosCommands.GetPlayerMute(PlayerId));
  FClient.Enqueue(THeosCommands.GetNowPlayingMedia(PlayerId));
end;


procedure TfrmHeosRemote.cbPlayersChange(Sender: TObject);
var
  Index: Integer;

begin

  if FSelectingDevice then
    begin

      Index := cbPlayers.ItemIndex;
      if (Index >= 0) and (Index < Length(FDevices)) then
        begin

          edHost.Text := FDevices[Index].Address;
          ConnectToHost(False);
        end;
      Exit;
    end;

  FVolumePending := False;
  FVolumeRequest := 0;
  FFileRequest := 0;
  FFileNeedsStart := True;
  FPlayState := '';
  VolumeTimer.Enabled := False;
  pbProgress.Position := 0;
  lblTime.Caption := '00:00:00 / 00:00:00';
  UpdateControls();

  try

    RefreshPlayer();
  except

    on E: Exception do
      AddLog(E.Message);
  end;
end;


procedure TfrmHeosRemote.LoadPlayers(APayload: TJSONValue);
var
  Players: TJSONArray;
  Player: TJSONObject;
  PlayerId: Int64;
  PreviousId: Int64;
  HadSelection: Boolean;
  i: Integer;
  Index: Integer;
  Name: string;

begin

  if not (APayload is TJSONArray) then
    Exit;

  HadSelection := SelectedPlayer(PreviousId);
  Players := TJSONArray(APayload);
  cbPlayers.Items.BeginUpdate;

  try

    cbPlayers.Clear;
    FPlayerIds.Clear;
    FPlayerAddresses.Clear;
    Index := -1;

    for i := 0 to Players.Count - 1 do
      begin

        if not (Players.Items[i] is TJSONObject) then
          Continue;

        Player := TJSONObject(Players.Items[i]);
        if not TryStrToInt64(JsonText(Player, 'pid'), PlayerId) then
          Continue;

        Name := HeosDecode(JsonText(Player, 'name'));
        cbPlayers.Items.Add(Name + ' (' + JsonText(Player, 'ip') + ')');
        FPlayerIds.Add(PlayerId);
        FPlayerAddresses.Add(JsonText(Player, 'ip'));

        if (HadSelection and (PlayerId = PreviousId)) or
           (not HadSelection and (JsonText(Player, 'ip') = Trim(edHost.Text))) then
          Index := FPlayerIds.Count - 1;
      end;

    if (Index < 0) and (FPlayerIds.Count > 0) then
      Index := 0;

    cbPlayers.ItemIndex := Index;
  finally

    cbPlayers.Items.EndUpdate;
  end;

  if not HadSelection or (cbPlayers.ItemIndex < 0) or
     (FPlayerIds[cbPlayers.ItemIndex] <> PreviousId) then
    cbPlayersChange(cbPlayers)
  else
    begin

      UpdateControls();
      RefreshPlayer();
    end;
  AddLog(Format('%d HEOS player(s) found.', [FPlayerIds.Count]));
  if (FPlayerIds.Count = 0) and FAllowDiscovery then
    FDiscoverPending := True;
end;


procedure TfrmHeosRemote.TransportClick(Sender: TObject);
var
  PlayerId: Int64;
  Command: THeosCommand;

begin

  if not Assigned(FClient) or not SelectedPlayer(PlayerId) then
    Exit;

  try

    if (TComponent(Sender).Tag = 1) and (edAudioFile.Text <> '') and
       (FFileNeedsStart or (FPlayState = 'stop')) then
      begin

        PlaySelectedFile();
        Exit;
      end;

    if (TComponent(Sender).Tag = 3) then
      FFileNeedsStart := True;

    case TComponent(Sender).Tag of
      0: Command := THeosCommands.PlayPrevious(PlayerId);
      1: Command := THeosCommands.SetPlayState(PlayerId, hpsPlay);
      2: Command := THeosCommands.SetPlayState(PlayerId, hpsPause);
      3: Command := THeosCommands.SetPlayState(PlayerId, hpsStop);
      4: Command := THeosCommands.PlayNext(PlayerId);
    else
      Exit;
    end;

    FClient.Enqueue(Command);
    FClient.Enqueue(THeosCommands.GetPlayState(PlayerId));
  except

    on E: Exception do
      AddLog(E.Message);
  end;
end;


procedure TfrmHeosRemote.btnBrowseClick(Sender: TObject);
begin

  if not dlgAudioFile.Execute then
    Exit;

  edAudioFile.Text := dlgAudioFile.FileName;
  FFileNeedsStart := True;
  AddLog('Selected file: ' + edAudioFile.Text + '. Press Play to stream it.');
end;


procedure TfrmHeosRemote.PlaySelectedFile();
var
  PlayerId: Int64;
  Address: string;

begin

  if not Assigned(FClient) or not SelectedPlayer(PlayerId) then
    Exit;
  if (FFileRequest <> 0) then
    Exit;

  try

    if not FileExists(edAudioFile.Text) then
      raise EInvalidOperation.Create('Choose an existing audio file first.');

    Address := FPlayerAddresses[cbPlayers.ItemIndex];
    if not IPv4Valid(Address) then
      raise EInvalidOperation.Create('The selected player has no valid IPv4 address.');

    Address := LocalAddressFor(Address);
    FreeAndNil(FAudioServer);
    FServingFile := edAudioFile.Text;
    FAudioServer := THeosAudioServer.Create(Address, 0, FServingFile, False);
    FAudioServer.Start;
    FFileRequest := FClient.Enqueue(THeosCommands.PlayUrl(PlayerId, FAudioServer.Url()));
    AddLog('Serving selected file: ' + FAudioServer.Url());
    lblState.Caption := 'State: loading file...';
  except

    on E: Exception do
      begin

        FFileRequest := 0;
        FFileNeedsStart := True;
        FreeAndNil(FAudioServer);
        AddLog(E.Message);
      end;
  end;
end;


procedure TfrmHeosRemote.ApplyVolume(ALevel: Integer);
begin

  if (ALevel < 0) or (ALevel > 100) or
     FVolumePending or (FVolumeRequest <> 0) then
    Exit;

  FUpdating := True;

  try

    tbVolume.Position := ALevel;
    lblVolume.Caption := Format('Volume: %d%%', [ALevel]);
  finally

    FUpdating := False;
  end;
end;


procedure TfrmHeosRemote.tbVolumeChange(Sender: TObject);
begin

  if FUpdating or not Assigned(FClient) then
    Exit;

  FDesiredVolume := tbVolume.Position;
  lblVolume.Caption := Format('Volume: %d%%', [FDesiredVolume]);
  FVolumePending := True;
  VolumeTimer.Enabled := False;
  VolumeTimer.Enabled := True;
end;


procedure TfrmHeosRemote.VolumeTimerTimer(Sender: TObject);
var
  PlayerId: Int64;

begin

  if (FVolumeRequest <> 0) then
    Exit;

  VolumeTimer.Enabled := False;
  if not FVolumePending or not Assigned(FClient) or not SelectedPlayer(PlayerId) then
    Exit;

  try

    FVolumeRequest := FClient.Enqueue(THeosCommands.SetPlayerVolume(PlayerId, FDesiredVolume));
    FVolumePending := False;
  except

    on E: Exception do
      begin

        FVolumePending := False;
        AddLog(E.Message);
      end;
  end;
end;


procedure TfrmHeosRemote.chkMuteClick(Sender: TObject);
var
  PlayerId: Int64;

begin

  if FUpdating or not Assigned(FClient) or not SelectedPlayer(PlayerId) then
    Exit;

  try

    FClient.Enqueue(THeosCommands.SetPlayerMute(PlayerId, chkMute.Checked));
    FClient.Enqueue(THeosCommands.GetPlayerMute(PlayerId));
  except

    on E: Exception do
      AddLog(E.Message);
  end;
end;


procedure TfrmHeosRemote.HandleReply(Sender: TObject;
                                      AMessage: THeosMessage);
var
  PlayerId: Int64;
  ReplyPlayer: Int64;
  Payload: TJSONObject;

begin

  if (AMessage.RequestId = FVolumeRequest) then
    FVolumeRequest := 0;

  if (FFileRequest <> 0) and (AMessage.RequestId = FFileRequest) then
    begin

      FFileRequest := 0;
      FFileNeedsStart := not AMessage.Success or (edAudioFile.Text <> FServingFile);
      if AMessage.Success then
        AddLog('HEOS accepted the file URL. Playback may take a few seconds.');
    end;

  if not AMessage.Success then
    begin

      AddLog(AMessage.Command + ': ' + AMessage.ErrorText);
      Exit;
    end;

  if (AMessage.Command = 'player/get_players') then
    begin

      LoadPlayers(AMessage.Payload);
      Exit;
    end;

  if not SelectedPlayer(PlayerId) or
     not TryStrToInt64(AMessage.Parameter('pid'), ReplyPlayer) or
     (ReplyPlayer <> PlayerId) then
    Exit;

  if (AMessage.Command = 'player/get_volume') or
     (AMessage.Command = 'player/set_volume') then
    ApplyVolume(AMessage.IntegerParameter('level', -1))
  else
    if (AMessage.Command = 'player/get_mute') or
       (AMessage.Command = 'player/set_mute') then
      begin

        FUpdating := True;
        try

          chkMute.Checked := (AMessage.Parameter('state') = 'on');
        finally

          FUpdating := False;
        end;
      end
  else
    if (AMessage.Command = 'player/get_play_state') or
       (AMessage.Command = 'player/set_play_state') then
      begin

        FPlayState := AMessage.Parameter('state');
        lblState.Caption := 'State: ' + FPlayState;
      end
  else
    if (AMessage.Command = 'player/get_now_playing_media') and
       (AMessage.Payload is TJSONObject) then
      begin

        Payload := TJSONObject(AMessage.Payload);
        lblTitle.Caption := 'Title: ' + HeosDecode(JsonText(Payload, 'song'));
        lblArtist.Caption := 'Artist: ' + HeosDecode(JsonText(Payload, 'artist'));
        lblAlbum.Caption := 'Album: ' + HeosDecode(JsonText(Payload, 'album'));
      end;
end;


procedure TfrmHeosRemote.HandleEvent(Sender: TObject;
                                      AMessage: THeosMessage);
var
  PlayerId: Int64;
  PositionMs: Int64;
  DurationMs: Int64;

begin

  if (AMessage.EventKind = hePlayersChanged) then
    begin

      FClient.Enqueue(THeosCommands.GetPlayers());
      Exit;
    end;

  if not SelectedPlayer(PlayerId) or
     (AMessage.IntegerParameter('pid') <> PlayerId) then
    Exit;

  case AMessage.EventKind of
    hePlayerStateChanged:
      begin

        FPlayState := AMessage.Parameter('state');
        lblState.Caption := 'State: ' + FPlayState;
      end;
    heNowPlayingChanged: FClient.Enqueue(THeosCommands.GetNowPlayingMedia(PlayerId));
    hePlayerVolumeChanged:
      begin

        ApplyVolume(AMessage.IntegerParameter('level', -1));
        FUpdating := True;
        try

          chkMute.Checked := (AMessage.Parameter('mute') = 'on');
        finally

          FUpdating := False;
        end;
      end;
    heNowPlayingProgress:
      begin

        PositionMs := AMessage.IntegerParameter('cur_pos');
        DurationMs := AMessage.IntegerParameter('duration');
        lblTime.Caption := TimeText(PositionMs) + ' / ' + TimeText(DurationMs);

        if (DurationMs > 0) then
          pbProgress.Position := Round((PositionMs / DurationMs) * pbProgress.Max)
        else
          pbProgress.Position := 0;
      end;
    hePlaybackError: AddLog('Playback error: ' + AMessage.MessageText);
  end;
end;


procedure TfrmHeosRemote.HandleConnection(Sender: TObject;
                                           AMessage: THeosMessage);
begin

  lblConnection.Caption := 'HEOS: ' + AMessage.MessageText;
  AddLog(lblConnection.Caption);
  UpdateControls();
end;


procedure TfrmHeosRemote.HandleError(Sender: TObject;
                                      AMessage: THeosMessage);
begin

  if (AMessage.RequestId = FVolumeRequest) then
    FVolumeRequest := 0;

  if (FFileRequest <> 0) and (AMessage.RequestId = FFileRequest) then
    begin

      FFileRequest := 0;
      FFileNeedsStart := True;
    end;

  AddLog(AMessage.LocalError);
  if FAllowDiscovery and Assigned(FClient) and not FClient.Connected then
    FDiscoverPending := True;
  UpdateControls();
end;


procedure TfrmHeosRemote.DispatchTimerTimer(Sender: TObject);
begin

  if Assigned(FDiscovery) then
    begin

      CompleteDiscovery();
      Exit;
    end;

  if not Assigned(FClient) then
    Exit;

  try

    FClient.Dispatch();
    // Defer client destruction until all API callbacks have returned.
    if FDiscoverPending then
      StartDiscovery();
  except

    on E: Exception do
      AddLog(E.Message);
  end;
end;


procedure TfrmHeosRemote.btnClearLogClick(Sender: TObject);
begin

  memLog.Clear;
end;

end.