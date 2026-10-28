// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: HEOS Remote.
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HEOSAudioServer.pas
// Kind: Pascal Unit
// Release date: 24-01-2026
// Language: ENU
//
// Revision Version: 4.0.0
// Description: Audio server.
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
// Source: FactoryX.Code / MfPack
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
unit HEOSAudioServer;

interface

uses

  {WinApi}
  WinApi.Windows,
  WinApi.WinSock,
  {System}
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections;

type

  THEOSAudioServer = class(TThread)
  private
    FListener: TSocket;
    FFileName, FPath, FMime, FAddress: string;
    FPort: Word;
    FLive: Boolean;
    FLock: TCriticalSection;
    FData: TQueue<TBytes>;
    FQueuedBytes: Integer;
    FRequests: Integer;
    FLastError: string;

    procedure Serve(Client: TSocket);
    function Pop(out Data: TBytes): Boolean;
    procedure SetError(const Text: string);
    function ReadClientHeader(Client: TSocket; out Header: string): Boolean;
    function SendClient(Client: TSocket; Data: Pointer; Count: Integer): Boolean;

  protected
    procedure Execute(); override;

  public

    constructor Create(const LocalAddress: string;
                       Port: Word;
                       const FileName: string;
                       Live: Boolean);

    destructor Destroy(); override;

    procedure Push(const Data: TBytes);
    function Url(): string;
    function Requests(): Integer;
    function LastError(): string;
  end;

  function AudioMime(const FileName: string): string;


implementation

uses

  {System}
  System.StrUtils,
  System.Diagnostics,
  {Application}
  HEOSSockets;

function AudioMime(const FileName: string): string;
var
  Ext: string;

begin

  Ext := LowerCase(ExtractFileExt(FileName));

  if (Ext = '.mp3') then
    Result := 'audio/mpeg'
  else
    if (Ext = '.flac') then
      Result := 'audio/flac'
    else
      if (Ext = '.wav') then
        Result := 'audio/wav'
      else
        if (Ext = '.m4a') or (Ext = '.mp4') then
          Result := 'audio/mp4'
        else
          if (Ext = '.aac') then
            Result := 'audio/aac'
          else
            if (Ext = '.wma') then
              Result := 'audio/x-ms-wma'
            else
              raise Exception.Create('Choose an MP3, FLAC, WAV, AAC, M4A or WMA audio file');
end;


constructor THEOSAudioServer.Create(const LocalAddress: string;
                                    Port: Word;
                                    const FileName: string;
                                    Live: Boolean);
var
  Addr: TSockAddrIn;
  G: TGUID;
  Token: AnsiString;
  Host: AnsiString;
  Reuse: Integer;

begin

  inherited Create(True);

  FreeOnTerminate := False;
  FListener := INVALID_SOCKET;
  FLock := TCriticalSection.Create;
  FData := TQueue<TBytes>.Create;
  FAddress := LocalAddress;
  FPort := Port;
  FFileName := FileName;
  FLive := Live;
  CreateGUID(G);
  Token := AnsiString(StringReplace(StringReplace(GUIDToString(G),
                                                  '{',
                                                  '',
                                                  []),
                                    '}',
                                    '',
                                    []));

  if Live then
    begin
      FMime := 'audio/aac';
      FPath := '/' + string(Token) + '/windows.aac';
    end
  else
    begin
      if not FileExists(FileName) then
        raise Exception.Create('Music file not found');
      FMime := AudioMime(FileName);
      FPath := '/' + string(Token) + '/track' + LowerCase(ExtractFileExt(FileName));
    end;

  FListener := socket(AF_INET,
                      SOCK_STREAM,
                      IPPROTO_TCP);

  if (FListener = INVALID_SOCKET) then
    SocketCheck(SOCKET_ERROR,
                'Create audio server');

  Reuse := 1;
  SocketCheck(setsockopt(FListener,
                         SOL_SOCKET,
                         SO_REUSEADDR,
                         PAnsiChar(@Reuse),
                         SizeOf(Reuse)),
                         'Set audio server socket reuse');

  FillChar(Addr,
           SizeOf(Addr),
           0);

  Host := AnsiString(LocalAddress);
  Addr.sin_family := AF_INET;
  Addr.sin_port := htons(Port);
  Addr.sin_addr.S_addr := inet_addr(PAnsiChar(Host));

  SocketCheck(bind(FListener,
                   Addr,
                   SizeOf(Addr)),
                   'Bind audio server');

  SocketCheck(listen(FListener,
                     4),
              'Listen for receiver');
