// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: Media Foundation - MFPack - Samples
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: MainForm.pas
// Kind: Pascal Unit
// Release date: 24-01-2026
// Language: ENU
//
// Revision Version: 1.0.0.1
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
unit MainForm;

interface

uses

  {System}
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  WinApi.Messages,
  {Vcl}
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Graphics,
  Vcl.Dialogs,
  Vcl.Menus,
  Vcl.Imaging.jpeg,
  {Application}
  HEOSTransport,
  Heos,
  HEOSAudioServer,
  HEOSLoopback,
  HEOSDiscovery,
  HEOSPlaylistForm,
  RDJ.PlaylistTypes,
  RDJ.PlaylistDb,
  RDJ.PlaylistManager,
  // Controls
  HEOSLevelProgressBar,
  HEOSButton,
  HEOSTrackBar;

type

  THEOSTrackInfo = class(TThread)
  private
    FFileName: string;
    FDurationMs: Int64;

  protected
    procedure Execute(); override;

  public

    constructor Create(const FileName: string);

    property FileName: string read FFileName;
    property DurationMs: Int64 read FDurationMs;
  end;


  THEOSStreamAction = record
    Action: Integer;
    FileName: string;
    QueueStarting: Boolean;
    PositionMs: Int64;
    Receiver: string;
  end;

  THEOSForm = class(TForm)
    pnlSettings: TPanel;
    AddressLabel: TLabel;
    FStatus: TLabel;
    edHost: TEdit;
    cbxHEOSDevices: TComboBox;
    VolumeTimer: TTimer;
    StreamTimer: TTimer;
    StreamActionTimer: TTimer;
    pnlPlay: TPanel;
    lblStreamInfo: TLabel;
    Panel3: TPanel;
    imgLogo: TImage;
    btnSettings: TDnButton;
    btnPlayer: TDnButton;
    btnStop: TDnButton;
    btnPlayPause: TDnButton;
    btnLoadFile: TDnButton;
    btnPlayList: TDnButton;
    btnPrevious: TDnButton;
    btnNext: TDnButton;
    btnShuffle: TDnButton;
    btnLoop: TDnButton;
    btnStreamWinAudio: TDnButton;
    lblDuration: TLabel;
    lblPlayed: TLabel;
    PcAddressLabel: TLabel;
    PcAddressEdit: TEdit;
    PortLabel: TLabel;
    StreamPortEdit: TEdit;
    btnFindHEOSDevice: TDnButton;
    tbVolume: TDnTrackBar;
    tbBalance: TDnTrackBar;
    lblBalance: TLabel;
    Bevel1: TBevel;
    pbProgress: TDnLevelProgressBar;
    lblSeekTime: TLabel;
    SeekHintTimer: TTimer;
    lblVolumePerc: TLabel;
    lblVol: TLabel;
    btnMainZone: TDnButton;
    btnZone2: TDnButton;
    Bevel2: TBevel;
    lblZones: TLabel;
    pmPlaylists: TPopupMenu;
    Bevel3: TBevel;
    btnMute: TDnButton;
    btnTone: TDnButton;
    tbBass: TDnTrackBar;
    tbTreble: TDnTrackBar;
    lblBass: TLabel;
    lblTreble: TLabel;
    lblToneStatus: TLabel;
    DnButton2: TDnButton;
    lblAppTitle: TLabel;
    FSource: TComboBox;
    chkAutoNextCheck: TCheckBox;
    memFLog: TMemo;
    Label2: TLabel;
    Label3: TLabel;
    Bevel5: TBevel;
    btnSelectInput: TDnButton;
    btnWebInterface: TDnButton;
    btnReadStatus: TDnButton;
    Label1: TLabel;
    Bevel4: TBevel;
    Bevel6: TBevel;
    Bevel7: TBevel;
    Label4: TLabel;
    Label5: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure pbProgressMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pbProgressMouseUp(Sender: TObject; Button: TMouseButton;
                                 Shift: TShiftState; X, Y: Integer);
    procedure SeekHintTick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ActionClick(Sender: TObject);
    procedure VolumeChange(Sender: TObject);
    procedure VolumeTick(Sender: TObject);
    procedure BalanceChange(Sender: TObject);
    procedure BalanceDblClick(Sender: TObject);
    procedure ZoneClick(Sender: TObject);
    procedure BrowserClick(Sender: TObject);
    procedure BrowseMusicClick(Sender: TObject);
    procedure StreamTick(Sender: TObject);
    procedure StreamActionTick(Sender: TObject);
    procedure FindHEOSDeviceClick(Sender: TObject);
    procedure HEOSDeviceChange(Sender: TObject);
    procedure PlaylistClick(Sender: TObject);
    procedure TrackClick(Sender: TObject);
    procedure MainCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnStreamWinAudioClick(Sender: TObject);
    procedure StreamClick(Sender: TObject);
    procedure PlayPauseClick(Sender: TObject);
    procedure SettingsClick(Sender: TObject);
    procedure PlayerClick(Sender: TObject);
    procedure QueueModeClick(Sender: TObject);
    procedure PlaylistHover(Sender: TObject);
    procedure PlaylistPopup(Sender: TObject);
    procedure PlaylistPopupItemClick(Sender: TObject);
    procedure btnPlayListMouseExit(Sender: TObject);
    procedure tbVolumeDblClick(Sender: TObject);
    procedure ToneClick(Sender: TObject);
    procedure ToneChange(Sender: TObject);
    procedure ToneDblClick(Sender: TObject);

  private
    FWorker: TDenonRequest;
    FUpdatingTone: Boolean;
    FToneKnown: Boolean;
    FToneEnabled: Boolean;
    FDesiredToneEnabled: Boolean;
    FDesiredBass: Integer;
    FDesiredTreble: Integer;
    FTonePending: Boolean;
    FBassPending: Boolean;
    FTreblePending: Boolean;
    FToneReadPending: Boolean;
    FToneRequest: Boolean;
    FToneMode: string;
    FDynamicEq: Boolean;
    FPowerText: string;
    FZone2PowerText: string;
    FMainZonePending: Boolean;
    FMainZoneDesired: Boolean;
    FZone2Pending: Boolean;
    FZone2Desired: Boolean;
    FZoneReadPending: Boolean;
    FZoneRequest: Boolean;
    FZoneRequestKind: Integer;
    FZoneRequestTarget: Boolean;
    FStartupZoneReadAttempts: Integer;
    FExpectedPowerReply: string;
    FVolumeText: string;
    FVolumePending: Boolean;
    FVolumeReadPending: Boolean;
    FInitialVolumeRead: Boolean;
    FVolumeRequest: Boolean;
    FUpdatingVolume: Boolean;
    FVolumeReady: Boolean;
    FDesiredVolume: Integer;
    FBalancePending: Boolean;
    FBalanceReadPending: Boolean;
    FBalanceRequest: Boolean;
    FBalanceReadingBase: Boolean;
    FStartupBalanceReadAttempts: Integer;
    FBalanceKnown: Boolean;
    FUpdatingBalance: Boolean;
    FBalanceBaseHost: string;
    FBalanceBaseInput: string;
    FBalanceLeft: Integer;
    FBalanceRight: Integer;
    FBalanceReplyLeft: Integer;
    FBalanceReplyRight: Integer;
    FBalanceLeftReceived: Boolean;
    FBalanceRightReceived: Boolean;
    FDesiredBalance: Integer;
    FMuteText: string;
    FInputText: string;
    FAudioServer: THEOSAudioServer;
    FLoopback: THEOSLoopback;
    FHeos: THeosRequest;
    FWaitingForCapture: Boolean;
    FStreamReceiver: string;
    FStreamDescription: string;
    FLastServerError: string;
    FLastHeosAction: THeosAction;
    FPlaybackState: string;
    FPlaybackFile: string;
    FSelectedFile: string;
    FTrackDurationMs: Int64;
    FReceiverDurationMs: Int64;
    FPlayedMs: Int64;
    FActiveSeekMs: Int64;
    FSeekGuardUntil: UInt64;
    FProgressTick: UInt64;
    FProgressSequence: Cardinal;
    FClockRunning: Boolean;
    FTrackInfoThreads: TList<THEOSTrackInfo>;
    FProgressMonitors: TList<THeosProgressMonitor>;
    FProgressMonitor: THeosProgressMonitor;
    FStreamActions: TList<THEOSStreamAction>;
    FDesiredPlaybackState: string;
    FDesiredPlaybackFile: string;
    FProcessingStreamActions: Boolean;
    FDiscovery: THEOSDiscovery;
    FDevices: TArray<THEOSDevice>;
    FPlaylistEditor: THEOSPlaylistEditor;
    FPlaylistDb: TRDJPlaylistDb;
    FPlaylistManager: TRDJPlaylistManager;
    FPlaylistPopupVisible: Boolean;
    FQueue: TStringList;
    FQueueIndex: Integer;
    FQueueActive: Boolean;
    FQueueIsPlaylist: Boolean;
    FQueueSawPlaying: Boolean;
    FQueueNextPending: Boolean;
    FQueueStarting: Boolean;
    FQueuePollTicks: Integer;

    procedure DiscoveryFinished(Sender: TObject);

    procedure PlayPlaylist(Sender: TObject;
                           Playlist: TRDJPlaylist;
                           StartIndex: Integer);

    procedure LoadPlaylistForDenon(Sender: TObject;
                                   Playlist: TRDJPlaylist;
                                   StartIndex: Integer);

    procedure PlayQueueIndex(Index: Integer);
    procedure ShuffleUpcoming(StartIndex: Integer);
    procedure EnsurePlaylistManager();
    procedure StartStreamAction(Action: Integer);
    procedure ExecuteStreamAction(Action: Integer);
    procedure ProcessStreamActions();
    procedure StreamActionsReady(var message: TMessage); message WM_APP + $126;
    function RequestedPlaybackState(): string;
    procedure SelectAudioFile(const FileName: string);
    procedure UpdatePlaybackProgress();
    procedure UpdateProgressDisplay();
    procedure StartProgressMonitor();
    function ProgressPositionAt(X, Y: Integer; out PositionMs: Int64): Boolean;
    function CanSeekPlayback(): Boolean;

    procedure StopLocalStream();
    procedure HeosFinished(Sender: TObject);
    procedure SendHeos(Action: THeosAction;
                       const Url: string = '';
                       PositionMs: Int64 = 0);
    procedure UpdateStreamButtons();
    function ValidAddress(): Boolean;

    procedure StartRequest(const Commands: array of string;
                            const ExpectedPowerReply: string = '');

    procedure RequestFinished(Sender: TObject);
    procedure ParseStatus(const Line: string);
    procedure SetVolumeBusy(Busy: Boolean);
    procedure StartBalanceRequest();
    procedure StartToneRequest();
    procedure UpdateToneDisplay();
    procedure UpdateBalanceDisplay();

    procedure QueueZoneChange(MainZone: Boolean;
                              Active: Boolean);

    procedure StartZoneRequest();
    procedure UpdateZoneButtons();
    procedure RetryStartupZoneRead();
    function ReceiverActionsPending(): Boolean;
    function VolumeCaption(HalfSteps: Integer): string;

  public

    destructor Destroy(); override;

    property AudioFileName: string read FSelectedFile write SelectAudioFile;

  end;

  function GetTickCount64(): UInt64; stdcall;

