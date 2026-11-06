// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: Media Foundation - MFPack - Samples
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HEOSRadioForm.pas
// Kind: Pascal Unit
// Release date: 30-10-2026
// Language: ENU
//
// Revision Version: 1.1.0.0
// Description: Asynchronous HEOS radio service browser.
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
unit HEOSRadioForm;

{$B-}

interface

uses

  {WinApi}
  WinApi.Windows,
  WinApi.Messages,
  {System}
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
  {Vcl}
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Dialogs,
  {Application}
  Heos.Cli,
  Heos.Commands,
  HEOSButton,
  HEOSRadioArtwork,
  HEOSRadioStreamProbe;

type

  THeosRadioPlayEvent = procedure(Sender: TObject;
                                  const Command: THeosCommand;
                                  const StationName: string) of object;

  THeosRadioPlaybackEvent = procedure(Sender: TObject;
                                      const StationName: string;
                                      Playing: Boolean) of object;

  THeosRadioLocation = record
    SourceId: Int64;
    ContainerId: string;
    Title: string;
    SearchText: string;
    CriteriaId: string;
    First: Integer;
  end;

  THeosRadioItem = record
    Name: string;
    ContainerId: string;
    MediaId: string;
    ImageUrl: string;
    StreamUrl: string;
    SourceId: Int64;
    IsContainer: Boolean;
    IsStation: Boolean;
  end;

  THeosRadioRequest = (rrNone,
                       rrPlayers,
                       rrSources,
                       rrCriteria,
                       rrBrowse,
                       rrPlay,
                       rrStop);

  THEOSRadioForm = class(TForm)
    pnlTop: TPanel;
    pnlCustomStation: TPanel;
    lblStationName: TLabel;
    lblStationUrl: TLabel;
    edStationName: TEdit;
    edStationUrl: TEdit;
    btnAddStation: TDnButton;
    btnRemoveStation: TDnButton;
    lvStations: TListView;
    pmStations: TPopupMenu;
    miRemoveStation: TMenuItem;
    miStationLogo: TMenuItem;
    miStationLogoFile: TMenuItem;
    pnlBrowse: TPanel;
    lblStatus: TLabel;
    PollTimer: TTimer;
    btnHome: TDnButton;
    btnBack: TDnButton;
    btnPreviousPage: TDnButton;
    btnNextPage: TDnButton;
    imgStationArtwork: TImage;
    Bevel1: TBevel;
    lblService: TLabel;
    cbService: TComboBox;
    btnRefresh: TDnButton;
    btnClose: TDnButton;
    btnMinimize: TDnButton;
    Label1: TLabel;
    lblLocation: TLabel;
    lblArtworkStatus: TLabel;
    lblSelectedStation: TLabel;
    lblStationFeedback: TLabel;
    cbCriteria: TComboBox;
    edSearch: TEdit;
    btnSearch: TDnButton;
    lblPlaying: TLabel;
    chkPlayStation: TDnButton;
    lblLogo: TLabel;
    edLogoUrl: TEdit;
    btnAddLogoPath: TDnButton;
    Bevel2: TBevel;
    Bevel3: TBevel;

    procedure FormCreate(Sender: TObject);
    procedure RadioCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure RadioClose(Sender: TObject; var Action: TCloseAction);
    procedure PollTick(Sender: TObject);
    procedure RefreshClick(Sender: TObject);
    procedure AddStationClick(Sender: TObject);
    procedure RemoveStationClick(Sender: TObject);
    procedure StationPopup(Sender: TObject);
    procedure StationContextPopup(Sender: TObject; MousePos: TPoint;
                                    var Handled: Boolean);
    procedure StationLogoClick(Sender: TObject);
    procedure StationLogoFileClick(Sender: TObject);
    procedure LogoUrlExit(Sender: TObject);
    procedure LogoUrlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SourceChange(Sender: TObject);
    procedure SearchClick(Sender: TObject);
    procedure NavigationClick(Sender: TObject);
    procedure OpenItem(Sender: TObject);
    procedure SelectionChange(Sender: TObject; Item: TListItem;
                                Selected: Boolean);
    procedure PlayClick(Sender: TObject);
    procedure PlayStationClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure pnlTopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Label1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnCloseClick(Sender: TObject);
    procedure btnMinimizeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private

    FStreamProbe: THeosRadioStreamProbe;
    FProbeItem: THeosRadioItem;
    FProbePlay: Boolean;

    procedure PollStreamProbe();
    function CanEditStationLogo(): Boolean;

    function ApplyStationLogo(const Item: THeosRadioItem;
                              const Value: string): Boolean;

    procedure SetStationLogo(const Item: THeosRadioItem;
                             const Url: string);

  private

    FArtwork: THeosRadioArtwork;
    FArtworkUrl: string;
    FArtworkPending: Boolean;
    FArtworkRequestedTick: UInt64;

    procedure ClearArtwork();
    procedure SelectArtwork();
    procedure PollArtwork();

  private
    FClient: THeosClient;
    FStatusClient: THeosClient;
    FHost: string;
    FPlayerId: Int64;
    FPlayerFound: Boolean;
    FRequestId: UInt64;
    FRequest: THeosRadioRequest;
    FSourceIds: TList<Int64>;
    FCustomItems: TList<THeosRadioItem>;
    FStationsFile: string;
    FCriteriaIds: TList<string>;
    FItems: TList<THeosRadioItem>;
    FHistory: TList<THeosRadioLocation>;
    FLocation: THeosRadioLocation;
    FPendingLocation: THeosRadioLocation;
    FNavigation: Integer;
    FReturned: Integer;
    FTotal: Integer;
    FPlaying: Boolean;
    FStationName: string;
    FPlaybackStatus: string;
    FPlaybackConfirmed: Boolean;
    FPlaybackTimedOut: Boolean;
    FPlaybackStarted: Boolean;
    FPlaybackChecking: Boolean;
    FPlaybackQueryId: UInt64;
    FPlaybackDeadline: UInt64;
    FNextPlaybackCheck: UInt64;
    FLastPlayState: string;
    FSearchStatus: string;
    FOnBeforePlay: THeosRadioPlayEvent;
    FOnPlayback: THeosRadioPlaybackEvent;

    function IsCustomService(): Boolean;
    function ValidStationUrl(const Url: string): Boolean;
    procedure LoadCustomStations();
    function SaveCustomStations(): Boolean;
    procedure ShowCustomStations();
    procedure StationFeedback(const Text: string);

    procedure Request(Kind: THeosRadioRequest;
                      const Command: THeosCommand);

    procedure Reply(Message: THeosMessage);
    procedure ReadSources(Payload: TJSONValue);
    procedure ReadCriteria(Payload: TJSONValue);
    procedure ReadItems(Message: THeosMessage);

    procedure Browse(const Location: THeosRadioLocation;
                     Navigation: Integer);

    procedure UpdateButtons();
    procedure ReportPlayback(Playing: Boolean);
    procedure CheckPlayback();
    procedure PlaybackReply(Message: THeosMessage);
    function RootLocation(): THeosRadioLocation;
    function NextPageAvailable(): Boolean;

  public

    destructor Destroy(); override;

    procedure ConnectTo(const Host: string;
                        Port: Word = 1255);

    procedure StartPlayback(const Command: THeosCommand;
                            const StationName: string);

    function ReadyForPlayback(): Boolean;
    procedure NotifyStopped();
    function PlaybackPending(): Boolean;

    property PlaybackConfirmed: Boolean read FPlaybackConfirmed;
    property PlaybackStatus: string read FPlaybackStatus;
    property Host: string read FHost;
    property OnBeforePlay: THeosRadioPlayEvent read FOnBeforePlay write FOnBeforePlay;
    property OnPlayback: THeosRadioPlaybackEvent read FOnPlayback write FOnPlayback;
  end;


