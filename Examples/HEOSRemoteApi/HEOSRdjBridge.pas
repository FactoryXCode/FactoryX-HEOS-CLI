// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: HEOS Remote.
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HEOSRdjBridge.pas
// Kind: Pascal Unit
// Release date: 24-01-2026
// Language: ENU
//
// Revision Version: 1.0.0.1
// Description: RDJ Pro playlist actions routed to the Denon receiver.
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
// Remarks: Requires Windows 10 22H2 or higher.
//          Please, read documentation carefully!
//
// Related objects: -
// Related projects: MfPackX400
// Known Issues: -
//
// Compiler version: 23 up to 35
// SDK version: 10.0.28000.2705
//
// Todo: -
//
// =============================================================================
// Source: FactoryX.Code.
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
unit HEOSRdjBridge;

interface

uses
  {WinApi}
  WinApi.Windows,
  {System}
  System.Classes,
  System.SysUtils,
  {Application}
  RDJ.PlaylistTypes;

type
  THEOSRdjRouteEvent = procedure(Sender: TObject;
                                 Playlist: TRDJPlaylist;
                                 StartIndex: Integer;
                                 StartPlayback: Boolean) of object;

  THEOSDeckAdapter = class
  private
    FDatabaseFile: string;
    FOnRoute: THEOSRdjRouteEvent;

    function RoutePlaylist(const PlaylistID: Integer;
                             StartPlayback: Boolean): HRESULT;

  public

    function LoadSingleTrack(const FileName: string;
                               StartPlayback: Boolean = False): HRESULT;
    function PlayPlaylistByID(PlaylistID: Integer): HRESULT;
    function LoadPlaylistByID(PlaylistID: Integer): HRESULT;

    property DatabaseFile: string read FDatabaseFile write FDatabaseFile;
    property OnRoute: THEOSRdjRouteEvent read FOnRoute write FOnRoute;
  end;

  THEOSRdjBridge = class
  private
    FDeck: THEOSDeckAdapter;

  public

    constructor Create(const DatabaseFile: string;
                         Route: THEOSRdjRouteEvent);
    destructor Destroy(); override;

    function GetChannelDeckCount(): Integer;
    function GetChannelDeck(Index: Integer): THEOSDeckAdapter;
  end;

var
  MainMDIFrm: THEOSRdjBridge;

implementation

uses
  {Application}
  RDJ.PlaylistDb,
  RDJ.TrackLibrary,
  RDJ.PlaylistManager;

constructor THEOSRdjBridge.Create(const DatabaseFile: string;
                                    Route: THEOSRdjRouteEvent);
begin

  inherited Create;
  FDeck := THEOSDeckAdapter.Create;
  FDeck.DatabaseFile := DatabaseFile;
  FDeck.OnRoute := Route;
end;

destructor THEOSRdjBridge.Destroy();
begin

  FDeck.Free;
  inherited;
end;

function THEOSRdjBridge.GetChannelDeckCount(): Integer;
begin

  Result := 1;
end;

function THEOSRdjBridge.GetChannelDeck(Index: Integer): THEOSDeckAdapter;
begin

  Result := nil;
  if Index = 0 then
    Result := FDeck;
end;

function THEOSDeckAdapter.LoadSingleTrack(const FileName: string;
                                            StartPlayback: Boolean): HRESULT;
var
  Playlist: TRDJPlaylist;
  Entry: TRDJPlaylistEntry;
begin

  Result := HRESULT($80004005);
  if not FileExists(FileName) then
    Exit(HRESULT($80070002));
  if not Assigned(FOnRoute) then
    Exit;
  Playlist := TRDJPlaylist.Create;
  try
    Entry := RDJEmptyPlaylistEntry();
    Entry.Track.FullPath := ExpandFileName(FileName);
    Entry.Track.FileName := ExtractFileName(FileName);
    Entry.Track.Title := ChangeFileExt(Entry.Track.FileName, '');
    Playlist.Add(Entry);
    FOnRoute(Self, Playlist, 0, StartPlayback);
    Result := S_OK;
  finally
    Playlist.Free;
  end;
end;

function THEOSDeckAdapter.RoutePlaylist(const PlaylistID: Integer;
                                          StartPlayback: Boolean): HRESULT;
var
  Db: TRDJPlaylistDb;
  LibraryRef: TRDJTrackLibrary;
  Manager: TRDJPlaylistManager;
  Playlist: TRDJPlaylist;
begin

  Result := HRESULT($80004005);
  if not Assigned(FOnRoute) then
    Exit;
  Db := TRDJPlaylistDb.Create;
  LibraryRef := nil;
  Manager := nil;
  Playlist := nil;
  try
    Db.Open(FDatabaseFile);
    LibraryRef := TRDJTrackLibrary.Create(Db);
    Manager := TRDJPlaylistManager.Create(Db, LibraryRef);
    Playlist := Manager.LoadPlaylist(PlaylistID);
    if (Playlist = nil) or (Playlist.Count = 0) then
      Exit;
    FOnRoute(Self, Playlist, 0, StartPlayback);
    Result := S_OK;
  finally
    Playlist.Free;
    Manager.Free;
    LibraryRef.Free;
    Db.Free;
  end;
end;

function THEOSDeckAdapter.PlayPlaylistByID(PlaylistID: Integer): HRESULT;
begin

  Result := RoutePlaylist(PlaylistID, True);
end;

function THEOSDeckAdapter.LoadPlaylistByID(PlaylistID: Integer): HRESULT;
begin

  Result := RoutePlaylist(PlaylistID, False);
end;

end.