end;


destructor THEOSAudioServer.Destroy();
begin

  Terminate();

  // Nonblocking client I/O checks Terminated at least every 100 ms.
  if Suspended then
    Start();

  WaitFor();

  if (FListener <> INVALID_SOCKET) then
    closesocket(FListener);

  FData.Free;
  FLock.Free;

  inherited;
end;


function THEOSAudioServer.Url(): string;
begin

  Result := Format('http://%s:%d%s',
                   [FAddress, FPort, FPath]);
end;


function THEOSAudioServer.Requests: Integer;
begin

  Result := InterlockedCompareExchange(FRequests,
                                       0,
                                       0);
end;


procedure THEOSAudioServer.SetError(const Text: string);
begin

  FLock.Acquire;
  try
    FLastError := Text;
  finally
    FLock.Release;
  end;
end;


function THEOSAudioServer.LastError(): string;
begin

  FLock.Acquire;
  try
    Result := FLastError;
  finally
    FLock.Release;
  end;
end;


function THEOSAudioServer.ReadClientHeader(Client: TSocket;
                                           out Header: string): Boolean;
var
  Buffer: array[0..4095] of AnsiChar;
  Data: AnsiString;
  Chunk: AnsiString;
  Fds: TFDSet;
  Timeout: TTimeVal;
  Timer: TStopwatch;
  Code: Integer;
  Error: Integer;