implementation

{$R *.dfm}

uses

  {System}
  System.StrUtils,
  System.IniFiles,
  Heos.Files,
  System.Math,
  {Application}
  MainForm,
  LWFileBrowserExDlg;

const
  RadioPageSize = 50;


function JsonText(Obj: TJSONObject;
                  const Name: string): string;
var
  Value: TJSONValue;

begin

  Result := '';

  if not Assigned(Obj) then
    Exit;

  Value := Obj.GetValue(Name);

  if Assigned(Value) then
    Result := HeosDecode(Value.Value);
end;


procedure THEOSRadioForm.FormCreate(Sender: TObject);
var
  Directory: string;

begin

  FSourceIds := TList<Int64>.Create;
  FCustomItems := TList<THeosRadioItem>.Create;
  FCriteriaIds := TList<string>.Create;
  FItems := TList<THeosRadioItem>.Create;
  FHistory := TList<THeosRadioLocation>.Create;

  Directory := GetEnvironmentVariable('LOCALAPPDATA');

  if (Directory = '') then
    Directory := GetEnvironmentVariable('APPDATA');

  if (Directory <> '') then
    FStationsFile := IncludeTrailingPathDelimiter(Directory) + HEOS_REMOTE_DATADIR + RADIOSTATIONSINIFILE;

  try
    LoadCustomStations();

  except
    on E: Exception do
      lblStatus.Caption := 'Cannot read saved radio stations: ' + E.Message;
  end;
  UpdateButtons();
end;


procedure THEOSRadioForm.FormShow(Sender: TObject);
begin

  SetWindowLong(Handle,
                GWL_STYLE,
                GetWindowLong(Handle,
                              GWL_STYLE) and not WS_CAPTION or WS_BORDER);

  Width := Width - 10;
  Height := Height - 20;
end;

destructor THEOSRadioForm.Destroy();
begin

  PollTimer.Enabled := False;
  THeosRadioStreamProbe.Release(FStreamProbe);
  FreeAndNil(FArtwork);
  FreeAndNil(FStatusClient);
  FreeAndNil(FClient);
  FHistory.Free;
  FItems.Free;
  FCriteriaIds.Free;
  FCustomItems.Free;
  FSourceIds.Free;

  inherited;
end;


procedure THEOSRadioForm.btnMinimizeClick(Sender: TObject);
begin

  WindowState := wsMinimized;
end;


procedure THEOSRadioForm.ConnectTo(const Host: string;
                                   Port: Word);
begin

  if Assigned(FClient) and SameText(FHost,
                                    Host) then
    begin
      if not FPlayerFound and (FRequest = rrNone) then
        RefreshClick(nil);
      Exit;
    end;

  FreeAndNil(FStatusClient);
  FreeAndNil(FClient);
  FProbePlay := False;

  THeosRadioStreamProbe.Release(FStreamProbe);

  FHost := Host;
  FClient := THeosClient.Create(Host,
                                Port);
  FClient.TimeoutMs := 6000;
  FStatusClient := THeosClient.Create(Host,
                                      Port);
  FStatusClient.TimeoutMs := 6000;
  FPlayerFound := False;
  FPlaying := False;
  FPlaybackChecking := False;
  FPlaybackConfirmed := False;
  FPlaybackTimedOut := False;
  FPlaybackStarted := False;
  FPlaybackQueryId := 0;
  FHistory.Clear;
  FSourceIds.Clear;
  FCriteriaIds.Clear;
  ClearArtwork();
  FItems.Clear;
  cbService.Clear;
  cbCriteria.Clear;
  lvStations.Clear;
  lblPlaying.Caption := 'No radio station started.';
  Request(rrPlayers,
          THeosCommands.GetPlayers());
end;


procedure THEOSRadioForm.Request(Kind: THeosRadioRequest;
                                 const Command: THeosCommand);
begin

  FRequest := Kind;
  FRequestId := FClient.Enqueue(Command);

  if FRequestId = 0 then
    begin
      FRequest := rrNone;
      lblStatus.Caption := 'Receiver request queue is full; request was not sent. Retry after pending work completes.';
      UpdateButtons();
      Exit;
    end;

  lblStatus.Caption := 'Contacting receiver: ' + Command.Path + ' ...';
  UpdateButtons();
end;


procedure THEOSRadioForm.PollTick(Sender: TObject);
var
  Message: THeosMessage;

begin

  PollStreamProbe();
  PollArtwork();

  if not Assigned(FClient) then
    Exit;

  while FClient.TakeMessage(Message) do
    try
      if (Message.RequestId = FRequestId) and (FRequest <> rrNone) and
         (Message.Kind in [hmReply, hmError]) then
        Reply(Message);

    finally
      Message.Free;
    end;

  if Assigned(FStatusClient) then
    while FStatusClient.TakeMessage(Message) do
      try
        if (FPlaybackQueryId <> 0) and (Message.RequestId = FPlaybackQueryId) and
           (Message.Kind in [hmReply, hmError]) then
          PlaybackReply(Message);

      finally
        Message.Free;
      end;

  CheckPlayback();
end;


procedure THEOSRadioForm.Reply(Message: THeosMessage);
var
  Kind: THeosRadioRequest;
  Values: TJSONArray;
  Obj: TJSONObject;
  I: Integer;
  Id: Int64;