var
  HEOSForm: THEOSForm;


implementation

{$R *.dfm}

uses

  {System}
  WinApi.Windows,
  WinApi.ShellAPI,
  {System}
  System.StrUtils,
  System.Types,
  WinApi.ActiveX.ObjBase,
  WinApi.ComBaseApi,
  WinApi.MediaFoundationApi.MfApi,
  {Application}
  HEOSSockets,
  RDJ.FilenameParser,
  RDJ.TagReader,
  LWFileBrowserExDlg;


const

  Kernel32Lib = 'kernel32.dll';

  SourceCommands: array[0..7] of string = ('SITV',
                                           'SIBD',
                                           'SIGAME',
                                           'SIMPLAY',
                                           'SISAT/CBL',
                                           'SICD',
                                           'SITUNER',
                                           'SINET');

constructor THEOSTrackInfo.Create(const FileName: string);
begin

  inherited Create(True);

  FreeOnTerminate := False;
  FFileName := FileName;
end;


procedure THEOSTrackInfo.Execute();
var
  Track: TRDJTrack;

begin

  if Failed(CoInitializeEx(nil,
            COINIT_MULTITHREADED)) then
    Exit;

  try
    if Failed(MFStartup(MF_VERSION,
                        MFSTARTUP_FULL)) then
      Exit;

    try
      try
        Track := RDJEmptyTrack;

        if not Terminated and ReadDurationMf(FFileName,
                                             Track) then
          FDurationMs := Track.DurationMs;

      except
        // Unknown duration is valid for unsupported files and live sources.
      end;

    finally
      MFShutdown;
    end;

  finally
    CoUninitialize;
  end;
end;


function PlaybackTimeText(Milliseconds: Int64): string;
var
  Seconds: Int64;

begin

  if (Milliseconds < 0) then
    Milliseconds := 0;

  Seconds := Milliseconds div 1000;
  Result := Format('%.2d:%.2d:%.2d', [Seconds div 3600,
                                      (Seconds div 60) mod 60,
                                      Seconds mod 60]);
end;


procedure THEOSForm.SelectAudioFile(const FileName: string);
var
  Artist: string;
  Title: string;
  Info: THEOSTrackInfo;
  Changed: Boolean;

begin

  Changed := not SameFileName(FSelectedFile,
                              FileName);
  FSelectedFile := FileName;
  TFileNameParser.ParseArtistTitleFromFileName(FileName,
                                               Artist,
                                               Title);

  lblStreamInfo.Caption := TFileNameParser.BuildIceCastSongText(Artist,
                                                                Title,
                                                                ChangeFileExt(ExtractFileName(FileName),
                                                                ''));
  lblStreamInfo.Hint := FileName;

  if Changed then
    begin
      FTrackDurationMs := 0;
      FReceiverDurationMs := 0;
      FPlayedMs := 0;
      FClockRunning := False;
      FProgressTick := GetTickCount64;

      if FileExists(FileName) then
        begin
          Info := THEOSTrackInfo.Create(FileName);
          FTrackInfoThreads.Add(Info);
          Info.Start;
        end;
    end;

  UpdateProgressDisplay();
end;


procedure THEOSForm.StartProgressMonitor();
begin

  if Assigned(FProgressMonitor) then
    FProgressMonitor.Terminate;

  FProgressMonitor := THeosProgressMonitor.Create(FStreamReceiver);
  FProgressMonitors.Add(FProgressMonitor);
  FProgressSequence := 0;
  FProgressMonitor.Start;
end;


function THEOSForm.ProgressPositionAt(X, Y: Integer;
                                        out PositionMs: Int64): Boolean;
var
  DurationMs: Int64;
  Coordinate: Integer;
  Extent: Integer;
  Inset: Integer;

begin

  Result := False;
  PositionMs := 0;
  DurationMs := FTrackDurationMs;

  if (FReceiverDurationMs > 0) then
    DurationMs := FReceiverDurationMs;

  if Assigned(FLoopback) or (DurationMs <= 0) then
    Exit;

  Inset := pbProgress.Padding;

  if (pbProgress.Orientation = poHorizontal) then
    begin
      Coordinate := X - Inset;
      Extent := pbProgress.ClientWidth - 2 * Inset;
    end
  else
    begin
      Coordinate := pbProgress.ClientHeight - Inset - Y;
      Extent := pbProgress.ClientHeight - 2 * Inset;
    end;

  if (Extent <= 0) then
    Exit;

  if (Coordinate < 0) then
    Coordinate := 0;
  if (Coordinate > Extent) then
    Coordinate := Extent;

  PositionMs := Round((Coordinate / Extent) * DurationMs / 1000) * 1000;

  // Avoid seeking to EOF, which can advance a playing playlist.
  if (PositionMs >= DurationMs) then
    PositionMs := DurationMs - 1;

  PositionMs := (PositionMs div 1000) * 1000;
  Result := True;
end;


function THEOSForm.CanSeekPlayback(): Boolean;
begin

  Result := Assigned(FAudioServer) and not Assigned(FLoopback) and
            (FPlaybackFile <> '') and
            SameFileName(FSelectedFile, FPlaybackFile) and
            ((FPlaybackState = 'play') or (FPlaybackState = 'pause')) and
            (RequestedPlaybackState() <> 'stop');
end;


procedure THEOSForm.pbProgressMouseMove(Sender: TObject;
                                         Shift: TShiftState;
                                         X, Y: Integer);
var
  PositionMs: Int64;
  P: TPoint;

begin

  if not ProgressPositionAt(X, Y, PositionMs) then
    begin
      lblSeekTime.Visible := False;
      SeekHintTimer.Enabled := False;
      Exit;
    end;

  lblSeekTime.Caption := ' ' + PlaybackTimeText(PositionMs) + ' ';
  P := lblSeekTime.Parent.ScreenToClient(pbProgress.ClientToScreen(Point(X, pbProgress.Height)));
  P.X := P.X - lblSeekTime.Width div 2;

  if (P.X > lblSeekTime.Parent.ClientWidth - lblSeekTime.Width - 2) then
    P.X := lblSeekTime.Parent.ClientWidth - lblSeekTime.Width - 2;
  if (P.X < 2) then
    P.X := 2;

  lblSeekTime.Left := P.X;
  lblSeekTime.Top := P.Y + 1;
  lblSeekTime.BringToFront();
  lblSeekTime.Visible := True;
  SeekHintTimer.Enabled := True;
end;


procedure THEOSForm.SeekHintTick(Sender: TObject);
var
  P: TPoint;

begin

  P := pbProgress.ScreenToClient(Mouse.CursorPos);

  if not pbProgress.Showing or (P.X < 0) or (P.Y < 0) or
     (P.X >= pbProgress.ClientWidth) or (P.Y >= pbProgress.ClientHeight) or
     (WindowState = wsMinimized) then
    begin
      lblSeekTime.Visible := False;
      SeekHintTimer.Enabled := False;
    end;
end;


procedure THEOSForm.pbProgressMouseUp(Sender: TObject;
                                       Button: TMouseButton;
                                       Shift: TShiftState;
                                       X, Y: Integer);
var
  PositionMs: Int64;
  Command: THEOSStreamAction;
  i: Integer;

begin

  if (Button <> mbLeft) or not CanSeekPlayback() then
    Exit;

  if not ProgressPositionAt(X,
                            Y,
                            PositionMs) then
    Exit;

  Command := Default(THEOSStreamAction);
  Command.Action := 5;
  Command.PositionMs := PositionMs;
  Command.FileName := FPlaybackFile;
  Command.Receiver := FStreamReceiver;

  // Keep the latest click while a transport request is in flight.
  for i := FStreamActions.Count - 1 downto 0 do
    if (FStreamActions[i].Action = 5) then
      FStreamActions.Delete(i);

  FStreamActions.Add(Command);
  StreamActionTimer.Enabled := True;
  ProcessStreamActions();
end;


procedure THEOSForm.UpdateProgressDisplay();
var
  DurationMs: Int64;
begin

  if not Assigned(pbProgress) or not Assigned(lblDuration) or not Assigned(lblPlayed) then
    Exit;

  DurationMs := FTrackDurationMs;

  if (FReceiverDurationMs > 0) then
    DurationMs := FReceiverDurationMs;

  if Assigned(FLoopback) then
    lblDuration.Caption := 'Duration: Live'
  else
    if (DurationMs > 0) then
      lblDuration.Caption := 'Duration: ' + PlaybackTimeText(DurationMs)
    else
      if (FSelectedFile <> '') then
        lblDuration.Caption := 'Duration: --:--:--'
      else
        lblDuration.Caption := 'Duration: 00:00:00';

  if not Assigned(FLoopback) and (DurationMs > 0) and (FPlayedMs > DurationMs) then
    FPlayedMs := DurationMs;

  lblPlayed.Caption := 'Played: ' + PlaybackTimeText(FPlayedMs);

  if not Assigned(FLoopback) and (DurationMs > 0) then
    pbProgress.Position := Round((FPlayedMs / DurationMs) * pbProgress.Maximum)
  else
    pbProgress.Position := 0;
end;


procedure THEOSForm.UpdatePlaybackProgress();
var
  I: Integer;
  Info: THEOSTrackInfo;
  Monitor: THEOSProgressMonitor;
  Progress: THEOSProgress;
  Tick: UInt64;
  CurrentSource: Boolean;

