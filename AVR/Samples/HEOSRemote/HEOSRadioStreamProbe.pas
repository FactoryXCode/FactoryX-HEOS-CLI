// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: Media Foundation - MFPack - Samples
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HEOSRadioStreamProbe.pas
// Kind: Pascal Unit
// Release date: 30-10-2026
// Language: ENU
//
// Revision Version: 1.1.2.0
// Description: Asynchronous custom station URL response check.
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
unit HEOSRadioStreamProbe;

interface

uses

  System.Classes,
  System.SysUtils;

type

  THeosRadioStreamProbe = class(TThread)
  private

    FUrl: string;
    FErrorText: string;
    FLogoUrl: string;
    FResolvedUrl: string;

    function ProbeUrl(const Url: string; ResolveWebsite: Boolean): Boolean;

  protected

    procedure Execute(); override;

  public

    constructor Create(const Url: string);
    destructor Destroy(); override;
    class procedure Release(var Probe: THeosRadioStreamProbe); static;
    property ErrorText: string read FErrorText;
    property LogoUrl: string read FLogoUrl;
    property ResolvedUrl: string read FResolvedUrl;
  end;

implementation

uses

  Winapi.Windows,
  Winapi.WinInet,
  System.StrUtils,
  System.RegularExpressions;

function StreamInternetError(const Action: string; ErrorCode: DWORD): string;
var
  Buffer: array[0..1023] of Char;
  Text: string;

begin

  Text := '';

  if (FormatMessage(FORMAT_MESSAGE_FROM_HMODULE or FORMAT_MESSAGE_FROM_SYSTEM or
                      FORMAT_MESSAGE_IGNORE_INSERTS,
                      Pointer(GetModuleHandle('wininet.dll')), ErrorCode, 0,
                      @Buffer[0], Length(Buffer), nil) > 0) then
    Text := Trim(PChar(@Buffer[0]));

  if (Text = '') then
    Text := 'Check the URL, network access and whether the audio server is running.';

  Result := Format('%s (WinINet error %d): %s', [Action, ErrorCode, Text]);
end;


class procedure THeosRadioStreamProbe.Release(var Probe: THeosRadioStreamProbe);
var
  Pending: THeosRadioStreamProbe;
  Reaper: TThread;

begin

  Pending := Probe;
  Probe := nil;

  if not Assigned(Pending) then
    Exit;

  Pending.Terminate;

  if Pending.Finished then
    begin
      Pending.Free();
      Exit;
    end;

  // WinINet cancellation can still be waiting for DNS or a receive timeout.
  // This independent worker owns no form references. Join it off the UI thread.
  Reaper := TThread.CreateAnonymousThread(
    procedure
    begin

      Pending.WaitFor();
      Pending.Free();
    end);
  Reaper.FreeOnTerminate := True;
  Reaper.Start();
end;


constructor THeosRadioStreamProbe.Create(const Url: string);
begin

  inherited Create(True);
  FreeOnTerminate := False;
  FUrl := Url;
end;


destructor THeosRadioStreamProbe.Destroy();
begin

  Terminate;
  WaitFor;
  inherited;
end;


procedure THeosRadioStreamProbe.Execute();
begin

  ProbeUrl(FUrl, True);
end;


function THeosRadioStreamProbe.ProbeUrl(const Url: string;
                                        ResolveWebsite: Boolean): Boolean;
var
  Session: HINTERNET;
  Request: HINTERNET;
  Timeout: DWORD;
  Status: DWORD;
  ErrorCode: DWORD;
  Size: DWORD;
  Index: DWORD;
  Count: DWORD;
  Header: array[0..511] of Char;
  Buffer: array[0..4095] of Byte;
  Combined: array[0..8191] of Char;
  ContentType: string;
  EffectiveUrl: string;
  AudioUrl: string;
  Html: string;
  HtmlBytes: UTF8String;
  Link: TMatch;
  Href: TMatch;
  Stream: TMemoryStream;