begin

  Kind := FRequest;
  FRequest := rrNone;
  try
    if not Message.Success then
      begin
        lblStatus.Caption := Message.ErrorText;

        if (Kind = rrPlayers) then
          lblStatus.Caption := lblStatus.Caption + ' Check the current IP in Settings / Find HEOS, then retry.';

        if Message.DeliveryUnknown then
          lblStatus.Caption := lblStatus.Caption + ' Command delivery is unknown; check the receiver.';

        if (Kind = rrCriteria) then
          begin
            FSearchStatus := 'Search unavailable: ' + Message.ErrorText;
            Browse(RootLocation(),
                   0);
          end
        else
          if (Kind = rrPlay) then
            begin
              FPlaybackStatus := 'Radio request failed: ' + lblStatus.Caption;
              ReportPlayback(False);
            end;

        UpdateButtons();
        Exit;
      end;

    case Kind of
      rrPlayers: begin
                   if not (Message.Payload is TJSONArray) then
                     begin lblStatus.Caption := 'No HEOS players returned.'; UpdateButtons(); Exit; end;

                   Values := TJSONArray(Message.Payload);

                   for I := 0 to Values.Count - 1 do
                     if (Values.Items[I] is TJSONObject) then
                       begin
                         Obj := TJSONObject(Values.Items[I]);

                         if SameText(JsonText(Obj,
                                              'ip'),
                                     FHost) and TryStrToInt64(JsonText(Obj,
                                                              'pid'),
                                                              Id) then
                           begin
                             FPlayerId := Id;
                             FPlayerFound := True;
                             Break;
                           end;
                       end;

                   if not FPlayerFound then
                     begin lblStatus.Caption := 'The selected receiver was not found in the HEOS player list.'; UpdateButtons(); Exit; end;
                   Request(rrSources, THeosCommands.GetMusicSources());
                 end;

      rrSources: ReadSources(Message.Payload);

      rrCriteria: begin
                    ReadCriteria(Message.Payload);
                    Browse(RootLocation(),
                           0);
                  end;

      rrBrowse: ReadItems(Message);

      rrPlay: begin
                FPlaybackConfirmed := False;
                FPlaybackTimedOut := False;
                FPlaybackChecking := True;
                FPlaybackQueryId := 0;
                FLastPlayState := '';
                FNextPlaybackCheck := Heos.Cli.GetTickCount64() + 500;
                FPlaybackDeadline := Heos.Cli.GetTickCount64() + 15000;
                FPlaybackStatus := 'Command accepted; checking receiver playback';
                ReportPlayback(True);
                lblStatus.Caption := 'Command accepted. Waiting for the receiver to report playing ...';
              end;

      rrStop: begin
                FPlaybackStatus := 'Radio stopped';
                ReportPlayback(False);
                lblStatus.Caption := 'Radio stopped.';
              end;
    end;

  except
    on E: Exception do
      lblStatus.Caption := E.Message;
  end;

  UpdateButtons();
end;


procedure THEOSRadioForm.ReadSources(Payload: TJSONValue);
var
  Values: TJSONArray;
  Obj: TJSONObject;
  I: Integer;
  Id: Int64;
  Name: string;
  Preferred: Integer;

begin

  if not (Payload is TJSONArray) then
    begin lblStatus.Caption := 'Receiver did not return a music-source list.'; Exit; end;

  cbService.Clear;
  FSourceIds.Clear;
  lvStations.Items.Clear;
  ClearArtwork();
  FItems.Clear;
  FHistory.Clear;
  FLocation := Default(THeosRadioLocation);
  FReturned := 0;
  FTotal := 0;
  Preferred := 0;
  Values := TJSONArray(Payload);

  for I := 0 to Values.Count - 1 do
    if (Values.Items[I] is TJSONObject) then
      begin
        Obj := TJSONObject(Values.Items[I]);

        Name := JsonText(Obj,
                         'name');

        if not TryStrToInt64(JsonText(Obj,
                                      'sid'),
                             Id) then
          Continue;

        // 'available' describes service-account information, not CLI support.
        // Anonymous radio browsing must also work when this field is false.
        if (Id <> 3) and (Id <> 7) and (Id <> 8) and (Id <> 1028) and
           not ContainsText(Name,
                            'radio') and not ContainsText(Name,
                                                          'TuneIn') then
          Continue;

        if (Id = 3) or ContainsText(Name,
                                    'TuneIn') then
          Preferred := cbService.Items.Count;

        cbService.Items.Add(Name);
        FSourceIds.Add(Id);
      end;

  if (FCustomItems.Count > 0) then
    begin
      cbService.Items.Add('My stations');
      FSourceIds.Add(-1);
    end;

  if (FSourceIds.Count = 0) then
    begin
      lblStatus.Caption := 'No radio services returned by the receiver. Check the HEOS app, then Refresh.';
      Exit;
    end;

  cbService.ItemIndex := Preferred;
  SourceChange(nil);
end;


procedure THEOSRadioForm.ReadCriteria(Payload: TJSONValue);
var
  Values: TJSONArray;
  Obj: TJSONObject;
  I: Integer;
  Id: string;

begin

  cbCriteria.Clear;
  FCriteriaIds.Clear;
  FSearchStatus := 'This service returned no search criteria. Browse its categories instead.';

  if not (Payload is TJSONArray) then
    Exit;

  Values := TJSONArray(Payload);

  for I := 0 to Values.Count - 1 do
    if (Values.Items[I] is TJSONObject) then
      begin
        Obj := TJSONObject(Values.Items[I]);
        Id := JsonText(Obj,
                       'scid');

        if (Id <> '') then
          begin
            cbCriteria.Items.Add(JsonText(Obj,
                                 'name'));
            FCriteriaIds.Add(Id);
          end;
      end;

  if (FCriteriaIds.Count > 0) then
    begin
      FSearchStatus := '';
      cbCriteria.ItemIndex := 0;

      for I := 0 to cbCriteria.Items.Count - 1 do
        if ContainsText(cbCriteria.Items[I],
                        'station') then
          cbCriteria.ItemIndex := I;
    end;
end;


function THEOSRadioForm.RootLocation(): THeosRadioLocation;
begin

  Result := Default(THeosRadioLocation);
  Result.SourceId := FSourceIds[cbService.ItemIndex];
  Result.Title := cbService.Text;
end;


procedure THEOSRadioForm.SourceChange(Sender: TObject);
begin

  if (FRequest <> rrNone) or (cbService.ItemIndex < 0) then
    Exit;

  if IsCustomService() then
    begin
      ShowCustomStations();
      Exit;
    end;

  cbCriteria.Clear;
  FCriteriaIds.Clear;
  edSearch.Clear;
  FSearchStatus := '';
  lvStations.Items.Clear;
  ClearArtwork();
  FItems.Clear;
  FHistory.Clear;
  FLocation := RootLocation();
  FReturned := 0;
  FTotal := 0;
  lblLocation.Caption := FLocation.Title;

  if (FSourceIds[cbService.ItemIndex] = 1028) then
    begin
      FSearchStatus := 'Favorites has no search. Select TuneIn to search for stations.';
      Browse(RootLocation(), 0);
    end
  else
    Request(rrCriteria, THeosCommands.GetSearchCriteria(FSourceIds[cbService.ItemIndex]));
end;


procedure THEOSRadioForm.Browse(const Location: THeosRadioLocation;
                                Navigation: Integer);