begin

  Tick := GetTickCount64;

  if FClockRunning then
    Inc(FPlayedMs,
        Int64(Tick - FProgressTick));

  FProgressTick := Tick;

  for I := FTrackInfoThreads.Count - 1 downto 0 do
    begin
      Info := FTrackInfoThreads[I];

      if not Info.Finished then
        Continue;

      if SameFileName(Info.FileName,
                      FSelectedFile) then
        FTrackDurationMs := Info.DurationMs;

      FTrackInfoThreads.Delete(I);
      Info.Free;
    end;

  for I := FProgressMonitors.Count - 1 downto 0 do
    begin
      Monitor := FProgressMonitors[I];

      if not Monitor.Finished then
        Continue;

      if (Monitor = FProgressMonitor) then
        FProgressMonitor := nil;

      FProgressMonitors.Delete(I);
      Monitor.Free;
    end;

  CurrentSource := Assigned(FLoopback) or ((FPlaybackFile <> '') and SameFileName(FSelectedFile,
                                                                                  FPlaybackFile));

  if CurrentSource and Assigned(FProgressMonitor) then
    begin
      Progress := FProgressMonitor.Snapshot();

      if (Progress.Sequence <> FProgressSequence) then
        begin
          FProgressSequence := Progress.Sequence;
          if (Tick >= FSeekGuardUntil) or
             (Abs(Progress.PositionMs - FActiveSeekMs) <= 3000) then
            begin
              FPlayedMs := Progress.PositionMs;
              FSeekGuardUntil := 0;
            end;
          FReceiverDurationMs := Progress.DurationMs;
        end;
    end;

  FClockRunning := CurrentSource and
                   (FPlaybackState = 'play') and
                   Assigned(FAudioServer) and
                   (FAudioServer.Requests > 0);

  UpdateProgressDisplay();
end;


procedure THEOSForm.FormCreate(Sender: TObject);
begin

  FQueue := TStringList.Create;
  FStreamActions := TList<THEOSStreamAction>.Create;
  FTrackInfoThreads := TList<THEOSTrackInfo>.Create;
  FProgressMonitors := TList<THEOSProgressMonitor>.Create;
  FProgressTick := GetTickCount64;
  pbProgress.Minimum := 0;
  pbProgress.Maximum := 1000;
  UpdateProgressDisplay();
  FQueueIndex := -1;
  FPlaybackState := 'stop';
  Randomize;
  PlayerClick(Self);

  FPowerText := '?';
  FZone2PowerText := '?';
  UpdateZoneButtons();
  FVolumeText := '?';
  lblVolumePerc.Caption := '--';
  lblBalance.Caption := 'Balance: --';
  FMuteText := '?';
  FInputText := '?';
  FVolumeReady := True;
  UpdateToneDisplay();
end;


procedure THEOSForm.FormShow(Sender: TObject);
begin

  if FInitialVolumeRead then
    Exit;

  FInitialVolumeRead := True;
  FVolumeReadPending := True;
  FBalanceReadPending := True;
  FZoneReadPending := True;
  FToneReadPending := True;
  VolumeTimer.Enabled := True;
  VolumeTick(nil);
end;


destructor THEOSForm.Destroy();
var
  Info: THEOSTrackInfo;
  Monitor: THeosProgressMonitor;

begin

  if Assigned(StreamActionTimer) then
    StreamActionTimer.Enabled := False;

  if Assigned(VolumeTimer) then
    VolumeTimer.Enabled := False;

  if Assigned(FDiscovery) then
    begin
      FDiscovery.OnTerminate := nil;
      FDiscovery.Terminate;
      FDiscovery.WaitFor;
      FreeAndNil(FDiscovery);
    end;

  FreeAndNil(FPlaylistEditor);
  FreeAndNil(FPlaylistManager);
  FreeAndNil(FPlaylistDb);
  FreeAndNil(FQueue);

  if Assigned(StreamTimer) then
    StreamTimer.Enabled := False;

  if Assigned(FHeos) then
    begin
      FHeos.OnTerminate := nil;
      FHeos.Terminate;
      FHeos.WaitFor;
      FreeAndNil(FHeos);
    end;

  StopLocalStream();

  if Assigned(FProgressMonitors) then
    begin
      for Monitor in FProgressMonitors do
        Monitor.Terminate;

      for Monitor in FProgressMonitors do
        Monitor.Free;

      FreeAndNil(FProgressMonitors);
    end;

  if Assigned(FTrackInfoThreads) then
    begin
      for Info in FTrackInfoThreads do Info.Terminate;
      for Info in FTrackInfoThreads do
        begin
          Info.WaitFor;
          Info.Free;
        end;
      FreeAndNil(FTrackInfoThreads);
    end;

  FreeAndNil(FStreamActions);

  if Assigned(FWorker) then
    begin
      FWorker.OnTerminate := nil;
      FWorker.Terminate;
      FWorker.WaitFor();
      FWorker.Free;
    end;

  inherited;
end;


procedure THEOSForm.BrowseMusicClick(Sender: TObject);
var
  FileName: TFileName;
  FileURI: string;
  Duration: string;

begin

  if BrowseLWFileEx(Self,
                    fbxAudio,
                    FileName,
                    FileURI,
                    Duration,
                    ExtractFilePath(FSelectedFile)) then
    SelectAudioFile(FileName);
end;


procedure THEOSForm.StopLocalStream();
begin

  if Assigned(FProgressMonitor) then
    begin
      FProgressMonitor.Terminate;
      FProgressMonitor := nil;
    end;

  FPlayedMs := 0;
  FReceiverDurationMs := 0;
  FSeekGuardUntil := 0;
  lblSeekTime.Visible := False;
  SeekHintTimer.Enabled := False;
  FClockRunning := False;
  FProgressSequence := 0;
  FProgressTick := GetTickCount64;
  FWaitingForCapture := False;
  FreeAndNil(FLoopback);
  FreeAndNil(FAudioServer);

  if Assigned(btnStreamWinAudio) then
    btnStreamWinAudio.Checked := False;

  FStreamDescription := '';
  FLastServerError := '';
  FPlaybackState := 'stop';
  FPlaybackFile := '';

  if (FSelectedFile <> '') then
    SelectAudioFile(FSelectedFile);

  UpdateProgressDisplay();
end;


procedure THEOSForm.UpdateStreamButtons();
var
  Busy: Boolean;

begin

  Busy := FWaitingForCapture or (Assigned(FHeos) and not FHeos.Finished);

  btnStreamWinAudio.Enabled := not Busy;
  btnStreamWinAudio.Checked := Assigned(FAudioServer) and Assigned(FLoopback) and
                                FLoopback.Ready and FLoopback.Initialized and
                                not FLoopback.Finished and not FWaitingForCapture and
                                (FPlaybackState = 'play') and
                                (RequestedPlaybackState() = 'play');


  btnPrevious.Enabled := (not Busy) and (FQueueIndex > 0);
  btnNext.Enabled := (not Busy) and Assigned(FQueue) and (FQueueIndex + 1 < FQueue.Count);
  btnStop.Enabled := True;
  btnPlayPause.Enabled := not Assigned(FLoopback) and not FWaitingForCapture;

  btnPrevious.Enabled := not Busy and Assigned(FQueue) and
                       ((FQueueIndex > 0) or (btnLoop.Checked and (FQueue.Count > 0)));

  btnNext.Enabled := not Busy and Assigned(FQueue) and
                     ((FQueueIndex + 1 < FQueue.Count) or
                      (btnLoop.Checked and (FQueue.Count > 0)));

  if (RequestedPlaybackState() = 'play') then
    btnPlayPause.Caption := 'Pause'
  else
    if RequestedPlaybackState() = 'pause' then
      btnPlayPause.Caption := 'Resume'
    else
      btnPlayPause.Caption := 'Play';

  btnPlayList.Checked := FQueueIsPlaylist and
                         FQueueActive and
                         (FQueue.Count > 0) and
                         Assigned(FAudioServer) and not
                         Assigned(FLoopback) and
                         (FPlaybackState = 'play') and
                         (RequestedPlaybackState() = 'play');
end;


procedure THEOSForm.SendHeos(Action: THeosAction;
                              const Url: string;
                              PositionMs: Int64);
begin

  if Assigned(FHeos) and not FHeos.Finished then
    Exit;

  FreeAndNil(FHeos);
  FLastHeosAction := Action;
  if (Action = haSeek) then
    FActiveSeekMs := PositionMs;

  FHeos := THeosRequest.Create(FStreamReceiver,
                               Action,
                               Url,
                               1255,
                               PositionMs);

  FHeos.OnTerminate := HeosFinished;

  if (Action <> haGetState) then
    lblStreamInfo.Caption := 'Contacting HEOS ...';

  FHeos.Start();
  UpdateStreamButtons();
end;


procedure THEOSForm.HeosFinished(Sender: TObject);
begin

  UpdatePlaybackProgress();
  // Dispatch after OnTerminate returns; the request cannot be freed here.
  PostMessage(Handle, WM_APP + $126, 0, 0);
  if (FLastHeosAction = haGetState) then
    begin
      if (FHeos.ErrorText = '') then
        FPlaybackState := FHeos.PlayState;

      if (FHeos.ErrorText <> '') then
        begin
          FQueueActive := False;
          memFLog.Lines.Add('! Playlist state: ' + FHeos.ErrorText);
        end
      else
        if (FHeos.PlayState = 'play') then
          FQueueSawPlaying := True
      else
        if (FHeos.PlayState = 'stop') and FQueueSawPlaying and
           (FStreamActions.Count = 0) and (FDesiredPlaybackState <> 'stop') then
          FQueueNextPending := True;

      UpdatePlaybackProgress();
      Exit;
  end;

  if (FHeos.ErrorText <> '') then
    begin
      memFLog.Lines.Add('! HEOS: ' + FHeos.ErrorText);
      lblStreamInfo.Caption := FHeos.ErrorText;

      if (FLastHeosAction = haPlayUrl) then
        begin
          FQueueActive := False;
          StopLocalStream();
          if (FStreamActions.Count > 0) and (FStreamActions[0].Action <> 4) then
            FStreamActions.Clear;
        end;
    end
  else
    begin
      case FLastHeosAction of
        haSeek: begin
                  FPlayedMs := FActiveSeekMs;
                  FProgressTick := GetTickCount64;
                  FSeekGuardUntil := FProgressTick + 2500;
                end;
        haPlayUrl, haResume: FPlaybackState := 'play';
        haPause: FPlaybackState := 'pause';
        haStop: FPlaybackState := 'stop';
      end;
      if (FLastHeosAction = haPlayUrl) then
        begin
          StartProgressMonitor();
          FToneReadPending := True;
          VolumeTimer.Enabled := True;
        end;

      memFLog.Lines.Add('HEOS: ' + FHeos.Summary);
      lblStreamInfo.Caption := FHeos.Summary;
    end;

  UpdatePlaybackProgress();
