// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: Media Foundation - MFPack - Samples
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HEOS.RDJPlaylistImport.pas
// Kind: Pascal Unit
// Release date: 24-01-2026
// Language: ENU
//
// Revision Version: 4.0.0
// Description: Opens SQLite database, create schema, load/save tracks,
//              load/save playlists and runs queries
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
//          Please, read documentation carefully!
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
unit HEOS.RDJPlaylistImport;

interface

uses

  {System}
  System.SysUtils,
  System.Generics.Collections,
  {Application}
  RDJ.PlaylistTypes,
  RDJ.PlaylistDb;

type

  THEOSRDJPlaylistImport = class
  public

    class function GetPlaylists(const ADatabaseFile: string): TList<TRDJPlaylistInfo>;
    class function ImportPlaylist(ADestination: TRDJPlaylistDb;
                                  const ADatabaseFile: string;
                                  const APlaylistID: Integer;
                                  out ATrackCount: Integer;
                                  out AMissingCount: Integer): Integer;
  end;


implementation

uses

  {FireDAC}
  FireDAC.Comp.Client,
  {Application}
  RDJ.TrackLibrary,
  RDJ.PlaylistManager;


class function THEOSRDJPlaylistImport.GetPlaylists(const ADatabaseFile: string): TList<TRDJPlaylistInfo>;
var
  Db: TRDJPlaylistDb;
  LibraryRef: TRDJTrackLibrary;
  Manager: TRDJPlaylistManager;

begin

  Db := TRDJPlaylistDb.Create;
  LibraryRef := nil;
  Manager := nil;

  try

    Db.OpenReadOnly(ADatabaseFile);
    LibraryRef := TRDJTrackLibrary.Create(Db);
    Manager := TRDJPlaylistManager.Create(Db,
                                         LibraryRef);
    Result := Manager.GetAllPlaylists();
  finally

    Manager.Free;
    LibraryRef.Free;
    Db.Free;
  end;
end;


class function THEOSRDJPlaylistImport.ImportPlaylist(ADestination: TRDJPlaylistDb;
                                                     const ADatabaseFile: string;
                                                     const APlaylistID: Integer;
                                                     out ATrackCount: Integer;
                                                     out AMissingCount: Integer): Integer;
var
  SourceDb: TRDJPlaylistDb;
  SourceLibrary: TRDJTrackLibrary;
  DestinationManager: TRDJPlaylistManager;
  Names: TList<TRDJPlaylistInfo>;
  Playlist: TRDJPlaylist;
  Q: TFDQuery;
  Info: TRDJPlaylistInfo;
  Entry: TRDJPlaylistEntry;
  Track: TRDJTrack;
  BaseName: string;
  NewName: string;
  NameUsed: Boolean;
  Suffix: Integer;
  i: Integer;
  TrackID: Integer;

begin

  Result := 0;
  ATrackCount := 0;
  AMissingCount := 0;

  if (ADestination = nil) or not ADestination.IsOpen() then
    raise Exception.Create('The HEOS playlist database is not open.');

  if SameFileName(ExpandFileName(ADatabaseFile),
                  ExpandFileName(ADestination.DbFileName)) then
    raise Exception.Create('Select the RDJ Pro database, not the current HEOS database.');

  SourceDb := TRDJPlaylistDb.Create;
  SourceLibrary := nil;
  DestinationManager := nil;
  Names := nil;
  Playlist := TRDJPlaylist.Create;
  Q := TFDQuery.Create(nil);

  try

    SourceDb.OpenReadOnly(ADatabaseFile);
    SourceLibrary := TRDJTrackLibrary.Create(SourceDb);
    SourceDb.BeginTx();
    Q.Connection := SourceDb.Connection;
    Q.SQL.Text := 'SELECT Name, Notes FROM Playlists WHERE PlaylistID = :ID';
    Q.ParamByName('ID').AsInteger := APlaylistID;
    Q.Open;

    if Q.Eof then
      raise Exception.Create('The selected RDJ Pro playlist no longer exists.');

    Info := RDJEmptyPlaylistInfo();
    Info.Name := Q.FieldByName('Name').AsString;
    Info.Notes := Q.FieldByName('Notes').AsString;
    Playlist.Info := Info;
    Q.Close;
    Q.SQL.Text := 'SELECT TrackID, CueInMs, CueOutMs, UserNote ' +
                  'FROM PlaylistItems WHERE PlaylistID = :ID ' +
                  'ORDER BY SortOrder, PlaylistItemID';
    Q.ParamByName('ID').AsInteger := APlaylistID;
    Q.Open;

    // Read only the selected playlist and its tracks, never the entire library.
    while not Q.Eof do
      begin

        Entry := RDJEmptyPlaylistEntry();
        Entry.TrackID := Q.FieldByName('TrackID').AsInteger;

        if not SourceLibrary.FindTrackByID(Entry.TrackID,
                                           Track) then
          raise Exception.Create('A playlist item refers to a missing RDJ Pro database track.');

        if (Trim(Track.FullPath) = '') then
          raise Exception.Create('A playlist track has no audio file path.');

        Track.IsMissing := not FileExists(Track.FullPath);
        Entry.Track := Track;
        Entry.CueInMs := Q.FieldByName('CueInMs').AsLargeInt;
        Entry.CueOutMs := Q.FieldByName('CueOutMs').AsLargeInt;
        Entry.UserNote := Q.FieldByName('UserNote').AsString;
        Playlist.Add(Entry);
        Q.Next;
      end;

    Q.Close;
    SourceDb.CommitTx();

    DestinationManager := TRDJPlaylistManager.Create(ADestination,
                                                     nil);
    // Keep name allocation, tracks and playlist items in one transaction.
    ADestination.BeginTx();

    try

      Names := DestinationManager.GetAllPlaylists();
      BaseName := Trim(Playlist.Info.Name);

      if (BaseName = '') then
        BaseName := 'Imported RDJ Pro playlist';

      NewName := BaseName;
      Suffix := 1;

      repeat

        NameUsed := False;

        for i := 0 to Names.Count - 1 do
          if SameText(Names[i].Name,
                       NewName) then
            begin

              NameUsed := True;
              Break;
            end;

        if NameUsed then
          begin

            Inc(Suffix);
            NewName := Format('%s (%d)',
                               [BaseName, Suffix]);
          end;
      until not NameUsed;

      Result := ADestination.CreatePlaylist(NewName,
                                              Playlist.Info.Notes);

      for i := 0 to Playlist.Count - 1 do
        begin

          Entry := Playlist[i];
          TrackID := ADestination.FindTrackByPath(Entry.Track.FullPath);

          // Reuse existing HEOS tracks without overwriting their tags or cues.
          if (TrackID = 0) then
            TrackID := ADestination.AddOrUpdateTrack(Entry.Track);

          ADestination.AddPlaylistItem(Result,
                                         TrackID,
                                         i + 1,
                                         Entry.CueInMs,
                                         Entry.CueOutMs,
                                         Entry.UserNote);

          if Entry.Track.IsMissing then
            Inc(AMissingCount);
        end;

      ADestination.CommitTx();
      ATrackCount := Playlist.Count;
    except

      ADestination.RollbackTx();
      Result := 0;
      AMissingCount := 0;
      raise;
    end;
  finally

    Q.Free;
    Playlist.Free;
    Names.Free;
    DestinationManager.Free;
    SourceLibrary.Free;
    SourceDb.Free;
  end;
end;

end.