var
  Command: THeosCommand;

begin

  if (Location.SourceId = -1) then
    begin
      ShowCustomStations();
      Exit;
    end;

  FPendingLocation := Location;
  FNavigation := Navigation;

  if (Location.SearchText <> '') then
    Command := THeosCommands.Search(Location.SourceId,
                                    Location.SearchText,
                                    Location.CriteriaId,
                                    Location.First,
                                    Location.First + RadioPageSize - 1)
  else
    if (Location.ContainerId = '') and (Location.SourceId <> 1028) then
      Command := THeosCommands.Browse(Location.SourceId)
    else
      Command := THeosCommands.Browse(Location.SourceId,
                                      Location.ContainerId,
                                      Location.First,
                                      Location.First + RadioPageSize - 1);
  Request(rrBrowse,
          Command);
end;


procedure THEOSRadioForm.btnCloseClick(Sender: TObject);
begin

  Close();
end;


procedure THEOSRadioForm.ReadItems(Message: THeosMessage);
var
  Values: TJSONArray;
  Obj: TJSONObject;
  Item: THeosRadioItem;
  Row: TListItem;
  I: Integer;

begin

  if not (Message.Payload is TJSONArray) then
    begin lblStatus.Caption := 'Receiver did not return a station/category list.'; Exit; end;

  if (FNavigation = 0) then
    FHistory.Clear
  else
    if (FNavigation = 1) then
      FHistory.Add(FLocation)
    else
      if (FNavigation = -1) and (FHistory.Count > 0) then
        FHistory.Delete(FHistory.Count - 1);

  FLocation := FPendingLocation;
  FTotal := Message.IntegerParameter('count');
  Values := TJSONArray(Message.Payload);
  FReturned := Values.Count;
  ClearArtwork();
  FItems.Clear;
  lvStations.Items.BeginUpdate;

  try
    lvStations.Items.Clear;

    for I := 0 to Values.Count - 1 do
      if (Values.Items[I] is TJSONObject) then
        begin
          Obj := TJSONObject(Values.Items[I]);
          Item := Default(THeosRadioItem);
          Item.Name := JsonText(Obj,
                                'name');
          Item.ContainerId := JsonText(Obj,
                                       'cid');
          Item.MediaId := JsonText(Obj,
                                   'mid');
          Item.ImageUrl := JsonText(Obj,
                                    'image_url');
          Item.SourceId := FLocation.SourceId;

          if (JsonText(Obj,
                       'sid') <> '') then
            TryStrToInt64(JsonText(Obj,
                                   'sid'),
                          Item.SourceId);

          Item.IsContainer := SameText(JsonText(Obj,
                                                'container'),
                                       'yes') and  (Item.ContainerId <> '');

          Item.IsStation := SameText(JsonText(Obj,
                                     'type'),
                                     'station') and SameText(JsonText(Obj,
                                                             'playable'),
                                                             'yes') and
                            (Item.MediaId <> '');

          FItems.Add(Item);
          Row := lvStations.Items.Add;
          Row.Caption := Item.Name;

          if Item.IsContainer then
            Row.SubItems.Add('Category')
          else
            if Item.IsStation then
              Row.SubItems.Add('Station')
            else
              Row.SubItems.Add(JsonText(Obj,
                               'type'));
        end;

  finally
    lvStations.Items.EndUpdate;
  end;

  lblLocation.Caption := FLocation.Title;
  lblStatus.Caption := Format('%d entries; starting at %d. Double-click a category or select a station.',
                              [FReturned, FLocation.First + 1]);
  if (FSearchStatus <> '') then
    lblStatus.Caption := lblStatus.Caption + ' ' + FSearchStatus;
end;


procedure THEOSRadioForm.RefreshClick(Sender: TObject);
begin

  if not Assigned(FClient) or (FRequest <> rrNone) then
    Exit;

  if FPlayerFound then
    Request(rrSources, THeosCommands.GetMusicSources())
  else
    Request(rrPlayers, THeosCommands.GetPlayers());
end;


procedure THEOSRadioForm.SearchClick(Sender: TObject);
var
  Location: THeosRadioLocation;

begin

  if (FRequest <> rrNone) or (cbService.ItemIndex < 0) or (cbCriteria.ItemIndex < 0) then
    Exit;

  if (Trim(edSearch.Text) = '') or (Length(Trim(edSearch.Text)) > 128) then
    begin
      lblStatus.Caption := 'Enter a search text of 1 to 128 characters.';
      Exit;
    end;

  Location := RootLocation();
  Location.SearchText := Trim(edSearch.Text);
  Location.CriteriaId := FCriteriaIds[cbCriteria.ItemIndex];
  Location.Title := cbService.Text + ' / Search: ' + Location.SearchText;
  Browse(Location, 1);
end;


procedure THEOSRadioForm.NavigationClick(Sender: TObject);
var
  Location: THeosRadioLocation;

begin

  if (FRequest <> rrNone) or (cbService.ItemIndex < 0) then
    Exit;

  Location := FLocation;

  if (Sender = btnHome) then
    Browse(RootLocation(), 0)
  else
    if (Sender = btnBack) and (FHistory.Count > 0) then
      Browse(FHistory[FHistory.Count - 1],
             -1)
    else
      if (Sender = btnPreviousPage) and (Location.First > 0) then
        begin
          Location.First := Max(0,
                                Location.First - RadioPageSize);
          Browse(Location,
                 2);
        end
      else
        if (Sender = btnNextPage) and NextPageAvailable() then
          begin
            Inc(Location.First,
                FReturned);

            Browse(Location,
                   2);
          end;
end;


procedure THEOSRadioForm.OpenItem(Sender: TObject);
var
  Item: THeosRadioItem;
  Location: THeosRadioLocation;

begin

  if (FRequest <> rrNone) or not Assigned(lvStations.Selected) then
    Exit;

  Item := FItems[lvStations.Selected.Index];

  if Item.IsContainer then
    begin
      Location := Default(THeosRadioLocation);
      Location.SourceId := Item.SourceId;
      Location.ContainerId := Item.ContainerId;
      Location.Title := FLocation.Title + ' / ' + Item.Name;
      Browse(Location,
             1);
    end
  else
    if Item.IsStation then
      PlayClick(nil);
end;


procedure THEOSRadioForm.PlayStationClick(Sender: TObject);
begin

  // Use transport state: mouse and keyboard toggle Checked before OnClick.
  if FPlaying or Assigned(FStreamProbe) then
    StopClick(Sender)
  else
    PlayClick(Sender);

  UpdateButtons();
end;


procedure THEOSRadioForm.PlayClick(Sender: TObject);
var
  Item: THeosRadioItem;
  Command: THeosCommand;