end;


procedure THEOSForm.StreamTick(Sender: TObject);
var
  CaptureError: string;
  ServerError: string;

begin

  UpdatePlaybackProgress();
  if Assigned(FLoopback) and FLoopback.Ready then
    begin
      if ((not FLoopback.Initialized) or
         FLoopback.Finished) and
         (FLoopback.ErrorText <> '') then
        begin
          CaptureError := FLoopback.ErrorText;
          memFLog.Lines.Add('! Windows audio: ' + CaptureError);

          if Assigned(FHeos) and not FHeos.Finished then
           begin
              FHeos.OnTerminate := nil;
              FHeos.Terminate;
              FHeos.WaitFor;
              FreeAndNil(FHeos);
           end;

          StopLocalStream();
          lblStreamInfo.Caption := CaptureError;
        end
      else
       if FWaitingForCapture then
         begin
           FWaitingForCapture := False;
           SendHeos(haPlayUrl,
                    FAudioServer.Url);
         end;
    end;

  if Assigned(FAudioServer) and
     Assigned(FHeos) and
     FHeos.Finished and
     (FHeos.ErrorText = '') then
    lblStreamInfo.Caption := FStreamDescription + ' | HTTP requests: ' + IntToStr(FAudioServer.Requests);

  if Assigned(FAudioServer) then
    begin
      ServerError := FAudioServer.LastError();

      if (ServerError <> '') then
        begin
          lblStreamInfo.Caption := FStreamDescription + ' | ' + ServerError;

          if (ServerError <> FLastServerError) then
            memFLog.Lines.Add('! Audio HTTP: ' + ServerError);
        end;

      FLastServerError := ServerError;
    end;

  ProcessStreamActions();
  UpdateStreamButtons();

  if FQueueNextPending and Assigned(FHeos) and FHeos.Finished then
    begin
      FQueueNextPending := False;
      if FQueueActive and chkAutoNextCheck.Checked then
        PlayQueueIndex(FQueueIndex + 1);
    end;

  if (FStreamActions.Count = 0) and (FDesiredPlaybackState = '') and
     Assigned(FAudioServer) and not Assigned(FLoopback) and
     (not Assigned(FHeos) or FHeos.Finished) then
    begin
      Inc(FQueuePollTicks);

      if (FQueuePollTicks >= 5) then
        begin
          FQueuePollTicks := 0;
          SendHeos(haGetState);
        end;
    end;
end;


procedure THEOSForm.tbVolumeDblClick(Sender: TObject);
begin

  tbVolume.AnimateTrackBarToPosition(0,
                                     2);
end;


procedure THEOSForm.FindHEOSDEviceClick(Sender: TObject);
begin

  if not edHost.Enabled then
    Exit;

  if Assigned(FDiscovery) and not FDiscovery.Finished then
    Exit;

  FreeAndNil(FDiscovery);
  btnFindHEOSDevice.Enabled := False;
  btnFindHEOSDevice.Caption := 'Searching ...';
  FStatus.Caption := 'Searching local network interfaces for HEOS devices ...';
  FDiscovery := THEOSDiscovery.Create;
  FDiscovery.OnTerminate := DiscoveryFinished;
  FDiscovery.Start;
end;


procedure THEOSForm.DiscoveryFinished(Sender: TObject);
var
  I: Integer;
  Selected: Integer;

begin

  FDevices := Copy(FDiscovery.Devices);
  cbxHEOSDevices.Items.Clear();
  Selected := -1;

  for I := 0 to Length(FDevices) - 1 do
    begin
      cbxHEOSDevices.Items.Add(FDevices[I].Name + ' - ' + FDevices[I].Address);

      if (FDevices[I].Address = Trim(edHost.Text)) then
        Selected := I;

      memFLog.Lines.Add('Found device: ' + FDevices[I].Name + ' (' +
                      FDevices[I].Model + ') ' + FDevices[I].Address);
    end;

  if (Length(FDevices) = 1) then
    Selected := 0;

  cbxHEOSDevices.Visible := Length(FDevices) > 0;
  cbxHEOSDevices.ItemIndex := Selected;

  if Selected >= 0 then
    HEOSDeviceChange(cbxHEOSDevices);

  if (FDiscovery.ErrorText <> '') then
    FStatus.Caption := 'Discovery: ' + FDiscovery.ErrorText
  else
    if Length(FDevices) = 0 then
      FStatus.Caption := 'No device replied. Check the receiver is on the same LAN; the IP can still be entered manually.'
    else
      if (Selected < 0) then
        FStatus.Caption := 'Several Denon devices found. Select the receiver in the list above.'
      else
        FStatus.Caption := 'Device found. Receiver IP updated to ' + edHost.Text;

  btnFindHEOSDevice.Caption := 'Find Denon';
  btnFindHEOSDevice.Enabled := True;
end;


procedure THEOSForm.HEOSDeviceChange(Sender: TObject);
var
  Index: Integer;

begin

  Index := cbxHEOSDevices.ItemIndex;
  if edHost.Enabled and (Index >= 0) and (Index < Length(FDevices)) then
    edHost.Text := FDevices[Index].Address;
end;


procedure THEOSForm.PlaylistClick(Sender: TObject);
begin

  if (Sender = btnPlayList) then
    begin
      UpdateStreamButtons();
      PlaylistHover(Sender);
      Exit;
    end;

  if (FPlaylistEditor = nil) then
    begin
      FPlaylistEditor := THEOSPlaylistEditor.Create(Self);
      FPlaylistEditor.OnPlay := PlayPlaylist;
      FPlaylistEditor.OnLoad := LoadPlaylistForDenon;
    end;

  FPlaylistEditor.Show();
  FPlaylistEditor.BringToFront();
end;


procedure THEOSForm.EnsurePlaylistManager();
begin

  if not Assigned(FPlaylistDb) then
    FPlaylistDb := TRDJPlaylistDb.Create;

  if not FPlaylistDb.IsOpen() then
    FPlaylistDb.Open(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'Data\RDJLibrary.db');

  if not Assigned(FPlaylistManager) then
    FPlaylistManager := TRDJPlaylistManager.Create(FPlaylistDb, nil);
end;


procedure THEOSForm.PlaylistPopup(Sender: TObject);
var
  Playlists: TList<TRDJPlaylistInfo>;
  I: Integer;
  Item: TMenuItem;

begin

  pmPlaylists.Items.Clear;
  pmPlaylists.AutoHotkeys := maManual;
  Playlists := nil;

  try
    try
      EnsurePlaylistManager();
      Playlists := FPlaylistManager.GetAllPlaylists();

      if (Playlists.Count = 0) then
        begin
          Item := TMenuItem.Create(pmPlaylists);
          Item.Caption := '(No playlists found)';
          Item.Enabled := False;
          pmPlaylists.Items.Add(Item);
        end;

      for I := 0 to Playlists.Count - 1 do
        begin
          Item := TMenuItem.Create(pmPlaylists);
          Item.Caption := StringReplace(Playlists[I].Name,
                                        '&',
                                        '&&',
                                        [rfReplaceAll]);

          Item.Tag := Playlists[I].PlaylistID;
          Item.OnClick := PlaylistPopupItemClick;
          pmPlaylists.Items.Add(Item);
        end;

    except
      on E: Exception do
        begin
          pmPlaylists.Items.Clear;
          Item := TMenuItem.Create(pmPlaylists);
          Item.Caption := '(Playlists unavailable)';
          Item.Enabled := False;
          pmPlaylists.Items.Add(Item);
          memFLog.Lines.Add('! Playlists: ' + E.Message);
          lblStreamInfo.Caption := E.Message;
        end;
    end;

  finally
    Playlists.Free;
  end;

  Item := TMenuItem.Create(pmPlaylists);
  Item.Caption := '-';
  pmPlaylists.Items.Add(Item);
  Item := TMenuItem.Create(pmPlaylists);
  Item.Caption := 'Edit playlists...';
  Item.OnClick := PlaylistClick;
  pmPlaylists.Items.Add(Item);
end;


procedure THEOSForm.PlaylistHover(Sender: TObject);
var
  P: TPoint;

begin

  if FPlaylistPopupVisible or (csDesigning in ComponentState) then
    Exit;

  FPlaylistPopupVisible := True;

  try
    P := btnPlayList.ClientToScreen(Point(0,
                                          btnPlayList.Height));
    pmPlaylists.Popup(P.X,
                      P.Y);

  finally
    FPlaylistPopupVisible := False;
    UpdateStreamButtons();
  end;
end;


procedure THEOSForm.PlaylistPopupItemClick(Sender: TObject);
var
  Playlist: TRDJPlaylist;

begin

  if not (Sender is TMenuItem) or (TMenuItem(Sender).Tag <= 0) then
    Exit;

  Playlist := nil;

  try
    try
      if Assigned(FHeos) and not FHeos.Finished then
        raise Exception.Create('Wait for the current receiver request to finish');

      EnsurePlaylistManager();
      Playlist := FPlaylistManager.LoadPlaylist(TMenuItem(Sender).Tag);

      if (Playlist.Count = 0) then
        begin
          lblStreamInfo.Caption := 'Selected playlist is empty.';
          Exit;
        end;

      chkAutoNextCheck.Checked := True;
      PlayPlaylist(Sender,
                   Playlist,
                   0);

    except
      on E: Exception do
        begin
          memFLog.Lines.Add('! Playlists: ' + E.Message);
          lblStreamInfo.Caption := E.Message;
        end;
    end;

  finally
    Playlist.Free;
    UpdateStreamButtons();
  end;
