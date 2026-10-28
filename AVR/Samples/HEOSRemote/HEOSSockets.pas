// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: HEOS Remote.
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HEOSSockets.pas
// Kind: Pascal Unit
// Release date: 24-01-2026
// Language: ENU
//
// Revision Version: 4.0.0
// Description: .
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
// Source: FactoryX.Code
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
unit HEOSSockets;

interface

uses

  {WinApi}
  WinApi.Windows,
  WinApi.WinSock,
  {System}
  System.SysUtils;

type

  EDenonSocket = class(Exception);

  THEOSConnection = class
  private
    FSocket: TSocket;
    FReadBuffer: UTF8String;

  public

    constructor Create(const Host: string;
                       Port: Word;
                       TimeoutMs: Integer = 2500);

    destructor Destroy(); override;

    procedure Send(const Text: AnsiString);
    function ReadLine(Delimiter: AnsiChar;
                      TimeoutMs: Integer): string;

    property Handle: TSocket read FSocket;
  end;

  function SocketReady(S: TSocket;
                       Writing: Boolean;
                       TimeoutMs: Integer): Boolean;

  procedure SendBytes(S: TSocket;
                      Data: Pointer;
                      Count: Integer);

  procedure SendText(S: TSocket;
                     const Text: AnsiString);

  function ReadHeader(S: TSocket): string;

  procedure SetSocketTimeout(S: TSocket;
                             TimeoutMs: Integer);

  function IPv4Valid(const Value: string): Boolean;

  function LocalAddressFor(const Receiver: string): string;

  procedure SocketCheck(Code: Integer;
                        const Operation: string);


implementation

uses

  {System}
  System.Classes,
  System.Diagnostics;

var
  WsaData: TWSAData;


procedure SocketCheck(Code: Integer;
                      const Operation: string);
begin

  if (Code = SOCKET_ERROR) then
    raise EDenonSocket.CreateFmt('%s failed (Windows socket error %d)',
                                 [Operation, WSAGetLastError]);
end;


function IPv4Valid(const Value: string): Boolean;
var
  Parts: TArray<string>;
  Part: string;
  I,
  N: Integer;

begin

  Result := False;
  Parts := Value.Split(['.']);

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
                         N) then
        Exit;

      if (N < 0) or (N > 255) then
        Exit;
    end;

  Result := True;
end;


function SocketReady(S: TSocket;
                     Writing: Boolean;
                     TimeoutMs: Integer): Boolean;
var
  Fds: TFDSet;
  Timeout: TTimeVal;
  Code: Integer;

begin

  Fds.fd_count := 1;
  Fds.fd_array[0] := S;
  Timeout.tv_sec := TimeoutMs div 1000;
  Timeout.tv_usec := (TimeoutMs mod 1000) * 1000;

  if Writing then
    Code := select(0,
                   nil,
                   @Fds,
                   nil,
                   @Timeout)
  else
    Code := select(0,
                   @Fds,
                   nil,
                   nil,
                   @Timeout);

  SocketCheck(Code,
              'Socket wait');
  Result := (Code > 0);
end;


procedure SetSocketTimeout(S: TSocket;
                           TimeoutMs: Integer);
begin

  SocketCheck(setsockopt(S,
                         SOL_SOCKET,
                         SO_SNDTIMEO,
                         PAnsiChar(@TimeoutMs),
                         SizeOf(TimeoutMs)),
              'Set send timeout');
end;


constructor THEOSConnection.Create(const Host: string;
                                    Port: Word;
                                    TimeoutMs: Integer);
var
  Addr: TSockAddrIn;
  Mode: u_long;
  Code: Integer;
  Error: Integer;
  Len: Integer;
  HostAnsi: AnsiString;

begin

  inherited Create();

  FSocket := INVALID_SOCKET;

  if not IPv4Valid(Host) then
    raise EDenonSocket.Create('Invalid receiver IPv4 address');

  FSocket := socket(AF_INET,
                    SOCK_STREAM,
                    IPPROTO_TCP);

  if (FSocket = INVALID_SOCKET) then
    SocketCheck(SOCKET_ERROR,
                'Create socket');

  FillChar(Addr,
           SizeOf(Addr),
           0);

  HostAnsi := AnsiString(Host);
  Addr.sin_family := AF_INET;
  Addr.sin_port := htons(Port);
  Addr.sin_addr.S_addr := inet_addr(PAnsiChar(HostAnsi));
  Mode := 1;

  SocketCheck(ioctlsocket(FSocket,
                          FIONBIO,
                          Mode),
              'Set nonblocking socket');

  Code := connect(FSocket,
                  Addr,
                  SizeOf(Addr));

  if (Code = SOCKET_ERROR) then
    begin
      Error := WSAGetLastError;

      if (Error <> WSAEWOULDBLOCK) then
        raise EDenonSocket.CreateFmt('Connect failed (Windows socket error %d)', [Error]);

      if not SocketReady(FSocket,
                         True,
                         TimeoutMs) then
        raise EDenonSocket.Create('Receiver connection timed out');

      Error := 0;
      Len := SizeOf(Error);

      SocketCheck(getsockopt(FSocket,
                             SOL_SOCKET,
                             SO_ERROR,
                             PAnsiChar(@Error),
                             Len),
                  'Get connection status');

      if (Error <> 0) then
        raise EDenonSocket.CreateFmt('Connect error %d',
                                   [Error]);
    end;

  Mode := 0;

  SocketCheck(ioctlsocket(FSocket,
                          FIONBIO,
                          Mode),
              'Set blocking socket');

  SetSocketTimeout(FSocket,
                   TimeoutMs);