begin

  if (FRequest <> rrNone) or not FPlayerFound or not Assigned(lvStations.Selected) then
    Exit;

  Item := FItems[lvStations.Selected.Index];

  if not Item.IsStation then
    Exit;

  try
    if (Item.StreamUrl <> '') then
      begin
        if Assigned(FStreamProbe) then
          Exit;

        FProbeItem := Item;
        FProbePlay := True;
        FStreamProbe := THeosRadioStreamProbe.Create(Item.StreamUrl);
        FStreamProbe.Start;
        StationFeedback('Checking the station URL before changing playback ...');
        UpdateButtons();
        Exit;
      end
    else
      Command := THeosCommands.PlayStation(FPlayerId,
                                           Item.SourceId,
                                           Item.MediaId,
                                           FLocation.ContainerId,
                                           Item.Name);

    // MainForm owns source handover; retain this station even if selection changes.
    if Assigned(FOnBeforePlay) then
      FOnBeforePlay(Self,
                    Command,
                    Item.Name)
    else
      StartPlayback(Command,
                    Item.Name);

  except
    on E: Exception do
      lblStatus.Caption := E.Message;
  end;
end;


function THEOSRadioForm.ReadyForPlayback(): Boolean;
begin

  Result := Assigned(FClient) and FPlayerFound and (FRequest = rrNone);
end;


procedure THEOSRadioForm.StartPlayback(const Command: THeosCommand;
                                       const StationName: string);
begin

  if not ReadyForPlayback() then
    begin
      lblStatus.Caption := 'The Radio connection is not ready for playback.';
      Exit;
    end;

  FPlaybackChecking := False;
  FPlaybackConfirmed := False;
  FPlaybackTimedOut := False;
  FPlaybackStarted := False;
  FPlaybackQueryId := 0;
  FStationName := StationName;
  Request(rrPlay, Command);
end;


procedure THEOSRadioForm.pnlTopMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  // Drag window
  ReleaseCapture;
  SendMessage(Handle,
              WM_SYSCOMMAND,
              SC_MOVE + HTCAPTION,
              0);
end;


procedure THEOSRadioForm.StopClick(Sender: TObject);
begin

  FProbePlay := False;

  THeosRadioStreamProbe.Release(FStreamProbe);

  if (FRequest = rrNone) and FPlayerFound and FPlaying then
    Request(rrStop,
            THeosCommands.SetPlayState(FPlayerId,
                                       hpsStop));

  UpdateButtons();
end;


procedure THEOSRadioForm.ReportPlayback(Playing: Boolean);
begin

  FPlaying := Playing;

  if Playing then
    lblPlaying.Caption := FPlaybackStatus + ': ' + FStationName
  else
    begin
      FPlaybackChecking := False;
      FPlaybackConfirmed := False;
      FPlaybackTimedOut := False;
      FPlaybackStarted := False;
      FPlaybackQueryId := 0;
      lblPlaying.Caption := FPlaybackStatus;
    end;

  UpdateButtons();

  if Assigned(FOnPlayback) then
    FOnPlayback(Self,
                FStationName,
                Playing);
end;


procedure THEOSRadioForm.NotifyStopped();
begin

  FProbePlay := False;

  THeosRadioStreamProbe.Release(FStreamProbe);

  FPlaying := False;
  FPlaybackChecking := False;
  FPlaybackConfirmed := False;
  FPlaybackTimedOut := False;
  FPlaybackStarted := False;
  FPlaybackQueryId := 0;
  FPlaybackStatus := 'Radio stopped';
  lblPlaying.Caption := 'No radio station started.';
  UpdateButtons();
end;


function THEOSRadioForm.PlaybackPending(): Boolean;
begin

  Result := Assigned(FStreamProbe) or (FRequest in [rrPlay, rrStop]);
end;


procedure THEOSRadioForm.RadioCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

  CanClose := True;
end;


function THEOSRadioForm.NextPageAvailable(): Boolean;
begin

  Result := (FReturned > 0) and
            ((FLocation.SearchText <> '') or
             (FLocation.ContainerId <> '') or
             (FLocation.SourceId = 1028)) and
            ((FTotal <= 0) or
            (FLocation.First + FReturned < FTotal));
end;


procedure THEOSRadioForm.UpdateButtons();
var
  Idle: Boolean;
  Selected: Boolean;

begin

  Idle := Assigned(FClient) and (FRequest = rrNone);

  Selected := Assigned(lvStations.Selected) and (lvStations.Selected.Index < FItems.Count);
  btnAddLogoPath.Enabled := CanEditStationLogo();
  edLogoUrl.Enabled := btnAddLogoPath.Enabled;
  btnAddStation.Enabled := FRequest = rrNone;
  btnRemoveStation.Enabled := (FRequest = rrNone) and IsCustomService() and Selected;
  cbService.Enabled := Idle;
  btnRefresh.Enabled := Idle;
  btnHome.Enabled := Idle and (cbService.ItemIndex >= 0);
  btnBack.Enabled := Idle and (FHistory.Count > 0);
  btnPreviousPage.Enabled := Idle and (FLocation.First > 0);
  btnNextPage.Enabled := Idle and NextPageAvailable();
  cbCriteria.Enabled := Idle and (FCriteriaIds.Count > 0);
  edSearch.Enabled := cbCriteria.Enabled;
  btnSearch.Enabled := cbCriteria.Enabled;
  chkPlayStation.Checked := FPlaying or Assigned(FStreamProbe);
  chkPlayStation.Enabled := Idle and FPlayerFound and
                            (FPlaying or Assigned(FStreamProbe) or
                             (Selected and FItems[lvStations.Selected.Index].IsStation));
  lvStations.Enabled := Idle;
end;


procedure THEOSRadioForm.SelectionChange(Sender: TObject; Item: TListItem;
                                         Selected: Boolean);
begin

  UpdateButtons();

  if Selected then
    SelectArtwork()
  else
    if not Assigned(lvStations.Selected) then
      ClearArtwork();
end;


procedure THEOSRadioForm.ClearArtwork();
begin

  FArtworkUrl := '';
  FArtworkPending := False;

  if Assigned(FArtwork) then
    FArtwork.Terminate;

  imgStationArtwork.Picture.Assign(nil);
  lblSelectedStation.Caption := '';
  edLogoUrl.Text := '';
  lblArtworkStatus.Caption := 'Select a station to see its logo.';
end;


procedure THEOSRadioForm.SelectArtwork();
var
  Item: THeosRadioItem;