end;


procedure THEOSForm.MainCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

  CanClose := True;

  if Assigned(FPlaylistEditor) then
    CanClose := FPlaylistEditor.ConfirmSave();
end;


procedure THEOSForm.LoadPlaylistForDenon(Sender: TObject;
                                          Playlist: TRDJPlaylist;
                                          StartIndex: Integer);
var
  I: Integer;

begin

  StopLocalStream();
  FQueue.Clear();
  FQueueIsPlaylist := Playlist.Count > 0;

  for I := 0 to Playlist.Count - 1 do
    FQueue.Add(Playlist[I].Track.FullPath);

  FQueueIndex := StartIndex;

  if btnShuffle.Checked then
    ShuffleUpcoming(StartIndex + 1);

  FQueueActive := False;
  FQueueNextPending := False;

  if (StartIndex >= 0) and (StartIndex < FQueue.Count) then
    SelectAudioFile(FQueue[StartIndex]);

  UpdateStreamButtons();
end;


procedure THEOSForm.PlayPlaylist(Sender: TObject;
                                  Playlist: TRDJPlaylist;
                                  StartIndex: Integer);
var
  I: Integer;

begin

  if Assigned(FHeos) and not FHeos.Finished then
    raise Exception.Create('Wait for the current receiver request to finish');

  FQueue.Clear();
  FQueueIsPlaylist := Playlist.Count > 0;

  for I := 0 to Playlist.Count - 1 do
    FQueue.Add(Playlist[I].Track.FullPath);

  if btnShuffle.Checked then
    ShuffleUpcoming(StartIndex + 1);

  PlayQueueIndex(StartIndex);
end;


procedure THEOSForm.PlayQueueIndex(Index: Integer);
begin

  if (Index >= FQueue.Count) then
    begin
      if btnLoop.Checked and (FQueue.Count > 0) then
        begin
          if btnShuffle.Checked then
            ShuffleUpcoming(0);

          PlayQueueIndex(0);
          Exit;
        end;

      FQueueActive := False;
      StopLocalStream();
      lblStreamInfo.Caption := 'Playlist finished.';
      UpdateStreamButtons();
      Exit;
    end;

  if (Index < 0) then
    begin
      if btnLoop.Checked and (FQueue.Count > 0) then
        PlayQueueIndex(FQueue.Count - 1);
      Exit;
    end;

  if not FileExists(FQueue[Index]) then
    begin
      FQueueActive := False;
      lblStreamInfo.Caption := 'Playlist stopped: missing file ' + FQueue[Index];
      UpdateStreamButtons();
      Exit;
    end;

  FQueueIndex := Index;
  FQueueActive := True;
  FQueueSawPlaying := False;
  FQueueNextPending := False;
  FQueuePollTicks := 0;
  SelectAudioFile(FQueue[Index]);
  FQueueStarting := True;

  try
    StartStreamAction(0);

  finally
    FQueueStarting := False;
  end;

  memFLog.Lines.Add(Format('Playlist track %d / %d: %s',
                        [Index + 1, FQueue.Count, ExtractFileName(FQueue[Index])]));
end;


procedure THEOSForm.TrackClick(Sender: TObject);
begin

  if Assigned(FHeos) and not FHeos.Finished then
    Exit;

  PlayQueueIndex(FQueueIndex + TComponent(Sender).Tag);
end;


function THEOSForm.ValidAddress(): Boolean;
var
  Parts: TArray<string>;
  Part: string;
  Value, I: Integer;

begin

  Result := False;
  Parts := Trim(edHost.Text).Split(['.']);

  if (Length(Parts) <> 4) then
    Exit;

  for Part in Parts do
    begin
      if (Length(Part) = 0) or (Length(Part) > 3) then
        Exit;

      for I := 1 to Length(Part) do
        if not CharInSet(Part[I],
                         ['0'..'9']) then
          Exit;

        if not TryStrToInt(Part,
                           Value) then
          Exit;

        if (Value < 0) or (Value > 255) then
          Exit;
    end;
  Result := True;
end;


procedure THEOSForm.StartRequest(const Commands: array of string;
                                   const ExpectedPowerReply: string);
var
  Command: string;

begin

  if Assigned(FWorker) and (not FWorker.Finished) then
    Exit;

  if not ValidAddress then
    begin
      ShowMessage('Enter an IPv4 address, for example 192.168.50.103.');
      Exit;
    end;

  FreeAndNil(FWorker);
  FExpectedPowerReply := ExpectedPowerReply;
  FVolumeText := '?';
  FMuteText := '?';
  FInputText := '?';

  FWorker := TDenonRequest.Create(Trim(edHost.Text),
                                  Commands);
  FWorker.OnTerminate := RequestFinished;
  edHost.Enabled := False;
  btnFindHEOSDevice.Enabled := False;
  cbxHEOSDevices.Enabled := False;
  FStatus.Caption := 'Contacting ' + Trim(edHost.Text) + ':23 ...';
  memFLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + FStatus.Caption);

  for Command in Commands do
    memFLog.Lines.Add('> ' + Command);

  FWorker.Start();
end;


function THEOSForm.VolumeCaption(HalfSteps: Integer): string;
begin

  Result := IntToStr(HalfSteps div 2) + '.' +
              IntToStr((HalfSteps mod 2) * 5) + '%';
end;


procedure THEOSForm.SetVolumeBusy(Busy: Boolean);
begin

  edHost.Enabled := not Busy;
  cbxHEOSDevices.Enabled := not Busy;
  btnFindHEOSDevice.Enabled := not Busy and (not Assigned(FDiscovery) or FDiscovery.Finished);

  if not Busy then
    UpdateStreamButtons();
end;


procedure THEOSForm.VolumeChange(Sender: TObject);
begin

  if not FVolumeReady or FUpdatingVolume or (csLoading in ComponentState) then
    Exit;

  FDesiredVolume := tbVolume.Position;
  FVolumePending := True;
  lblVolumePerc.Caption := VolumeCaption(FDesiredVolume);
  VolumeTimer.Enabled := False;
  VolumeTimer.Enabled := True;
end;


procedure THEOSForm.UpdateBalanceDisplay();
var
  Amount: Integer;
  Direction: string;

begin

  Amount := Abs(FDesiredBalance);

  if (FDesiredBalance = 0) then
    lblBalance.Caption := 'Balance: Centre'
  else
    begin
      if FDesiredBalance < 0 then
        Direction := 'Left'
      else
        Direction := 'Right';

      lblBalance.Caption := 'Balance: ' + Direction + ' ' + IntToStr(Amount div 2) +
                              '.' + IntToStr((Amount mod 2) * 5) + ' dB';
    end;

end;


procedure THEOSForm.BalanceChange(Sender: TObject);
begin

  if not FVolumeReady or FUpdatingBalance or (csLoading in ComponentState) then
    Exit;

  FDesiredBalance := tbBalance.Position;
  FBalancePending := True;
  UpdateBalanceDisplay();
  VolumeTimer.Enabled := False;
  VolumeTimer.Enabled := True;
end;


procedure THEOSForm.BalanceDblClick(Sender: TObject);
begin

  tbBalance.AnimateTrackBarToPosition(0,
                                      2);
end;


procedure THEOSForm.UpdateToneDisplay();
var
  Available: Boolean;

  function ToneCaption(const Name: string; Value: Integer): string;
  begin
    Result := Name + ': ';
    if (Value > 0) then
      Result := Result + '+';
    Result := Result + IntToStr(Value) + ' dB';
  end;

begin

  FUpdatingTone := True;

  try
    if not FTonePending then
      btnTone.Checked := FToneEnabled;

    lblBass.Caption := ToneCaption('Bass',
                                   tbBass.Position);

    lblTreble.Caption := ToneCaption('Treble',
                                     tbTreble.Position);
    Available := (FPowerText = 'On') and
                  FToneKnown and not
                  ContainsText(FToneMode,
                               'DIRECT') and not
                  FDynamicEq;

    btnTone.Enabled := Available;
    tbBass.Enabled := Available and FToneEnabled and
                        not (FTonePending and not FDesiredToneEnabled);
    tbTreble.Enabled := tbBass.Enabled;

    if (FPowerText <> 'On') then
      lblToneStatus.Caption := 'Activate Main Zone to adjust tone.'
    else
      if ContainsText(FToneMode,
                      'DIRECT') then
        lblToneStatus.Caption := 'Tone is unavailable in Direct / Pure Direct mode.'
      else
        if FDynamicEq then
          lblToneStatus.Caption := 'Tone is unavailable while Dynamic EQ is on.'
      else
        if not FToneKnown then
          lblToneStatus.Caption := 'Reading receiver tone settings ...'
        else
          if not FToneEnabled then
            lblToneStatus.Caption := 'Enable Tone to adjust bass and treble.'
          else
            lblToneStatus.Caption := 'Bass / treble: -6 to +6 dB. Double-click for 0 dB.';

  finally
    FUpdatingTone := False;
  end;
end;


procedure THEOSForm.ToneClick(Sender: TObject);
begin

  if FUpdatingTone or not FVolumeReady then
    Exit;

  FDesiredToneEnabled := btnTone.Checked;
  FTonePending := True;

  if not FDesiredToneEnabled then
    begin
      FBassPending := False;
      FTreblePending := False;
    end;

  UpdateToneDisplay();
  VolumeTimer.Enabled := True;
end;


procedure THEOSForm.ToneChange(Sender: TObject);
begin

  if FUpdatingTone or not FVolumeReady or (csLoading in ComponentState) then
    Exit;

  if (Sender = tbBass) then
    begin
      FDesiredBass := tbBass.Position;
      FBassPending := True;
    end
  else if (Sender = tbTreble) then
    begin
      FDesiredTreble := tbTreble.Position;
      FTreblePending := True;
    end
  else
    Exit;

  UpdateToneDisplay();
  VolumeTimer.Enabled := False;
  VolumeTimer.Enabled := True;
end;


procedure THEOSForm.ToneDblClick(Sender: TObject);
begin

  if (Sender = tbBass) then
    tbBass.Position := 0
  else if (Sender = tbTreble) then
    tbTreble.Position := 0;
end;


procedure THEOSForm.StartToneRequest();
var
  Commands: TList<string>;
  Command: string;

