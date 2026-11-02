// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: Media Foundation - MFPack - Samples
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HEOSRadioArtwork.pas
// Kind: Pascal Unit
// Release date: 30-10-2026
// Language: ENU
//
// Revision Version: 1.1.2.0
// Description: Asynchronous receiver-supplied station artwork.
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
unit HEOSRadioArtwork;

interface

uses

  {System}
  System.Classes,
  System.SysUtils,
  {Vcl}
  Vcl.Graphics;

type

  THeosRadioArtwork = class(TThread)
  private

    FUrl: string;
    FGraphic: TGraphic;
    FErrorText: string;

  protected

    procedure Execute(); override;

  public

    constructor Create(const Url: string);
    destructor Destroy(); override;

    property Url: string read FUrl;
    property Graphic: TGraphic read FGraphic;
    property ErrorText: string read FErrorText;
  end;

implementation

uses

  {WinApi}
  WinApi.Windows,
  WinApi.WinInet,
  {System}
  System.StrUtils,
  System.Diagnostics,
  {Vcl}
  Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.GIFImg;

constructor THeosRadioArtwork.Create(const Url: string);
begin

  inherited Create(True);
  FreeOnTerminate := False;
  FUrl := Url;
end;


destructor THeosRadioArtwork.Destroy();
begin

  Terminate;
  WaitFor;
  FGraphic.Free;
  inherited;
end;


procedure THeosRadioArtwork.Execute();
var
  Session: HINTERNET;
  Request: HINTERNET;
  Timeout: DWORD;
  Status: DWORD;
  Index: DWORD;
  Size: DWORD;
  Count: DWORD;
  Buffer: array[0..8191] of Byte;
  Stream: TMemoryStream;
  LocalFile: TFileStream;
  Clock: TStopwatch;

begin

  Session := nil;
  Request := nil;
  Stream := nil;
  try
    try
      if not StartsText('http://', FUrl) and not StartsText('https://', FUrl) then
        begin
          if not FileExists(FUrl) then
            begin
              FErrorText := 'Station logo file is unavailable.';
              Exit;
            end;
          LocalFile := TFileStream.Create(FUrl, fmOpenRead or fmShareDenyWrite);
          try
            if (LocalFile.Size > 4 * 1024 * 1024) then
              begin
                FErrorText := 'Station logo is too large.';
                Exit;
              end;
            if Terminated then
              Exit;
            Stream := TMemoryStream.Create;
            Stream.CopyFrom(LocalFile, 0);
          finally
            LocalFile.Free;
          end;
        end
      else
        begin
          Session := InternetOpen('FactoryX HEOS Remote artwork',
                                   INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
          if not Assigned(Session) then
            begin
              FErrorText := 'Cannot start the station logo request.';
              Exit;
            end;
          Timeout := 1500;
          InternetSetOption(Session, INTERNET_OPTION_CONNECT_TIMEOUT, @Timeout, SizeOf(Timeout));
          InternetSetOption(Session, INTERNET_OPTION_SEND_TIMEOUT, @Timeout, SizeOf(Timeout));
          InternetSetOption(Session, INTERNET_OPTION_RECEIVE_TIMEOUT, @Timeout, SizeOf(Timeout));
          Clock := TStopwatch.StartNew;
          if Terminated then
            Exit;
          Request := InternetOpenUrl(Session, PChar(FUrl), nil, 0,
                                      INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_CACHE_WRITE or
                                      INTERNET_FLAG_NO_COOKIES or INTERNET_FLAG_NO_UI, 0);
          if not Assigned(Request) then
            begin
              FErrorText := 'Station logo could not be downloaded.';
              Exit;
            end;
          Status := 0;
          Index := 0;
          Size := SizeOf(Status);
          if not HttpQueryInfo(Request, HTTP_QUERY_STATUS_CODE or HTTP_QUERY_FLAG_NUMBER,
                                 @Status, Size, Index) or (Status < 200) or (Status >= 300) then
            begin
              FErrorText := 'Station logo is unavailable from its server.';
              Exit;
            end;
          Stream := TMemoryStream.Create;
          while not Terminated do
            begin
              if (Clock.ElapsedMilliseconds > 4000) then
                begin
                  FErrorText := 'Station logo request timed out.';
                  Exit;
                end;
              if not InternetReadFile(Request, @Buffer[0], SizeOf(Buffer), Count) then
                begin
                  FErrorText := 'Station logo download was interrupted.';
                  Exit;
                end;
              if (Count = 0) then
                Break;
              if (Stream.Size + Count > 4 * 1024 * 1024) then
                begin
                  FErrorText := 'Station logo is too large.';
                  Exit;
                end;
              Stream.WriteBuffer(Buffer[0], Count);
            end;
        end;
      if Terminated then
        Exit;
      Stream.Position := 0;
      FillChar(Buffer, SizeOf(Buffer), 0);
      Stream.Read(Buffer[0], 8);
      Stream.Position := 0;
      if (Stream.Size >= 8) and (Buffer[0] = $89) and
         (Buffer[1] = $50) and (Buffer[2] = $4E) and (Buffer[3] = $47) then
        FGraphic := TPngImage.Create
      else
        if (Stream.Size >= 3) and (Buffer[0] = $FF) and (Buffer[1] = $D8) then
          FGraphic := TJPEGImage.Create
        else
          if (Stream.Size >= 6) and (Buffer[0] = Ord('G')) and
             (Buffer[1] = Ord('I')) and (Buffer[2] = Ord('F')) then
            FGraphic := TGIFImage.Create
          else
            if (Stream.Size >= 2) and (Buffer[0] = Ord('B')) and (Buffer[1] = Ord('M')) then
              FGraphic := Vcl.Graphics.TBitmap.Create;
      if not Assigned(FGraphic) then
        begin
          FErrorText := 'Station logo format is not supported (PNG, JPEG, GIF or BMP required).';
          Exit;
        end;
      FGraphic.LoadFromStream(Stream);
      if (FGraphic.Width > 4096) or (FGraphic.Height > 4096) then
        begin
          FreeAndNil(FGraphic);
          FErrorText := 'Station logo dimensions are too large.';
        end;
    except
      on E: Exception do
        begin
          FreeAndNil(FGraphic);
          FErrorText := 'Station logo: ' + E.Message;
        end;
    end;
  finally
    Stream.Free;
    if Assigned(Request) then
      InternetCloseHandle(Request);
    if Assigned(Session) then
      InternetCloseHandle(Session);
  end;
end;

end.