begin

  ClearArtwork();

  if not Assigned(lvStations.Selected) or (lvStations.Selected.Index < 0) or (lvStations.Selected.Index >= FItems.Count) then
    Exit;

  Item := FItems[lvStations.Selected.Index];

  if not Item.IsStation then
    Exit;

  lblSelectedStation.Caption := Item.Name;
  edLogoUrl.Text := Item.ImageUrl;

  if not StartsText('http://',
                    Item.ImageUrl) and not StartsText('https://',
                                                      Item.ImageUrl) and
     not FileExists(Item.ImageUrl) then
    begin
      if (Item.StreamUrl <> '') then
        lblArtworkStatus.Caption := 'Choose a logo with the Logo button, or enter its path/URL.'
      else
        lblArtworkStatus.Caption := 'No logo supplied by the receiver.';
      Exit;
    end;

  FArtworkUrl := Item.ImageUrl;
  FArtworkPending := True;
  FArtworkRequestedTick := Heos.Cli.GetTickCount64();
  lblArtworkStatus.Caption := 'Loading station logo ...';
end;


procedure THEOSRadioForm.PollArtwork();
begin

  if Assigned(FArtwork) then
    begin
      if not FArtwork.Finished then
        Exit;

      try
        // A completed download may belong to an earlier selection.
        if not FArtworkPending and (FArtwork.Url = FArtworkUrl) then
          begin
            if Assigned(FArtwork.Graphic) then
              begin
                imgStationArtwork.Picture.Assign(FArtwork.Graphic);
                lblArtworkStatus.Caption := '';
              end
            else
              lblArtworkStatus.Caption := FArtwork.ErrorText;
          end;

      finally
        FreeAndNil(FArtwork);
      end;
    end;

  // Debounce fast keyboard/mouse selection changes.
  if FArtworkPending and (Heos.Cli.GetTickCount64() - FArtworkRequestedTick >= 150) then
    begin
      FArtworkPending := False;
      FArtwork := THeosRadioArtwork.Create(FArtworkUrl);
      FArtwork.Start;
    end;
end;


procedure THEOSRadioForm.RadioClose(Sender: TObject;
                                    var Action: TCloseAction);
begin

  Action := caHide;
end;


function THEOSRadioForm.IsCustomService(): Boolean;
begin

  Result := (cbService.ItemIndex >= 0) and (cbService.ItemIndex < FSourceIds.Count) and (FSourceIds[cbService.ItemIndex] = -1);
end;


procedure THEOSRadioForm.Label1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  // Drag window
  ReleaseCapture;
  SendMessage(Handle,
              WM_SYSCOMMAND,
              SC_MOVE + HTCAPTION,
              0);
end;


procedure THEOSRadioForm.LoadCustomStations();
var
  Settings: TMemIniFile;
  ErrorText: string;
  Item: THeosRadioItem;
  I: Integer;
  Count: Integer;
  Section: string;

begin

  FCustomItems.Clear;

  if (FStationsFile = '') or not FileExists(FStationsFile) then
    Exit;

  Settings := TMemIniFile.Create('');

  try
    if not TryLoadHeosIni(FStationsFile, Settings, ErrorText) then
      begin StationFeedback(ErrorText); Exit; end;
    Count := EnsureRange(Settings.ReadInteger('Stations',
                                              'Count',
                                              0),
                         0,
                         1000);

    for I := 0 to Count - 1 do
      begin
        Section := 'Station' + IntToStr(I);
        Item := Default(THeosRadioItem);
        Item.Name := Settings.ReadString(Section, 'Name', '');
        Item.StreamUrl := Settings.ReadString(Section, 'Url', '');
        Item.ImageUrl := Settings.ReadString(Section, 'ImageUrl', '');
        Item.IsStation := True;
        Item.SourceId := -1;

        if (Item.Name <> '') and ValidStationUrl(Item.StreamUrl) then
          FCustomItems.Add(Item);

      end;

  finally
    Settings.Free;
  end;
end;


function THEOSRadioForm.SaveCustomStations(): Boolean;
var
  Settings: TMemIniFile;
  ErrorText: string;
  Sections: TStringList;
  I: Integer;
  Section: string;

begin

  Result := False;
  if (FStationsFile = '') or not ForceDirectories(ExtractFilePath(FStationsFile)) then
    begin StationFeedback('Cannot create the radio station settings folder.'); Exit; end;

  Settings := TMemIniFile.Create('');
  Sections := TStringList.Create;

  try
    if not TryLoadHeosIni(FStationsFile, Settings, ErrorText) then
      begin StationFeedback(ErrorText); Exit; end;
    Settings.ReadSections(Sections);

    for I := 0 to Sections.Count - 1 do
      Settings.EraseSection(Sections[I]);

    Settings.WriteInteger('Stations',
                          'Count',
                          FCustomItems.Count);

    for I := 0 to FCustomItems.Count - 1 do
      begin
        Section := 'Station' + IntToStr(I);
        Settings.WriteString(Section,
                             'Name',
                             FCustomItems[I].Name);

        Settings.WriteString(Section,
                             'Url',
                             FCustomItems[I].StreamUrl);
        Settings.WriteString(Section,
                             'ImageUrl',
                             FCustomItems[I].ImageUrl);
      end;

    Result := TrySaveHeosIni(FStationsFile, Settings, ErrorText);
    if not Result then StationFeedback(ErrorText);

  finally
    Sections.Free;
    Settings.Free;
  end;
end;


function THEOSRadioForm.ValidStationUrl(const Url: string): Boolean;
var
  Address: string;
  I: Integer;