begin

  Result := False;
  Header := '';
  Data := '';
  Timer := TStopwatch.StartNew();

  while not Terminated do
    begin
      if (Timer.ElapsedMilliseconds >= 3000) then
        begin
          SetError('HTTP request header timed out');
          Exit;
        end;

      Fds.fd_count := 1;
      Fds.fd_array[0] := Client;
      Timeout.tv_sec := 0;
      Timeout.tv_usec := 100000;

      Code := select(0,
                     @Fds,
                     nil,
                     nil,
                     @Timeout);

      if (Code = 0) then
        Continue;

      if (Code = SOCKET_ERROR) then
        begin
          SetError(Format('HTTP read wait failed (Windows socket error %d)',
                           [WSAGetLastError]));
          Exit;
        end;

      Code := recv(Client,
                   Buffer,
                   SizeOf(Buffer),
                   0);

      if (Code = 0) then
        Exit;

      if (Code = SOCKET_ERROR) then
        begin
          Error := WSAGetLastError;

          if (Error = WSAEWOULDBLOCK) then
            Continue;

          SetError(Format('HTTP client read failed (Windows socket error %d)',
                          [Error]));
          Exit;
        end;

      SetString(Chunk,
                PAnsiChar(@Buffer[0]),
                Code);

      Data := Data + Chunk;

      if (Length(Data) > 16384) then
        begin
          SetError('HTTP request header too long');
          Exit;
        end;

      if (Pos(AnsiString(#13#10#13#10),
                         Data) > 0) then
        begin
          Header := string(Data);
          Result := True;
          Exit;
        end;
    end;
end;


function THEOSAudioServer.SendClient(Client: TSocket;
                                     Data: Pointer;
                                     Count: Integer): Boolean;
var
  P: PByte;
  Fds: TFDSet;
  Timeout: TTimeVal;
  Timer: TStopwatch;
  Sent: Integer;
  Code: Integer;
  Error: Integer;

begin

  Result := False;
  P := Data;
  Timer := TStopwatch.StartNew();

  while (Count > 0) and not Terminated do
    begin

      // File players can stop reading while their playback buffer is full.
      // Bound inactivity, rather than imposing a short blocking-send timeout.
      if (Timer.ElapsedMilliseconds >= 120000) then
        begin
          SetError('HTTP receiver stopped reading for 120 seconds; connection closed');
          Exit;
        end;

      Fds.fd_count := 1;
      Fds.fd_array[0] := Client;
      Timeout.tv_sec := 0;
      Timeout.tv_usec := 100000;

      Code := select(0,
                     nil,
                     @Fds,
                     nil,
                     @Timeout);

      if (Code = 0) then
        Continue;

      if (Code = SOCKET_ERROR) then
        begin
          SetError(Format('HTTP send wait failed (Windows socket error %d)',
                           [WSAGetLastError]));
          Exit;
        end;

      Sent := WinApi.WinSock.send(Client,
                                  P^,
                                  Count,
                                  0);

      if (Sent = SOCKET_ERROR) then
        begin
          Error := WSAGetLastError;
          if (Error = WSAEWOULDBLOCK) then
            Continue;

          SetError(Format('HTTP receiver connection ended (Windows socket error %d)',
                          [Error]));
          Exit;
        end;

      if (Sent = 0) then
        begin
          SetError('HTTP receiver closed the connection');
          Exit;
        end;

      Inc(P,
          Sent);

      Dec(Count,
          Sent);

      Timer := TStopwatch.StartNew();
    end;
  Result := (Count = 0) and not Terminated;
end;


procedure THEOSAudioServer.Push(const Data: TBytes);
var
  Old: TBytes;

begin

  if (Length(Data) = 0) then
    Exit;

  FLock.Acquire;

  try
    FData.Enqueue(Copy(Data));
    Inc(FQueuedBytes,
        Length(Data));

    // Bound memory when the receiver disconnects. Drop whole ADTS batches.
    while FQueuedBytes > 256 * 1024 do
      begin
        Old := FData.Dequeue;
        Dec(FQueuedBytes,
            Length(Old));
      end;

  finally
    FLock.Release;
  end;
end;


function THEOSAudioServer.Pop(out Data: TBytes): Boolean;
begin

  FLock.Acquire;

  try
    Result := FData.Count > 0;

    if Result then
      begin
        Data := FData.Dequeue;
        Dec(FQueuedBytes,
            Length(Data));
      end;

  finally
    FLock.Release;
  end;
end;


procedure THEOSAudioServer.Execute();
var
  Client: TSocket;
  Mode: u_long;

begin

  while not Terminated do
    begin
      try
        if not SocketReady(FListener,
                           False,
                           100) then
          Continue;

        Client := accept(FListener,
                         nil,
                         nil);

        if (Client = INVALID_SOCKET) then
          Continue;

        try
          Mode := 1;

          if (ioctlsocket(Client,
                          FIONBIO, Mode) = SOCKET_ERROR) then
            begin
              SetError(Format('Cannot set HTTP client nonblocking mode (Windows socket error %d)',
                              [WSAGetLastError]));
              Continue;
            end;

          SetError('');
          Serve(Client);

        finally
          closesocket(Client);
        end;

    except

      // A failed receiver request must not kill the listener. The next request
      // can reconnect; UI reports the request count and HEOS result separately.
      on E: Exception do
        SetError('Denon audio HTTP: ' + E.Message);
      end;
    end;
end;


procedure THEOSAudioServer.Serve(Client: TSocket);
var
  Header: string;
  First: string;
  Method: string;
  Path: string;
  Range: string;
  Text: string;
  Lines: TArray<string>;
  N: Integer;
  P: Integer;
  Count: Integer;
  IsHead: Boolean;
  Partial: Boolean;
  InvalidRange: Boolean;
  FileStream: TFileStream;
  StartByte: Int64;
  EndByte: Int64;
  Total: Int64;
  Remaining: Int64;
  Suffix: Int64;
  Data: TBytes;
  Buffer: array[0..32767] of Byte;

  // Helper
  function Respond(const Status,
                    Extra: string): Boolean;
  var
    Response: AnsiString;

  begin

    Response := AnsiString('HTTP/1.1 ' + Status + #13#10 + 'Connection: close' + #13#10 + Extra + #13#10);
    Result := SendClient(Client,
                         PAnsiChar(Response),
                         Length(Response));
  end;

begin

  if not ReadClientHeader(Client,
                          Header) then
    Exit;

  Lines := Header.Split([#10]);
  First := Trim(Lines[0]);

  P := Pos(' ',
           First);

  Method := Copy(First,
                 1,
                 P - 1);

  Delete(First,
         1,
         P);

  P := Pos(' ',
           First);
  Path := Copy(First,
               1,
               P - 1);

  IsHead := Method = 'HEAD';

  if (Method <> 'GET') and not IsHead then
    begin
      Respond('405 Method Not Allowed',
              'Content-Length: 0' + #13#10);
      Exit;
    end;

  if (Path <> FPath) then
    begin
      Respond('404 Not Found',
              'Content-Length: 0' + #13#10);
      Exit;
    end;

  InterlockedIncrement(FRequests);

  if FLive then
    begin
      if not Respond('200 OK',
                       'Content-Type: audio/aac' + #13#10 + 'Cache-Control: no-store' + #13#10 + 'Accept-Ranges: none' + #13#10) then
        Exit;

      if IsHead then
        Exit;

      FLock.Acquire;

      try FData.Clear;
        FQueuedBytes := 0;

      finally
        FLock.Release;
      end;

      // A continuous close-delimited stream avoids chunked-transfer assumptions.
      while not Terminated do
        begin
          if Pop(Data) then
            begin
              if not SendClient(Client,
                                @Data[0],
                                Length(Data)) then
                Exit;
            end
          else
            Sleep(10);
        end;

      Exit;
    end;

  FileStream := TFileStream.Create(FFileName,
                                   fmOpenRead or fmShareDenyWrite);

  try
    Total := FileStream.Size;
    StartByte := 0;
    EndByte := Total - 1;
    Range := '';
    Partial := False;
    InvalidRange := False;

    for Text in Lines do
      if StartsText('Range:',
                    Trim(Text)) then
        Range := Trim(Copy(Trim(Text),
                           7,
                           MaxInt));

    if (Range <> '') then
      begin
        Partial := True;

        if not StartsText('bytes=',
                          Range) or (Pos(',',
                                         Range) > 0) then
          InvalidRange := True
        else
          begin
            Delete(Range,
                   1,
                   6);

            P := Pos('-',
                     Range);

            if (P = 0) then
              InvalidRange := True
            else
              if (P = 1) then
                begin
                  if not TryStrToInt64(Copy(Range,
                                            2,
                                            MaxInt),
                                       Suffix) or (Suffix <= 0) then
                    InvalidRange := True
                  else
                    begin
                      StartByte := Total - Suffix;
                      if (StartByte < 0) then
                        StartByte := 0; end;
                end
                  else
                    begin
                      if not TryStrToInt64(Copy(Range,
                                                1,
                                                P - 1),
                                           StartByte) then
                        InvalidRange := True;

                      if (P < Length(Range)) then
                        if not TryStrToInt64(Copy(Range,
                                                  P + 1,
                                                  MaxInt),
                                             EndByte) then
                          InvalidRange := True;
                    end;
          end;

        if (StartByte < 0) or (StartByte >= Total) or (EndByte < StartByte) then
          InvalidRange := True;

        if (EndByte >= Total) then
          EndByte := Total - 1;

        if InvalidRange then
          begin
            Respond('416 Range Not Satisfiable',
                    Format('Content-Range: bytes */%d'#13#10'Content-Length: 0'#13#10,
                           [Total]));
            Exit;
          end;
      end;


    Header := 'Content-Type: ' + FMime + #13#10 + 'Accept-Ranges: bytes' + #13#10;
    Remaining := EndByte - StartByte + 1;
    Header := Header + 'Content-Length: ' + IntToStr(Remaining) + #13#10;

    if Partial then
      begin
        Header := Header + Format('Content-Range: bytes %d-%d/%d'#13#10,
                                  [StartByte, EndByte, Total]);

        if not Respond('206 Partial Content',
                       Header) then
          Exit;
      end
    else
      if not Respond('200 OK',
                     Header) then
        Exit;

    if IsHead then
      Exit;

    FileStream.Position := StartByte;

    while (Remaining > 0) and not Terminated do
      begin
        Count := SizeOf(Buffer);

        if (Remaining < Count) then
          Count := Integer(Remaining);

        N := FileStream.Read(Buffer,
                             Count);
        if (N = 0) then
          Break;

      if not SendClient(Client,
                        @Buffer[0],
                        N) then
        Exit;

      Dec(Remaining,
          N);
    end;

  finally
    FileStream.Free;
  end;
end;

end.