begin

  Commands := TList<string>.Create;
  try
    if FTonePending then
      if FDesiredToneEnabled then
        Commands.Add('PSTONE CTRL ON')
      else
        Commands.Add('PSTONE CTRL OFF');

    if FBassPending then
      Commands.Add('PSBAS ' + Format('%.2d',
                                     [50 + FDesiredBass]));

    if FTreblePending then
      Commands.Add('PSTRE ' + Format('%.2d',
                                     [50 + FDesiredTreble]));

    Commands.Add('MS?');
    Commands.Add('PSDYNEQ ?');
    Commands.Add('PSTONE CTRL ?');
    Commands.Add('PSBAS ?');
    Commands.Add('PSTRE ?');

    FreeAndNil(FWorker);
    FExpectedPowerReply := '';
    FWorker := TDenonRequest.Create(Trim(edHost.Text),
                                    Commands.ToArray,
                                    23,
                                    False,
                                    False,
                                    False,
                                    True);

    FToneRequest := True;
    FTonePending := False;
    FBassPending := False;
    FTreblePending := False;
    FToneReadPending := False;
    FWorker.OnTerminate := RequestFinished;
    FStatus.Caption := 'Updating receiver tone settings ...';

    for Command in Commands do
      memFLog.Lines.Add('> ' + Command);

    SetVolumeBusy(True);
    VolumeTimer.Enabled := ReceiverActionsPending();
    FWorker.Start();

  finally
    Commands.Free;
  end;
end;


procedure THEOSForm.StartBalanceRequest();
var
  Left: Integer;
  Right: Integer;
  LeftCommand: string;
  RightCommand: string;

  //Helper
  function ChannelValue(HalfSteps: Integer): string;
  begin
    if (HalfSteps < 76) then
      HalfSteps := 76;

    if (HalfSteps > 124) then
      HalfSteps := 124;

    Result := Format('%.2d',
                     [HalfSteps div 2]);

    if (HalfSteps mod 2 <> 0) then
      Result := Result + '5';
  end;

begin

  FreeAndNil(FWorker);
  FExpectedPowerReply := '';
  FBalanceRequest := True;
  FBalanceLeftReceived := False;
  FBalanceRightReceived := False;
  FBalanceReadingBase := not FBalanceKnown or FBalanceReadPending or (FBalanceBaseHost <> Trim(edHost.Text));
  FBalanceReadPending := False;

  if FBalanceReadingBase then
    begin
      Inc(FStartupBalanceReadAttempts);
      FWorker := TDenonRequest.Create(Trim(edHost.Text),
                                      ['SI?',
                                      'CV?'],
                                      23,
                                      False,
                                      True);

      FStatus.Caption := 'Reading front channel levels ...';
      memFLog.Lines.Add('> SI?');
      memFLog.Lines.Add('> CV?');
    end
  else
    begin
      Left := FBalanceLeft;
      Right := FBalanceRight;

      if (FDesiredBalance > 0) then
        Dec(Left,
            FDesiredBalance)
      else
        Inc(Right,
            FDesiredBalance);

      LeftCommand := 'CVFL ' + ChannelValue(Left);
      RightCommand := 'CVFR ' + ChannelValue(Right);

      FWorker := TDenonRequest.Create(Trim(edHost.Text),
                                      [LeftCommand,
                                       RightCommand,
                                       'CV?'],
                                      23,
                                      False,
                                      True);

      FBalancePending := False;
      FStatus.Caption := 'Setting receiver balance ...';
      memFLog.Lines.Add('> ' + LeftCommand);
      memFLog.Lines.Add('> ' + RightCommand);
      memFLog.Lines.Add('> CV?');
    end;

  FWorker.OnTerminate := RequestFinished;
  SetVolumeBusy(True);
  VolumeTimer.Enabled := ReceiverActionsPending();
  FWorker.Start();
end;


function THEOSForm.ReceiverActionsPending(): Boolean;
begin

  Result := FVolumePending or FVolumeReadPending or FBalancePending or
              FBalanceReadPending or FMainZonePending or FZone2Pending or FZoneReadPending or
              FTonePending or FBassPending or FTreblePending or FToneReadPending;
end;


procedure THEOSForm.UpdateZoneButtons();
begin

  if FMainZonePending then
    btnMainZone.Checked := FMainZoneDesired
  else
    if FZoneRequest and (FZoneRequestKind = 1) then
      btnMainZone.Checked := FZoneRequestTarget
    else
      btnMainZone.Checked := FPowerText = 'On';

  if FZone2Pending then
    btnZone2.Checked := FZone2Desired
  else
    if FZoneRequest and (FZoneRequestKind = 2) then
      btnZone2.Checked := FZoneRequestTarget
    else
      btnZone2.Checked := FZone2PowerText = 'On';
end;


procedure THEOSForm.ZoneClick(Sender: TObject);
begin

  if Sender = btnMainZone then
    QueueZoneChange(True,
                    btnMainZone.Checked)
  else
    if (Sender = btnZone2) then
      QueueZoneChange(False,
                      btnZone2.Checked);
end;


procedure THEOSForm.RetryStartupZoneRead();
begin

  if ((FPowerText = '?') or (FZone2PowerText = '?')) and
     (FStartupZoneReadAttempts < 3) then
    begin
      FZoneReadPending := True;
      if FVolumeText = '?' then
        FVolumeReadPending := True;
      VolumeTimer.Enabled := True;
    end;
end;


procedure THEOSForm.QueueZoneChange(MainZone: Boolean; Active: Boolean);
begin

  if MainZone then
    begin
      FMainZoneDesired := Active;
      FMainZonePending := True;

      if not Active then
        begin
          FQueueActive := False;
          FQueueNextPending := False;
        end;
    end
  else
    begin
      FZone2Desired := Active;
      FZone2Pending := True;
    end;

  UpdateZoneButtons();
  VolumeTimer.Enabled := True;
  VolumeTick(nil);
end;


procedure THEOSForm.StartZoneRequest();
var
  Command: string;
  Commands: TArray<string>;

begin

  Command := '';
  FZoneRequestKind := 0;

  if FMainZonePending then
    begin
      FMainZonePending := False;
      FZoneRequestKind := 1;
      FZoneRequestTarget := FMainZoneDesired;
      if FZoneRequestTarget then
        Command := 'ZMON'
      else
        Command := 'ZMOFF';
    end
  else
    if FZone2Pending then
      begin
        FZone2Pending := False;
        FZoneRequestKind := 2;
        FZoneRequestTarget := FZone2Desired;

        if FZoneRequestTarget then
          Command := 'Z2ON'
        else
          Command := 'Z2OFF';
      end;

  FZoneReadPending := False;

  if (Command = '') then
    begin
      Inc(FStartupZoneReadAttempts);
      Commands := TArray<string>.Create('ZM?',
                                        'Z2?');
    end
  else
    Commands := TArray<string>.Create(Command,
                                      'ZM?',
                                      'Z2?');

  FreeAndNil(FWorker);
  FExpectedPowerReply := Command;
  FZoneRequest := True;

  FWorker := TDenonRequest.Create(Trim(edHost.Text),
                                  Commands,
                                  23,
                                  False,
                                  False,
                                  True);

  FWorker.OnTerminate := RequestFinished;
  SetVolumeBusy(True);
  FStatus.Caption := 'Updating receiver zones ...';

  for Command in Commands do
    memFLog.Lines.Add('> ' + Command);

  UpdateZoneButtons();
  VolumeTimer.Enabled := ReceiverActionsPending();
  FWorker.Start();
end;


procedure THEOSForm.VolumeTick(Sender: TObject);
var
  Command: string;

begin

  if not ReceiverActionsPending() then
    begin
      VolumeTimer.Enabled := False;
      Exit;
    end;

  if Assigned(FWorker) and not FWorker.Finished then
    Exit;

  VolumeTimer.Enabled := False;

  if not ValidAddress() then
    begin
      FVolumePending := False;
      FVolumeReadPending := False;
      FBalancePending := False;
      FBalanceReadPending := False;
      FMainZonePending := False;
      FZone2Pending := False;
      FZoneReadPending := False;
      FTonePending := False;
      FBassPending := False;
      FTreblePending := False;
      FToneReadPending := False;
      UpdateZoneButtons();
      FStatus.Caption := 'Enter a valid receiver IPv4 address before setting volume.';
      Exit;
    end;

  if FMainZonePending or FZone2Pending or (FZoneReadPending and not FVolumeReadPending) then
    begin
      StartZoneRequest();
      Exit;
    end;

  if not FVolumePending and not FVolumeReadPending then
    begin
      if FBalancePending or FBalanceReadPending then
        StartBalanceRequest()
      else
        StartToneRequest();
      Exit;
    end;

  FreeAndNil(FWorker);
  FExpectedPowerReply := '';
  FVolumeRequest := True;

  if FVolumePending then
    begin
      Command := 'MV' + Format('%.2d',
                               [FDesiredVolume div 2]);

      if (FDesiredVolume mod 2 <> 0) then
        Command := Command + '5';

      FWorker := TDenonRequest.Create(Trim(edHost.Text),
                                      [Command,
                                      'MV?'],
                                      23,
                                      True);

      FStatus.Caption := 'Setting volume to ' + VolumeCaption(FDesiredVolume) + ' ...';
      memFLog.Lines.Add('> ' + Command);
    end
  else
    begin
      if FZoneReadPending then
        begin
          Inc(FStartupZoneReadAttempts);
          FWorker := TDenonRequest.Create(Trim(edHost.Text),
                                          ['ZM?',
                                           'Z2?',
                                           'MV?'],
                                          23,
                                          True,
                                          False,
                                          True);

          FZoneReadPending := False;
          FStatus.Caption := 'Reading receiver volume and zone states ...';
          memFLog.Lines.Add('> ZM?');
          memFLog.Lines.Add('> Z2?');
        end
      else
        begin
          FWorker := TDenonRequest.Create(Trim(edHost.Text),
                                          ['MV?'],
                                          23,
                                          True);

          FStatus.Caption := 'Reading receiver volume ...';
        end;
      memFLog.Lines.Add('> MV?');
    end;

  FVolumePending := False;
  FVolumeReadPending := False;
  VolumeTimer.Enabled := ReceiverActionsPending();
  FWorker.OnTerminate := RequestFinished;
  SetVolumeBusy(True);
  FWorker.Start();