begin

  Result := False;

  if (Length(Url) > 4096) or
     not (StartsText('http://',
                     Url) or StartsText('https://',
                                        Url)) then
    Exit;

  for I := 1 to Length(Url) do
    if (Ord(Url[I]) <= 32) or CharInSet(Url[I], ['"', '<', '>', '\']) then
      Exit;

  Address := Copy(Url,
                  Pos('://', Url) + 3,
                  MaxInt);

  I := Pos('/',
           Address);

  if (I > 0) then
    Address := Copy(Address, 1, I - 1);

  // Credentials belong in the service app, not a saved station URL.
  Result := (Address <> '') and not CharInSet(Address[1], [':', '?', '#']) and
            (Pos('@',
                 Address) = 0) and (Pos('?',
                                        Address) = 0) and (Pos('#',
                                                               Address) = 0);
end;


procedure THEOSRadioForm.ShowCustomStations();
var
  I: Integer;
  Row: TListItem;

begin

  FHistory.Clear;
  FLocation := RootLocation();
  FReturned := 0;
  FTotal := 0;
  cbCriteria.Clear;
  FCriteriaIds.Clear;
  FSearchStatus := 'Custom stations use direct stream URLs; no catalogue search.';
  ClearArtwork();
  lvStations.Items.BeginUpdate;

  try
    lvStations.Items.Clear;
    FItems.Clear;

    for I := 0 to FCustomItems.Count - 1 do
      begin
        FItems.Add(FCustomItems[I]);
        Row := lvStations.Items.Add;
        Row.Caption := FCustomItems[I].Name;
        Row.SubItems.Add('Custom station');
      end;

  finally
    lvStations.Items.EndUpdate;
  end;

  lblLocation.Caption := 'My stations';
  lblStatus.Caption := Format('%d saved stations. Select a station to play its stream URL.',
                              [FCustomItems.Count]);
  UpdateButtons();
end;


procedure THEOSRadioForm.StationFeedback(const Text: string);
begin

  lblStationFeedback.Caption := Text;
  lblStationFeedback.Hint := Text;
  lblStatus.Caption := Text;
end;


procedure THEOSRadioForm.AddStationClick(Sender: TObject);
var
  Item: THeosRadioItem;
  I: Integer;

begin

  if (FRequest <> rrNone) then
    begin
      StationFeedback('Please wait for the receiver request to finish, then add the station.');
      Exit;
    end;

  if (Trim(edStationName.Text) = '') then
    begin
      StationFeedback('Not saved: enter a station name in Name, and the stream address in URL.');

      if Visible and edStationName.CanFocus then
        edStationName.SetFocus;
      Exit;
    end;

  if not ValidStationUrl(Trim(edStationUrl.Text)) then
    begin
      StationFeedback('Not saved: enter a full http:// or https:// audio stream URL.');

      if Visible and edStationUrl.CanFocus then
        edStationUrl.SetFocus;

      Exit;
    end;

  if (FCustomItems.Count >= 1000) then
    begin
      StationFeedback('Not saved: the custom station list is full (1000 stations).');

      Exit;
    end;

  Item := Default(THeosRadioItem);
  Item.Name := Trim(edStationName.Text);
  Item.StreamUrl := Trim(edStationUrl.Text);
  Item.IsStation := True;
  Item.SourceId := -1;

  for I := 0 to FCustomItems.Count - 1 do
    if SameText(FCustomItems[I].Name,
                Item.Name) then
      begin
        StationFeedback('Not saved: that station name already exists. Remove it first to replace its URL.');
        Exit;
      end;

  FCustomItems.Add(Item);

  try
    if not SaveCustomStations() then
      begin FCustomItems.Delete(FCustomItems.Count - 1); Exit; end;

  except
    on E: Exception do
      begin
        FCustomItems.Delete(FCustomItems.Count - 1);
        StationFeedback('Station not saved: ' + E.Message);
        Exit;
      end;
  end;

  I := FSourceIds.IndexOf(-1);

  if (I < 0) then
    begin
      I := cbService.Items.Add('My stations');
      FSourceIds.Add(-1);
    end;

  cbService.ItemIndex := I;
  ShowCustomStations();
  lvStations.Items[FCustomItems.Count - 1].Selected := True;
  edStationName.Clear;
  edStationUrl.Clear;
  StationFeedback('Saved "' + Item.Name + '" in My stations. Press Play station to test the stream.');
end;


procedure THEOSRadioForm.StationContextPopup(Sender: TObject;
                                             MousePos: TPoint;
                                             var Handled: Boolean);
var
  Row: TListItem;

begin

  // Keyboard invocation keeps the focused selection. A mouse invocation
  // selects the actual row under the pointer, never an older selection.
  if (MousePos.X >= 0) and (MousePos.Y >= 0) then
    begin
      Row := lvStations.GetItemAt(MousePos.X,
                                  MousePos.Y);
      lvStations.Selected := Row;

      if Assigned(Row) then
        Row.Focused := True;
    end;
end;


function THEOSRadioForm.CanEditStationLogo(): Boolean;
begin

  Result := (FRequest = rrNone) and IsCustomService() and
            Assigned(lvStations.Selected) and
            (lvStations.Selected.Index >= 0) and
            (lvStations.Selected.Index < FCustomItems.Count);
end;


function THEOSRadioForm.ApplyStationLogo(const Item: THeosRadioItem;
                                          const Value: string): Boolean;
var
  Path: string;

begin

  Result := False;
  Path := Trim(Value);

  if (Path <> '') and not ValidStationUrl(Path) then
    begin
      if not FileExists(Path) then
        begin
          StationFeedback('Logo not saved: choose an existing image file or enter a full HTTP/HTTPS image URL.');
          Exit;
        end;

      if not MatchText(ExtractFileExt(Path), ['.png', '.jpg', '.jpeg', '.gif', '.bmp']) then
        begin
          StationFeedback('Logo not saved: choose a PNG, JPEG, GIF or BMP image.');
          Exit;
        end;

      Path := ExpandFileName(Path);
    end;

  try
    SetStationLogo(Item, Path);
    Result := True;
    StationFeedback('Station logo saved.');
  except
    on E: Exception do
      StationFeedback('Logo not saved: ' + E.Message);
  end;
end;


procedure THEOSRadioForm.LogoUrlExit(Sender: TObject);
var
  Item: THeosRadioItem;

begin

  if not CanEditStationLogo() then
    Exit;

  Item := FCustomItems[lvStations.Selected.Index];

  if (Trim(edLogoUrl.Text) <> Item.ImageUrl) then
    ApplyStationLogo(Item, edLogoUrl.Text);
end;


procedure THEOSRadioForm.LogoUrlKeyDown(Sender: TObject; var Key: Word;
                                         Shift: TShiftState);
begin

  if (Key = VK_RETURN) then
    begin
      Key := 0;
      LogoUrlExit(Sender);
    end;
end;


procedure THEOSRadioForm.StationPopup(Sender: TObject);
var
  Allowed: Boolean;

begin

  Allowed := CanEditStationLogo();
  miRemoveStation.Enabled := Allowed;
  miStationLogo.Enabled := Allowed;
  miStationLogoFile.Enabled := Allowed;
end;


procedure THEOSRadioForm.SetStationLogo(const Item: THeosRadioItem;
                                         const Url: string);
var
  I: Integer;
  Updated: THeosRadioItem;
  Previous: THeosRadioItem;

begin

  for I := 0 to FCustomItems.Count - 1 do
    if SameText(FCustomItems[I].Name, Item.Name) and
       (FCustomItems[I].StreamUrl = Item.StreamUrl) then
      begin
        Previous := FCustomItems[I];
        Updated := Previous;
        Updated.ImageUrl := Url;
        FCustomItems[I] := Updated;

        try
          if not SaveCustomStations() then
            begin FCustomItems[I] := Previous; Exit; end;
        except
          FCustomItems[I] := Previous;
          raise;
        end;

        if IsCustomService() and (I < FItems.Count) then
          begin
            FItems[I] := Updated;

            if Assigned(lvStations.Selected) and (lvStations.Selected.Index = I) then
              SelectArtwork();
          end;

        Exit;
      end;
end;


procedure THEOSRadioForm.StationLogoFileClick(Sender: TObject);
var
  Item: THeosRadioItem;
  FileName: TFileName;
  FileURI: string;
  Duration: string;
  Directory: string;

begin

  if not CanEditStationLogo() then
    Exit;

  Item := FCustomItems[lvStations.Selected.Index];
  Directory := '';

  if FileExists(Item.ImageUrl) then
    Directory := ExtractFilePath(Item.ImageUrl);

  if not BrowseLWFileEx(Self,
                         fbxGraphics,
                         FileName,
                         FileURI,
                         Duration,
                         Directory) then
    Exit;

  // LW FileName is the display name; FileURI contains the complete path.
  ApplyStationLogo(Item, FileURI);
end;


procedure THEOSRadioForm.StationLogoClick(Sender: TObject);
var
  Item: THeosRadioItem;
  Url: string;

begin

  StationPopup(nil);

  if not miStationLogo.Enabled then
    Exit;

  Item := FCustomItems[lvStations.Selected.Index];
  Url := Item.ImageUrl;

  if not InputQuery('Station logo',
                     'PNG, JPEG, GIF or BMP URL (blank removes the logo):', Url) then
    Exit;

  Url := Trim(Url);

  if (Url <> '') and not ValidStationUrl(Url) then
    begin
      StationFeedback('Logo not saved: enter a full HTTP or HTTPS image URL.');
      Exit;
    end;

  try
    SetStationLogo(Item, Url);
    StationFeedback('Station logo URL saved.');
  except
    on E: Exception do
      StationFeedback('Logo not saved: ' + E.Message);
  end;
end;


procedure THEOSRadioForm.PollStreamProbe();
var
  Command: THeosCommand;
  Item: THeosRadioItem;
  ErrorText: string;
  LogoUrl: string;
  ResolvedUrl: string;
  Play: Boolean;

begin

  if not Assigned(FStreamProbe) or not FStreamProbe.Finished then
    Exit;

  Item := FProbeItem;
  ErrorText := FStreamProbe.ErrorText;
  LogoUrl := FStreamProbe.LogoUrl;
  ResolvedUrl := FStreamProbe.ResolvedUrl;
  Play := FProbePlay;
  FProbePlay := False;
  FreeAndNil(FStreamProbe);
  UpdateButtons();

  if not Play then
    Exit;

  if (Item.ImageUrl = '') and (LogoUrl <> '') then
    try
      SetStationLogo(Item, LogoUrl);
    except
      on E: Exception do
        StationFeedback('Station logo not saved: ' + E.Message);
    end;

  if (ErrorText <> '') then
    begin
      StationFeedback(ErrorText);
      Exit;
    end;

  if not ReadyForPlayback() then
    begin
      StationFeedback('The receiver connection changed while checking the URL. Select the station again.');
      Exit;
    end;

  try
    if (ResolvedUrl <> Item.StreamUrl) then
      StationFeedback('Website resolved to audio stream: ' + ResolvedUrl);

    Command := THeosCommands.PlayUrl(FPlayerId, ResolvedUrl);

    if Assigned(FOnBeforePlay) then
      FOnBeforePlay(Self, Command, Item.Name)
    else
      StartPlayback(Command, Item.Name);
  except
    on E: Exception do
      StationFeedback(E.Message);
  end;
end;


procedure THEOSRadioForm.RemoveStationClick(Sender: TObject);
var
  I: Integer;
  Item: THeosRadioItem;

begin

  if (FRequest <> rrNone) or not IsCustomService() or not Assigned(lvStations.Selected) then
    Exit;

  I := lvStations.Selected.Index;

  if (I < 0) or (I >= FCustomItems.Count) then
    Exit;

  Item := FCustomItems[I];
  FCustomItems.Delete(I);

  try
    SaveCustomStations();

  except
    on E: Exception do
      begin
        FCustomItems.Insert(I, Item);
        lblStatus.Caption := 'Station not removed: ' + E.Message;
        Exit;
      end;
  end;

  ShowCustomStations();
end;



procedure THEOSRadioForm.CheckPlayback();
var
  Stamp: UInt64;

begin

  if not FPlaybackChecking then
    Exit;

  Stamp := Heos.Cli.GetTickCount64();

  if not FPlaybackConfirmed and not FPlaybackTimedOut and (Stamp >= FPlaybackDeadline) then
    begin
      // URL streams may buffer longer than the initial confirmation window.
      // An unknown state is not evidence that playback has stopped.
      FPlaybackTimedOut := True;
      FPlaybackStatus := 'Still waiting for playback confirmation';
      if (FLastPlayState <> '') then
        FPlaybackStatus := FPlaybackStatus + ' (receiver state: ' + FLastPlayState + ')';
      FPlaybackStatus := FPlaybackStatus + '. Checking continues; Stop remains available.';
      ReportPlayback(True);
      lblStatus.Caption := FPlaybackStatus;
      UpdateButtons();
    end;

  if Assigned(FStatusClient) and (FPlaybackQueryId = 0) and (FRequest = rrNone) and (Stamp >= FNextPlaybackCheck) then
    FPlaybackQueryId := FStatusClient.Enqueue(THeosCommands.GetPlayState(FPlayerId));
end;


procedure THEOSRadioForm.PlaybackReply(Message: THeosMessage);
var
  WasConfirmed: Boolean;

begin

  FPlaybackQueryId := 0;

  if not FPlaybackChecking then
    Exit;

  WasConfirmed := FPlaybackConfirmed;
  FNextPlaybackCheck := Heos.Cli.GetTickCount64() + 2000;

  if Message.Success then
    begin
      FLastPlayState := Message.Parameter('state');

      if SameText(FLastPlayState,
                  'play') then
        begin
          FPlaybackConfirmed := True;
          FPlaybackStarted := True;
          FPlaybackTimedOut := False;
          FPlaybackStatus := 'Receiver reports playing';

          if not WasConfirmed then
            begin
              ReportPlayback(True);
              lblStatus.Caption := 'Receiver confirms play state.';
            end;

          Exit;
        end;

      if FPlaybackStarted and SameText(FLastPlayState,
                                       'stop') then
        begin
          FPlaybackStatus := 'Receiver reports stopped';
          ReportPlayback(False);
          lblStatus.Caption := FPlaybackStatus;
          UpdateButtons();
          Exit;
        end;

      if SameText(FLastPlayState,
                  'unknown') and Assigned(FStatusClient) then
        FStatusClient.Disconnect();

      FPlaybackConfirmed := False;
      FPlaybackStatus := 'Waiting for playback confirmation (receiver state: ' +
                           FLastPlayState + '). Checking continues.';
    end
  else
    begin
      FPlaybackConfirmed := False;
      FPlaybackStatus := 'Playback status unavailable; checking again: ' + Message.ErrorText;

      if Assigned(FStatusClient) then
        FStatusClient.Disconnect();
    end;

  if WasConfirmed then
    begin
      FPlaybackTimedOut := False;
      FPlaybackDeadline := Heos.Cli.GetTickCount64() + 15000;
      ReportPlayback(True);
    end;

  lblPlaying.Caption := FPlaybackStatus;
  lblStatus.Caption := FPlaybackStatus;
end;


end.