begin

  Result := False;
  Session := nil;
  Request := nil;
  Stream := nil;

  try
    try
      Session := InternetOpen('FactoryX HEOS Remote stream check',
                               INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

      if not Assigned(Session) then
        begin
          ErrorCode := Winapi.Windows.GetLastError();
          FErrorText := StreamInternetError('Cannot initialize the URL check', ErrorCode);
          Exit;
        end;

      Timeout := 1500;
      InternetSetOption(Session, INTERNET_OPTION_CONNECT_TIMEOUT, @Timeout, SizeOf(Timeout));
      InternetSetOption(Session, INTERNET_OPTION_SEND_TIMEOUT, @Timeout, SizeOf(Timeout));
      InternetSetOption(Session, INTERNET_OPTION_RECEIVE_TIMEOUT, @Timeout, SizeOf(Timeout));

      if Terminated then
        Exit;

      Request := InternetOpenUrl(Session, PChar(Url), nil, 0,
                                  INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_CACHE_WRITE or
                                  INTERNET_FLAG_NO_COOKIES or INTERNET_FLAG_NO_UI, 0);

      if not Assigned(Request) then
        begin
          ErrorCode := Winapi.Windows.GetLastError();
          FErrorText := StreamInternetError('Cannot reach the stream URL from this PC', ErrorCode);
          Exit;
        end;

      Status := 0;
      Index := 0;
      Size := SizeOf(Status);

      if not HttpQueryInfo(Request, HTTP_QUERY_STATUS_CODE or HTTP_QUERY_FLAG_NUMBER,
                             @Status, Size, Index) then
        begin
          ErrorCode := Winapi.Windows.GetLastError();
          FErrorText := StreamInternetError('Cannot read the HTTP response', ErrorCode);
          Exit;
        end;

      if (Status < 200) or (Status >= 300) then
        begin
          FErrorText := Format('The stream URL returned HTTP %d. Check that its audio server is running.', [Status]);
          Exit;
        end;

      Index := 0;
      Size := SizeOf(Header);
      ContentType := '';

      if HttpQueryInfo(Request, HTTP_QUERY_CONTENT_TYPE, @Header[0], Size, Index) then
        ContentType := LowerCase(Trim(PChar(@Header[0])));

      EffectiveUrl := Url;
      Size := SizeOf(Combined);

      if InternetQueryOption(Request, INTERNET_OPTION_URL, @Combined[0], Size) then
        EffectiveUrl := PChar(@Combined[0]);

      if StartsText('text/html', ContentType) or
         StartsText('application/xhtml', ContentType) then
        begin
          FErrorText := 'This URL is a webpage, not an audio stream. HEOS needs a direct MP3/AAC stream URL; the browser broadcast cannot be played directly.';
          // Resolve a website only once; an HTML fallback must never loop.
          if not ResolveWebsite then
            Exit;

          Stream := TMemoryStream.Create();

          // Read only a small HTML prefix for an optional station icon.
          while (Stream.Size < 32768) and not Terminated do
            begin
              Count := 0;

              if not InternetReadFile(Request, @Buffer[0], SizeOf(Buffer), Count) or (Count = 0) then
                Break;

              Stream.WriteBuffer(Buffer[0], Count);
            end;

          SetString(HtmlBytes, PAnsiChar(Stream.Memory), Stream.Size);
          Html := UTF8ToString(HtmlBytes);

          for Link in TRegEx.Matches(Html, '<link\b[^>]*>', [roIgnoreCase]) do
            if TRegEx.IsMatch(Link.Value, 'rel\s*=\s*["''][^"'']*(?:apple-touch-icon|icon)', [roIgnoreCase]) then
              begin
                Href := TRegEx.Match(Link.Value, 'href\s*=\s*["'']([^"'']+)["'']', [roIgnoreCase]);

                if Href.Success then
                  begin
                    Size := Length(Combined);

                    if InternetCombineUrl(PChar(EffectiveUrl), PChar(Href.Groups[1].Value),
                                            @Combined[0], Size, 0) then
                      FLogoUrl := PChar(@Combined[0]);

                    Break;
                  end;
              end;

          if Terminated then
            Exit;

          Size := Length(Combined);

          if not InternetCombineUrl(PChar(EffectiveUrl), '/radio/live.aac',
                                       @Combined[0], Size, 0) then
            Exit;

          AudioUrl := PChar(@Combined[0]);
          FErrorText := '';
          InternetCloseHandle(Request);
          Request := nil;
          Result := ProbeUrl(AudioUrl, False);

          if not Result and not Terminated then
            FErrorText := 'This URL is a webpage. Its direct AAC stream is unavailable (' +
                          AudioUrl + '): ' + FErrorText;
          Exit;
        end
      else if StartsText('image/', ContentType) or
              StartsText('text/', ContentType) or
              StartsText('application/json', ContentType) then
        FErrorText := 'This URL does not return audio (Content-Type: ' + ContentType + '). Enter a direct MP3/AAC stream URL.';

      // A guessed website endpoint must explicitly identify itself as AAC.
      if not ResolveWebsite and (FErrorText = '') and
         not SameText(Trim(Copy(ContentType, 1, Pos(';', ContentType + ';') - 1)), 'audio/aac') and
         not SameText(Trim(Copy(ContentType, 1, Pos(';', ContentType + ';') - 1)), 'audio/aacp') and
         not SameText(Trim(Copy(ContentType, 1, Pos(';', ContentType + ';') - 1)), 'audio/x-aac') and
         not SameText(Trim(Copy(ContentType, 1, Pos(';', ContentType + ';') - 1)), 'audio/adts') then
        FErrorText := 'The AAC endpoint did not return AAC audio (Content-Type: ' + ContentType + ').';

      if not Terminated and (FErrorText = '') then
        begin
          FResolvedUrl := EffectiveUrl;
          Result := True;
        end;
    except
      on E: Exception do
        if (FErrorText = '') then
          FErrorText := E.Message;
    end;
  finally
    Stream.Free();

    if Assigned(Request) then
      InternetCloseHandle(Request);

    if Assigned(Session) then
      InternetCloseHandle(Session);
  end;
end;

end.