end;


destructor THEOSConnection.Destroy();
begin

  if (FSocket <> INVALID_SOCKET) then
    closesocket(FSocket);

  inherited;
end;


procedure SendBytes(S: TSocket;
                    Data: Pointer;
                    Count: Integer);
var
  Sent: Integer;
  P: PByte;

begin

  P := Data;

  while (Count > 0) do
    begin
      Sent := Winapi.WinSock.send(S,
                                  P^,
                                  Count,
                                  0);

      SocketCheck(Sent,
                  'Send');

      if (Sent = 0) then
        raise EDenonSocket.Create('Connection closed during send');

      Inc(P,
          Sent);

      Dec(Count,
          Sent);
    end;
end;


procedure SendText(S: TSocket;
                   const Text: AnsiString);
begin
  if (Text <> '') then
    SendBytes(S,
              PAnsiChar(Text),
              Length(Text));
end;


procedure THEOSConnection.Send(const Text: AnsiString);
begin

  SendText(FSocket,
           Text);
end;


function THEOSConnection.ReadLine(Delimiter: AnsiChar;
                                   TimeoutMs: Integer): string;
var
  Buffer: array[0..4095] of AnsiChar;
  Chunk: UTF8String;
  Timer: TStopwatch;
  N: Integer;
  P: Integer;
  Remaining: Integer;

begin

  Timer := TStopwatch.StartNew();

  while True do
    begin
      P := Pos(UTF8String(Delimiter), FReadBuffer);
      if (P > 0) then
        begin
          if (P > 65537) then
            raise EDenonSocket.Create('Reply too long');

          Result := string(Copy(FReadBuffer, 1, P - 1));
          Delete(FReadBuffer, 1, P);
          Exit;
        end;

      if (Length(FReadBuffer) > 65536) then
        raise EDenonSocket.Create('Reply too long');

      Remaining := TimeoutMs - Integer(Timer.ElapsedMilliseconds);
      if (Remaining <= 0) then
        begin
          // Keep partial replies for the next poll; TCP may split any line.
          Result := '';
          Exit;
        end;

      if (Remaining > 50) then
        Remaining := 50;

      if not SocketReady(FSocket,
                         False,
                         Remaining) then
        Continue;

      N := recv(FSocket,
                Buffer,
                SizeOf(Buffer),
                0);

      SocketCheck(N,
                   'Read');
      if (N = 0) then
        begin
          if (FReadBuffer <> '') then
            raise EDenonSocket.Create('Receiver closed connection before completing reply');
          raise EDenonSocket.Create('Receiver closed connection');
        end;

      SetString(Chunk, PAnsiChar(@Buffer[0]), N);
      FReadBuffer := FReadBuffer + Chunk;
    end;
end;


function ReadHeader(S: TSocket): string;
var
  Ch: AnsiChar;
  Data: AnsiString;
  Timer: TStopwatch;
  N: Integer;

begin

  Data := '';
  Timer := TStopwatch.StartNew();

  while (Timer.ElapsedMilliseconds < 3000) do
    begin
      if not SocketReady(S,
                         False,
                         100) then
        Continue;

      N := recv(S,
                Ch,
                1,
                0);

      SocketCheck(N,
                  'Read HTTP header');

      if (N = 0) then
        raise EDenonSocket.Create('HTTP client closed');

      Data := Data + Ch;

      if (Pos(AnsiString(#13#10#13#10),
                         Data) > 0) then
        Exit(string(Data));

      if (Length(Data) > 16384) then
        raise EDenonSocket.Create('HTTP header too long');
    end;

  raise EDenonSocket.Create('HTTP header timeout');
end;


function LocalAddressFor(const Receiver: string): string;
var
  S: TSocket; Addr,
  Local: TSockAddrIn;
  Len: Integer;
  Host: AnsiString;

begin

  if not IPv4Valid(Receiver) then
    raise EDenonSocket.Create('Invalid receiver IP');

  S := socket(AF_INET,
              SOCK_DGRAM,
              IPPROTO_UDP);

  if (S = INVALID_SOCKET) then
    SocketCheck(SOCKET_ERROR,
                'Create route socket');

  try
    FillChar(Addr,
             SizeOf(Addr),
             0);

    Host := AnsiString(Receiver);
    Addr.sin_family := AF_INET;
    Addr.sin_port := htons(1255);
    Addr.sin_addr.S_addr := inet_addr(PAnsiChar(Host));

    // UDP connect selects the route; no packet is sent.
    SocketCheck(connect(S,
                        Addr,
                        SizeOf(Addr)),
                'Find route to receiver');

    Len := SizeOf(Local);

    SocketCheck(getsockname(S,
                            Local,
                            Len),
                'Find local address');

    Result := string(AnsiString(inet_ntoa(Local.sin_addr)));

  finally
    closesocket(S);
  end;
end;

initialization

  if (WSAStartup($0202,
                 WsaData) <> 0) then
    raise EDenonSocket.Create('Windows sockets could not initialize');

finalization
  WSACleanup();

end.