end;


procedure THEOSForm.ActionClick(Sender: TObject);
var
  Command: string;

begin

  if not (Sender is TComponent) then
    Exit;

  case TComponent(Sender).Tag of
    0: begin
         FToneReadPending := True;
         VolumeTimer.Enabled := True;
         StartRequest(['PW?',
                       'ZM?',
                       'Z2?',
                       'MV?',
                       'MU?',
                       'SI?']);
         Exit;
       end;
    1: begin
         QueueZoneChange(True,
                         True);
         Exit;
       end;
    2: begin
         QueueZoneChange(True,
                         False);
         Exit;
       end;
    5: begin
         if (Sender = btnMute) and not btnMute.Checked then
           Command := 'MUOFF'
         else
           Command := 'MUON';
       end;
    6: Command := 'MUOFF';
    8: begin
         QueueZoneChange(False,
                         True);
         Exit;
       end;
    9: begin
         QueueZoneChange(False,
                         False);
         Exit;
       end;
    7: begin
         if (FSource.ItemIndex < Low(SourceCommands)) or (FSource.ItemIndex > High(SourceCommands)) then
           Exit;

         Command := SourceCommands[FSource.ItemIndex];
         FQueueActive := False;
         FQueueNextPending := False;
       end;
  else
    Exit;
  end;

  StartRequest([Command,
                'ZM?',
                'Z2?',
                'MV?',
                'MU?',
                'SI?']);
end;


procedure THEOSForm.RequestFinished(Sender: TObject);
var
  Line: string;
  PowerConfirmed: Boolean;

begin

  PowerConfirmed := (FExpectedPowerReply = '');

  for Line in FWorker.Lines do
    begin
      memFLog.Lines.Add('< ' + Line);
      ParseStatus(Line);
      if (Line = FExpectedPowerReply) then
        PowerConfirmed := True;
    end;

  RetryStartupZoneRead();
  if FToneRequest then
    begin
      FToneRequest := False;
      UpdateToneDisplay();
      if (FWorker.ErrorText <> '') then
        begin
          lblToneStatus.Caption := FWorker.ErrorText;
          memFLog.Lines.Add('! Tone: ' + FWorker.ErrorText);
        end;
      SetVolumeBusy(False);
      VolumeTimer.Enabled := ReceiverActionsPending();
      Exit;
    end;

  if FZoneRequest then
    begin
      FZoneRequest := False;
      UpdateZoneButtons();
      SetVolumeBusy(False);

      if (FWorker.ErrorText <> '') then
        begin
          FStatus.Caption := FWorker.ErrorText;
          memFLog.Lines.Add('! Zones: ' + FWorker.ErrorText);
        end
      else
        if not PowerConfirmed then
          begin
            FStatus.Caption := 'Receiver did not confirm the requested zone change.';
            memFLog.Lines.Add('! Zone change not confirmed: ' + FExpectedPowerReply);
          end
        else
          FStatus.Caption := 'Receiver zone states updated.';

      VolumeTimer.Enabled := ReceiverActionsPending();
      Exit;
    end;

  UpdateZoneButtons();

  if FBalanceRequest then
    begin
      FBalanceRequest := False;

      if (FWorker.ErrorText = '') and FBalanceLeftReceived and FBalanceRightReceived then
        begin
          if FBalanceReadingBase then
            begin
              // A centred balance has equal channel levels. Keep the louder
              // channel as the reference so the reported balance is reproduced.
              FBalanceLeft := FBalanceReplyLeft;
              if (FBalanceReplyRight > FBalanceLeft) then
                FBalanceLeft := FBalanceReplyRight;
              FBalanceRight := FBalanceLeft;
              FBalanceBaseHost := Trim(edHost.Text);
              FBalanceBaseInput := FInputText;
              FBalanceKnown := True;

              if not FBalancePending then
                begin
                  FDesiredBalance := FBalanceReplyRight - FBalanceReplyLeft;
                  if (FDesiredBalance < tbBalance.Minimum) then
                    FDesiredBalance := tbBalance.Minimum;
                  if (FDesiredBalance > tbBalance.Maximum) then
                    FDesiredBalance := tbBalance.Maximum;
                  FUpdatingBalance := True;

                  try
                    tbBalance.Position := FDesiredBalance;
                  finally
                    FUpdatingBalance := False;
                  end;

                  UpdateBalanceDisplay();
                end;
            end;
          FStatus.Caption := 'Receiver balance updated.';
        end
      else
        begin
          if FBalanceReadingBase and (FStartupBalanceReadAttempts < 3) then
            FBalanceReadPending := True
          else
            FBalancePending := False;

          if (FWorker.ErrorText <> '') then
            FStatus.Caption := FWorker.ErrorText
          else
            FStatus.Caption := 'Receiver did not return valid front channel levels.';

          memFLog.Lines.Add('! Balance: ' + FStatus.Caption);
        end;

      SetVolumeBusy(False);
      VolumeTimer.Enabled := ReceiverActionsPending();
      Exit;
    end;

  if FVolumeRequest then
    begin
      FVolumeRequest := False;
      SetVolumeBusy(False);

      if (FWorker.ErrorText <> '') then
        begin
          FStatus.Caption := FWorker.ErrorText;
          memFLog.Lines.Add('! ' + FWorker.ErrorText);
        end
      else
        FStatus.Caption := 'Receiver volume: ' + FVolumeText;
      VolumeTimer.Enabled := ReceiverActionsPending();
      Exit;
    end;

  if (FWorker.ErrorText <> '') then
    begin
      FStatus.Caption := FWorker.ErrorText;
      memFLog.Lines.Add('! ' + FWorker.ErrorText);
    end
  else
    if not PowerConfirmed then
      begin
        FStatus.Caption := 'Receiver replied, but the requested power change was not confirmed. Click Read status to check.';
        memFLog.Lines.Add('! Power change not confirmed: ' + FExpectedPowerReply);
      end
    else
      FStatus.Caption := 'Reply received at ' + FormatDateTime('hh:nn:ss',
                                                               Now) + '. Values below reflect receiver replies; click Read status to refresh.';
  pnlPlay.Enabled := True;
  edHost.Enabled := True;
  btnFindHEOSDevice.Enabled := not Assigned(FDiscovery) or FDiscovery.Finished;
  cbxHEOSDevices.Enabled := True;
end;


procedure THEOSForm.ParseStatus(const Line: string);
var
  Raw: string;
  Value: Integer;
  HalfSteps: Integer;

begin

  if (Line = 'PSTONE CTRL ON') or (Line = 'PSTONE CTRL OFF') then
    begin
      FToneKnown := True;
      FToneEnabled := Line = 'PSTONE CTRL ON';
      UpdateToneDisplay();
      Exit;
    end;

  if StartsText('PSBAS ', Line) or StartsText('PSTRE ', Line) then
    begin
      if TryStrToInt(Copy(Line, 7, MaxInt), Value) and (Value >= 44) and (Value <= 56) then
        begin
          FUpdatingTone := True;
          try
            if StartsText('PSBAS ', Line) then
              begin
                if not FBassPending then
                  tbBass.Position := Value - 50;
              end
            else if not FTreblePending then
              tbTreble.Position := Value - 50;
          finally
            FUpdatingTone := False;
          end;
          UpdateToneDisplay();
        end;
      Exit;
    end;

  if StartsText('MS', Line) then
    begin
      FToneMode := Copy(Line, 3, MaxInt);
      UpdateToneDisplay();
      Exit;
    end;

  if (Line = 'PSDYNEQ ON') or (Line = 'PSDYNEQ OFF') then
    begin
      FDynamicEq := Line = 'PSDYNEQ ON';
      UpdateToneDisplay();
      Exit;
    end;

  if (Copy(Line,
           1,
           5) = 'CVFL ') or (Copy(Line,
                                  1,
                                  5) = 'CVFR ') then
    begin
      Raw := Copy(Line, 6, MaxInt);

      if not TryStrToInt(Raw, Value) then
        Exit;

      if Length(Raw) = 2 then
        HalfSteps := Value * 2
      else
        if (Length(Raw) = 3) and (Value mod 5 = 0) then
          HalfSteps := Value div 5
        else
          Exit;

      if (HalfSteps < 76) or (HalfSteps > 124) then
        Exit;

      if Copy(Line,
              1,
              5) = 'CVFL ' then
        begin
          FBalanceReplyLeft := HalfSteps;
          FBalanceLeftReceived := True;
        end
      else
        begin
          FBalanceReplyRight := HalfSteps;
          FBalanceRightReceived := True;
        end;

      Exit;
    end;

  if (Line = 'ZMON') then
    begin
      if (FPowerText <> 'On') then
        begin
          FToneReadPending := True;
          VolumeTimer.Enabled := True;
        end;
      FPowerText := 'On';
      UpdateToneDisplay();
    end
  else
    if (Line = 'ZMOFF') then
      begin
        FPowerText := 'Standby';
        UpdateToneDisplay();
      end;

  if (Line = 'Z2ON') then
    FZone2PowerText := 'On'
  else
    if (Line = 'Z2OFF') then
      FZone2PowerText := 'Standby';

  if (Line = 'MUON') then
    begin
      FMuteText := 'On';
      btnMute.Checked := True;
    end
  else
    if (Line = 'MUOFF') then
      begin
        FMuteText := 'Off';
        btnMute.Checked := False;
      end;

  if StartsText('SI', Line) then
    begin
      if (FInputText <> Copy(Line, 3, MaxInt)) then
        begin
          FToneKnown := False;
          FTonePending := False;
          FBassPending := False;
          FTreblePending := False;
          FToneReadPending := True;
          VolumeTimer.Enabled := True;
          UpdateToneDisplay();
        end;
      FInputText := Copy(Line, 3, MaxInt);

      if FBalanceKnown and (FInputText <> FBalanceBaseInput) then
        begin
          FBalanceKnown := False;
          FStartupBalanceReadAttempts := 0;
          FBalancePending := False;
          FBalanceReadPending := True;
          VolumeTimer.Enabled := True;
        end;
    end;

  if StartsText('MVMAX ', Line) then
    begin
      Raw := Trim(Copy(Line, 7, MaxInt));

      if ((Length(Raw) = 2) or (Length(Raw) = 3)) and
         TryStrToInt(Raw, Value) then
        begin
          if (Length(Raw) = 2) then
            HalfSteps := Value * 2
          else
            if (Value mod 5 = 0) then
              HalfSteps := Value div 5
            else
              Exit;

          if (HalfSteps <= 0) or (HalfSteps > 196) then
            Exit;

          FUpdatingVolume := True;
          try
            tbVolume.Maximum := HalfSteps;
            if (FDesiredVolume > HalfSteps) then
              FDesiredVolume := HalfSteps;
            lblVolumePerc.Caption := VolumeCaption(tbVolume.Position);
          finally
            FUpdatingVolume := False;
          end;
        end;
      Exit;
    end;

  if StartsText('MV',
                Line) and (not StartsText('MVMAX',
                                          Line)) then
    begin

      Raw := Copy(Line,
                  3,
                  MaxInt);

      if ((Length(Raw) = 2) or (Length(Raw) = 3)) and TryStrToInt(Raw,
                                                                  Value) then
        begin
          if (Length(Raw) = 3) then
            begin
              if (Value mod 5 <> 0) then
                Exit;
              HalfSteps := Value div 5;
            end
          else
            HalfSteps := Value * 2;

          if (HalfSteps < 0) or (HalfSteps > 196) then
            Exit;

          FVolumeText := VolumeCaption(HalfSteps);

          if not FVolumePending then
            begin
              FUpdatingVolume := True;

              try
                tbVolume.Position := HalfSteps;
                lblVolumePerc.Caption := FVolumeText;
              finally
                FUpdatingVolume := False;
              end;
            end;
        end;
    end;
