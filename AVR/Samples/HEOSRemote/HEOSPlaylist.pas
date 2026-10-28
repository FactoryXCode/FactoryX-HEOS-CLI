// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: HEOS Remote.
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HEOSPlaylist.pas
// Kind: Pascal Unit
// Release date: 24-01-2026
// Language: ENU
//
// Revision Version: 1.0.0.1
// Description: HEOS playlist storage and background music-folder scan.
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
unit HEOSPlaylist;

interface

uses
  {System}
  System.Classes,
  System.SysUtils,
  {Application}
  RDJ.PlaylistTypes;

  function IsDenonAudioFile(const FileName: string): Boolean;
  function PlaylistEntry(const FileName: string): TRDJPlaylistEntry;

  procedure LoadPlaylist(const FileName: string;
                          Playlist: TRDJPlaylist);

  procedure SavePlaylist(const FileName: string;
                          Playlist: TRDJPlaylist);

type
  TAudioFolderScan = class(TThread)
  private
    FRoot: string;
    FFiles: TStringList;
    FError: string;
    FCount: Integer;

  protected
    procedure Execute(); override;

  public

    constructor Create(const Root: string);
    destructor Destroy(); override;

    function FileCount(): Integer;

    property Files: TStringList read FFiles;
    property ErrorText: string read FError;
  end;

implementation

uses
  {WinApi}
  WinApi.Windows,
  {System}
  System.IOUtils,
  System.StrUtils;

function IsDenonAudioFile(const FileName: string): Boolean;
var
  Ext: string;
begin

  Ext := LowerCase(ExtractFileExt(FileName));
  Result := (Ext = '.mp3') or (Ext = '.flac') or (Ext = '.wav') or
            (Ext = '.aac') or (Ext = '.m4a') or (Ext = '.wma');
end;

function PlaylistEntry(const FileName: string): TRDJPlaylistEntry;
begin

  Result := RDJEmptyPlaylistEntry();
  Result.Track.FullPath := ExpandFileName(FileName);
  Result.Track.FileName := ExtractFileName(FileName);
  Result.Track.FileExt := LowerCase(ExtractFileExt(FileName));
  Result.Track.Title := ChangeFileExt(Result.Track.FileName, '');
  Result.Track.IsMissing := not FileExists(Result.Track.FullPath);
end;

procedure LoadPlaylist(const FileName: string;
                        Playlist: TRDJPlaylist);
var
  Lines: TStringList;
  Items: TRDJPlaylist;
  Line: string;
  RawLine: string;
  Path: string;
  Title: string;
  Entry: TRDJPlaylistEntry;
  P: Integer;
  I: Integer;
begin

  Lines := TStringList.Create;
  Items := TRDJPlaylist.Create;
  try
    Lines.LoadFromFile(FileName, TEncoding.UTF8);
    Title := '';
    for RawLine in Lines do
    begin
      Line := Trim(RawLine);
      if Line = '' then
        Continue;
      if StartsText('#EXTINF:', Line) then
      begin
        P := Pos(',', Line);
        Title := Copy(Line, P + 1, MaxInt);
        Continue;
      end;
      if Line[1] = '#' then
        Continue;
      if Pos('://', Line) > 0 then
        raise Exception.Create('This playlist contains an Internet URL. Choose a playlist of local music files.');
      if not IsDenonAudioFile(Line) then
        raise Exception.Create('Unsupported playlist item: ' + Line);

      Path := Line;
      if TPath.IsRelativePath(Path) then
        Path := IncludeTrailingPathDelimiter(ExtractFilePath(ExpandFileName(FileName))) + Path;
      Entry := PlaylistEntry(Path);
      if Title <> '' then
        Entry.Track.Title := Title;
      Title := '';
      Items.Add(Entry);
    end;
    Playlist.Clear();
    for I := 0 to Items.Count - 1 do
      Playlist.Add(Items[I]);
    Playlist.RebuildSortOrder();
    Playlist.Modified := False;
  finally
    Items.Free;
    Lines.Free;
  end;
end;

procedure SavePlaylist(const FileName: string;
                        Playlist: TRDJPlaylist);
var
  Lines: TStringList;
  I: Integer;
begin

  Lines := TStringList.Create;
  try
    Lines.Add('#EXTM3U');
    for I := 0 to Playlist.Count - 1 do
    begin
      Lines.Add('#EXTINF:-1,' + Playlist[I].Track.Title);
      Lines.Add(Playlist[I].Track.FullPath);
    end;
    Lines.SaveToFile(FileName, TEncoding.UTF8);
    Playlist.Modified := False;
  finally
    Lines.Free;
  end;
end;

constructor TAudioFolderScan.Create(const Root: string);
begin

  inherited Create(True);
  FreeOnTerminate := False;
  FRoot := Root;
  FFiles := TStringList.Create;
end;

destructor TAudioFolderScan.Destroy();
begin

  Terminate;
  if Suspended then
    Start;
  WaitFor;
  FFiles.Free;
  inherited;
end;

function TAudioFolderScan.FileCount(): Integer;
begin

  Result := InterlockedCompareExchange(FCount, 0, 0);
end;

procedure TAudioFolderScan.Execute();
var
  Folders: TStringList;
  Folder: string;
  Path: string;
  Search: TSearchRec;
begin

  Folders := TStringList.Create;
  try
    try
      Folders.Add(IncludeTrailingPathDelimiter(ExpandFileName(FRoot)));

      while (Folders.Count > 0) and not Terminated do
        begin
          Folder := Folders[Folders.Count - 1];
          Folders.Delete(Folders.Count - 1);
          if FindFirst(Folder + '*',
                       faAnyFile,
                       Search) <> 0 then
          Continue;

          try
            repeat
              if Terminated then
                Break;

              if (Search.Name = '.') or (Search.Name = '..') then
                Continue;

              Path := Folder + Search.Name;
              if ((Search.Attr and faDirectory) <> 0) then
                begin

                  // Do not recurse into junctions or directory symbolic links.
                  {$WARN SYMBOL_PLATFORM OFF}
                  if ((Search.FindData.dwFileAttributes and FILE_ATTRIBUTE_REPARSE_POINT) = 0) then
                  {$WARN SYMBOL_PLATFORM ON}
                    Folders.Add(IncludeTrailingPathDelimiter(Path));
                end
              else
                if IsDenonAudioFile(Path) then
                  begin
                    FFiles.Add(Path);
                    InterlockedIncrement(FCount);
                  end;
            until (FindNext(Search) <> 0);

          finally
            System.SysUtils.FindClose(Search);
          end;

        end;

      FFiles.Sort();

    except
      on E: Exception do
        FError := E.Message;
    end;

  finally
    Folders.Free;
  end;
end;

end.