end;


procedure THEOSForm.BrowserClick(Sender: TObject);
var
  URL: string;

begin

  if not ValidAddress then
    begin
      ShowMessage('Enter a valid receiver IPv4 address first.');
      Exit;
    end;

  URL := 'http://' + Trim(edHost.Text);

  if (ShellExecute(Handle,
                   'open',
                   PChar(URL),
                   nil,
                   nil,
                   SW_SHOWNORMAL) <= 32) then
    ShowMessage('Windows could not open the browser. Open ' + URL + ' manually.');
end;


procedure THEOSForm.SettingsClick(Sender: TObject);
begin

  pnlPlay.Visible := False;
  pnlSettings.Visible := True;
  pnlSettings.BringToFront;
end;


procedure THEOSForm.PlayerClick(Sender: TObject);
begin

  pnlSettings.Visible := False;
  pnlPlay.Visible := True;
  pnlPlay.BringToFront;
end;


procedure THEOSForm.ShuffleUpcoming(StartIndex: Integer);
var
  I: Integer;
  J: Integer;

begin

  if (StartIndex < 0) then
    StartIndex := 0;

  for I := FQueue.Count - 1 downto StartIndex + 1 do
    begin
      J := StartIndex + Random(I - StartIndex + 1);
      FQueue.Exchange(I,
                      J);
    end;
end;


procedure THEOSForm.QueueModeClick(Sender: TObject);
begin

  if (Sender = btnShuffle) and btnShuffle.Checked then
    ShuffleUpcoming(FQueueIndex + 1);

  UpdateStreamButtons();
end;


procedure THEOSForm.StreamClick(Sender: TObject);
begin

  StartStreamAction(TComponent(Sender).Tag);
end;


procedure THEOSForm.btnPlayListMouseExit(Sender: TObject);
begin

  pmPlaylists.CloseMenu();
end;


procedure THEOSForm.btnStreamWinAudioClick(Sender: TObject);
begin

  if Assigned(FLoopback) or FWaitingForCapture then
    StartStreamAction(4)
  else
    StartStreamAction(1);
end;


procedure THEOSForm.PlayPauseClick(Sender: TObject);
var
  SameTrack: Boolean;
  QueueSelection: Boolean;

begin

  if (FDesiredPlaybackFile <> '') then
    SameTrack := SameFileName(FSelectedFile,
                              FDesiredPlaybackFile)
  else
    SameTrack := (FPlaybackFile <> '') and
                  SameFileName(FSelectedFile,
                               FPlaybackFile);

  QueueSelection := (FQueueIndex >= 0) and (FQueueIndex < FQueue.Count) and SameFileName(FSelectedFile,
                                                                                         FQueue[FQueueIndex]);
  if SameTrack and (RequestedPlaybackState() = 'play') then
    StartStreamAction(2)
  else
    if SameTrack and (RequestedPlaybackState() = 'pause') then
      StartStreamAction(3)
  else
    if FileExists(FSelectedFile) then
      begin
        if not QueueSelection then
          begin
            FQueue.Clear;
            FQueueIsPlaylist := False;
            FQueue.Add(FSelectedFile);
            FQueueIndex := 0;
          end;
        PlayQueueIndex(FQueueIndex);
      end
    else
      StartStreamAction(0);
end;


procedure THEOSForm.StartStreamAction(Action: Integer);
var
  Command: THEOSStreamAction;

begin

  Command := Default(THEOSStreamAction);
  Command.Action := Action;
  Command.FileName := FSelectedFile;
  Command.QueueStarting := FQueueStarting;

  if (Action = 4) then
    begin
      FStreamActions.Clear;
      FQueueActive := False;
      FQueueNextPending := False;
      StopLocalStream();
      FDesiredPlaybackFile := '';
    end;

  case Action of
    0: begin
         FDesiredPlaybackState := 'play';
         FDesiredPlaybackFile := Command.FileName;
       end;
    1, 3: FDesiredPlaybackState := 'play';
    2: FDesiredPlaybackState := 'pause';
    4: FDesiredPlaybackState := 'stop';
  end;

  FStreamActions.Add(Command);
  StreamActionTimer.Enabled := True;
  UpdateStreamButtons();
  ProcessStreamActions();
end;


function THEOSForm.RequestedPlaybackState(): string;
begin

  if (FDesiredPlaybackState <> '') then
    Result := FDesiredPlaybackState
  else
    Result := FPlaybackState;
end;


procedure THEOSForm.StreamActionsReady(var Message: TMessage);
begin

  ProcessStreamActions();
end;


procedure THEOSForm.StreamActionTick(Sender: TObject);
begin

  ProcessStreamActions();
end;


procedure THEOSForm.ProcessStreamActions();
var
  Command: THEOSStreamAction;
  QueueStarting: Boolean;

begin

  if FProcessingStreamActions then
    Exit;

  FProcessingStreamActions := True;

  try
    while not FWaitingForCapture and
          (not Assigned(FHeos) or FHeos.Finished) do
      begin
        if (FStreamActions.Count = 0) then
          begin
            FDesiredPlaybackState := '';
            FDesiredPlaybackFile := '';
            StreamActionTimer.Enabled := False;
            Break;
          end;

        Command := FStreamActions[0];
        FStreamActions.Delete(0);
        QueueStarting := FQueueStarting;

        try
          FQueueStarting := Command.QueueStarting;
          if (Command.Action = 5) then
            begin
              if CanSeekPlayback() and
                 SameFileName(Command.FileName, FPlaybackFile) and
                 (Command.Receiver = FStreamReceiver) then
                SendHeos(haSeek, '', Command.PositionMs);
              Continue;
            end;

          if (Command.Action = 0) then
            begin
              SelectAudioFile(Command.FileName);

              if Command.QueueStarting then
                FQueueActive := True;
            end;

          ExecuteStreamAction(Command.Action);

        finally
          FQueueStarting := QueueStarting;
        end;
      end;

  finally
    FProcessingStreamActions := False;
  end;

  UpdateStreamButtons();
end;


procedure THEOSForm.ExecuteStreamAction(Action: Integer);
var
  Port: Integer;
  LocalIP: string;

begin

  if Assigned(FHeos) and not FHeos.Finished then
    Exit;

  if ((Action = 0) and not FQueueStarting) or (Action = 1) or (Action = 4) then
    begin
      FQueueActive := False;
      FQueueNextPending := False;
    end;

  try

    if (Action >= 2) then
      begin
        if (FStreamReceiver = '') then
          FStreamReceiver := Trim(edHost.Text);

        case Action of
          2: SendHeos(haPause);
          3: SendHeos(haResume);
          4: begin
               StopLocalStream;
               SendHeos(haStop);
             end;
        end;
        Exit;
      end;

    if not ValidAddress then
      raise Exception.Create('Enter a valid receiver IPv4 address');

    if (Action = 0) and not FileExists(FSelectedFile) then
      raise Exception.Create('Choose a music file first');

    if not TryStrToInt(StreamPortEdit.Text, Port) or (Port < 1024) or (Port > 65535) then
      raise Exception.Create('Choose a streaming port between 1024 and 65535');

    LocalIP := Trim(PcAddressEdit.Text);

    if (LocalIP = '') then
      LocalIP := LocalAddressFor(Trim(edHost.Text));

    if not IPv4Valid(LocalIP) then
      raise Exception.Create('Enter a valid PC IPv4 address or leave it blank for automatic detection');

    StopLocalStream();
    FStreamReceiver := Trim(edHost.Text);
    FAudioServer := THEOSAudioServer.Create(LocalIP,
                                            Port,
                                            FSelectedFile,
                                            Action = 1);
    FAudioServer.Start;
    memFLog.Lines.Add('Stream URL: ' + FAudioServer.Url);

    if (Action = 1) then
      begin
        FStreamDescription := 'Windows sound (default playback device), stereo AAC';
        lblStreamInfo.Caption := 'Windows sound (default playback device)';
        FLoopback := THEOSLoopback.Create(FAudioServer);
        FWaitingForCapture := True;
        FLoopback.Start();
        lblStreamInfo.Caption := 'Starting Windows audio capture ...';
        UpdateStreamButtons();
      end
    else
      begin
        FStreamDescription := lblStreamInfo.Caption;
        FPlaybackFile := FSelectedFile;
        SendHeos(haPlayUrl,
                 FAudioServer.Url);
      end;

  except
    on E: Exception do
      begin
        FQueueActive := False;
        FStreamActions.Clear;
        StopLocalStream();
        memFLog.Lines.Add('! Streaming: ' + E.Message);
        lblStreamInfo.Caption := E.Message;
        UpdateStreamButtons();
      end;
  end;
end;

// External

function GetTickCount64;  external Kernel32Lib name 'GetTickCount64';

end.

