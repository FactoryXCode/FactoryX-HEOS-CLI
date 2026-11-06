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

    constructor CreateSocket(ASocket: TSocket);

  public

    // Compatibility entry points. Live callers should use the Try methods.
    constructor Create(const Host: string;
                       Port: Word;
                       TimeoutMs: Integer = 2500);
    destructor Destroy; override;

    class function TryConnect(const Host: string;
                              Port: Word;
                              TimeoutMs: Integer;
                              out Connection: THEOSConnection;
                              out ErrorText: string): Boolean; static;

    function TrySend(const Text: AnsiString;
                     out ErrorText: string): Boolean;

    function TryReadLine(Delimiter: AnsiChar;
                         TimeoutMs: Integer;
                         out Line: string;
                         out ErrorText: string): Boolean;

    procedure Send(const Text: AnsiString);
    function ReadLine(Delimiter: AnsiChar;
                      TimeoutMs: Integer): string;

    property Handle: TSocket read FSocket;
  end;

  function TrySocketReady(S: TSocket;
                          Writing: Boolean;
                          TimeoutMs: Integer;
                          out Ready: Boolean;
                          out ErrorText: string): Boolean;

  function TrySendBytes(S: TSocket;
                        Data: Pointer;
                        Count: Integer;
                        out ErrorText: string): Boolean;

  function TryReadHeader(S: TSocket;
                         out Header: string;
                         out ErrorText: string): Boolean;

  function TryLocalAddressFor(const Receiver: string;
                              out Address: string;
                              out ErrorText: string): Boolean;

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

  function ProbeReceiver(const Host: string;
                         Port: Word;
                         TimeoutMs: Integer;
                         out ErrorText: string): Boolean;

  function LocalAddressFor(const Receiver: string): string;
  procedure SocketCheck(Code: Integer;
                        const Operation: string);


implementation

uses

  {System}
  System.Diagnostics;

var

  WsaData: TWSAData;
  StartupError: Integer;


function SocketError(const Operation: string;
                     Code: Integer): string;

begin

  Result := Format('%s (Windows socket error %d).',
                   [Operation, Code]);
end;


function IPv4Valid(const Value: string): Boolean;
var
  Part: string;
  I: Integer;
  N: Integer;
  Parts: TArray<string>;

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
                         N) or (N < 0) or (N > 255) then
        Exit;
    end;

  Result := True;
end;


function TrySocketReady(S: TSocket;
                        Writing: Boolean;
                        TimeoutMs: Integer;
                        out Ready: Boolean;
                        out ErrorText: string): Boolean;
var
  Fds: TFDSet;
  Timeout: TTimeVal;
  Code: Integer;

begin

  Ready := False;

  ErrorText := '';

  Fds.fd_count := 1;

  Fds.fd_array[0] := S;

  if (TimeoutMs < 0) then
    TimeoutMs := 0;

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

  Result := Code <> SOCKET_ERROR;

  if not Result then
    ErrorText := SocketError('Socket wait failed',
                             WSAGetLastError)
  else
    Ready := Code > 0;
end;


function OpenReceiverSocket(const Host: string;
                            Port: Word;
                            TimeoutMs: Integer;
                            out ConnectedSocket: TSocket;
                            out ErrorText: string): Boolean;
var
  S: TSocket;
  Addr: TSockAddrIn;
  Peer: TSockAddrIn;
  Mode: u_long;
  Code: Integer;
  Error: Integer;
  Len: Integer;
  HostAnsi: AnsiString;
  Writable: TFDSet;
  Failed: TFDSet;
  Timeout: TTimeVal;

begin

  Result := False;

  ConnectedSocket := INVALID_SOCKET;

  ErrorText := '';

  if StartupError <> 0 then
    begin

      ErrorText := SocketError('Windows sockets unavailable',
                               StartupError);

      Exit;
    end;

  if not IPv4Valid(Host) or (Port = 0) or (TimeoutMs <= 0) then
    begin

      ErrorText := 'Invalid receiver address, port or timeout.';

      Exit;
    end;

  S := socket(AF_INET,
              SOCK_STREAM,
              IPPROTO_TCP);

  if S = INVALID_SOCKET then
    begin

      ErrorText := SocketError('Cannot create receiver socket',
                               WSAGetLastError);

      Exit;
    end;

  try

    Mode := 1;

    if ioctlsocket(S,
                   FIONBIO,
                   Mode) = SOCKET_ERROR then
      begin

        ErrorText := SocketError('Cannot configure receiver socket',
                                 WSAGetLastError);

        Exit;
      end;

    FillChar(Addr,
             SizeOf(Addr),
             0);

    HostAnsi := AnsiString(Host);

    Addr.sin_family := AF_INET;

    Addr.sin_port := htons(Port);

    Addr.sin_addr.S_addr := inet_addr(PAnsiChar(HostAnsi));

    Code := connect(S,
                    Addr,
                    SizeOf(Addr));

    if Code = SOCKET_ERROR then
      begin

        Error := WSAGetLastError;

        if (Error <> WSAEWOULDBLOCK) then
          begin

            ErrorText := SocketError('Receiver connection failed',
                                     Error);

            Exit;
          end;

        FillChar(Writable,
                 SizeOf(Writable),
                 0);

        Writable.fd_count := 1;

        Writable.fd_array[0] := S;

        Failed := Writable;

        Timeout.tv_sec := TimeoutMs div 1000;

        Timeout.tv_usec := (TimeoutMs mod 1000) * 1000;

        Code := select(0,
                       nil,
                       @Writable,
                       @Failed,
                       @Timeout);

        if Code = 0 then
          begin

            ErrorText := 'Receiver connection timed out.';

            Exit;
          end;

        if (Code = SOCKET_ERROR) then
          begin

            ErrorText := SocketError('Receiver connection wait failed',
                                     WSAGetLastError);

            Exit;
          end;

        Error := 0;

        Len := SizeOf(Error);

        if getsockopt(S,
                      SOL_SOCKET,
                      SO_ERROR,
                      PAnsiChar(@Error),
                      Len) = SOCKET_ERROR then
          Error := WSAGetLastError;

        if Error <> 0 then
          begin

            ErrorText := SocketError('Receiver connection failed',
                                     Error);

            Exit;
          end;

        if (Writable.fd_count = 0) or (Failed.fd_count <> 0) then
          begin

            ErrorText := 'Receiver connection was not established.';

            Exit;
          end;
      end;

    Mode := 0;

    if ioctlsocket(S,
                   FIONBIO,
                   Mode) = SOCKET_ERROR then
      begin

        ErrorText := SocketError('Cannot configure receiver connection',
                                 WSAGetLastError);

        Exit;
      end;

    Len := SizeOf(Peer);

    if getpeername(S,
                   Peer,
                   Len) = SOCKET_ERROR then
      begin

        ErrorText := SocketError('Receiver is not connected',
                                 WSAGetLastError);

        Exit;
      end;

    if (setsockopt(S,
                   SOL_SOCKET,
                   SO_SNDTIMEO,
                   PAnsiChar(@TimeoutMs),
                   SizeOf(TimeoutMs)) = SOCKET_ERROR) then
      begin

        ErrorText := SocketError('Cannot set receiver timeout',
                                 WSAGetLastError);

        Exit;
      end;

    ConnectedSocket := S;

    S := INVALID_SOCKET;

    Result := True;
  finally

    if (S <> INVALID_SOCKET) then
      closesocket(S);
  end;
end;


constructor THEOSConnection.CreateSocket(ASocket: TSocket);

begin

  inherited Create;

  FSocket := ASocket;
end;


constructor THEOSConnection.Create(const Host: string;
                                   Port: Word;
                                   TimeoutMs: Integer);
var
  ErrorText: string;

begin

  inherited Create();

  FSocket := INVALID_SOCKET;

  if not OpenReceiverSocket(Host,
                            Port,
                            TimeoutMs,
                            FSocket,
                            ErrorText) then
    raise EDenonSocket.CreateFmt('%s:%d: %s',
                                 [Host, Port, ErrorText]);
end;


class function THEOSConnection.TryConnect(const Host: string;
                                          Port: Word;
                                          TimeoutMs: Integer;
                                          out Connection: THEOSConnection;
                                          out ErrorText: string): Boolean;
var
  S: TSocket;

begin

  Connection := nil;

  Result := OpenReceiverSocket(Host,
                               Port,
                               TimeoutMs,
                               S,
                               ErrorText);

  if Result then
    Connection := THEOSConnection.CreateSocket(S)
  else
    ErrorText := Format('%s:%d: %s',
                        [Host, Port, ErrorText]);
end;


destructor THEOSConnection.Destroy;

begin

  if (FSocket <> INVALID_SOCKET) then
    closesocket(FSocket);

  inherited;
end;


function TrySendBytes(S: TSocket;
                      Data: Pointer;
                      Count: Integer;
                      out ErrorText: string): Boolean;
var
  Sent: Integer;
  P: PByte;

begin

  Result := False;

  ErrorText := '';

  if (Count < 0) or ((Count > 0) and (Data = nil)) then
    begin

      ErrorText := 'Invalid send buffer.';

      Exit;
    end;

  P := Data;

  while Count > 0 do
    begin

      Sent := WinApi.WinSock.send(S,
                                  P^,
                                  Count,
                                  0);

      if Sent = SOCKET_ERROR then
        begin

          ErrorText := SocketError('Send failed',
                                   WSAGetLastError);

          Exit;
        end;

      if Sent = 0 then
        begin

          ErrorText := 'Connection closed during send.';

          Exit;
        end;

      Inc(P,
          Sent);

      Dec(Count,
          Sent);
    end;

  Result := True;
end;


function THEOSConnection.TrySend(const Text: AnsiString;
                                 out ErrorText: string): Boolean;

begin

  Result := TrySendBytes(FSocket,
                         PAnsiChar(Text),
                         Length(Text),
                         ErrorText);
end;


function THEOSConnection.TryReadLine(Delimiter: AnsiChar;
                                     TimeoutMs: Integer;
                                     out Line: string;
                                     out ErrorText: string): Boolean;
var
  Buffer: array[0..4095] of AnsiChar;
  Chunk: UTF8String;
  Timer: TStopwatch;
  N: Integer;
  P: Integer;
  Remaining: Integer;
  Ready: Boolean;

begin

  Result := False;

  Line := '';

  ErrorText := '';

  Timer := TStopwatch.StartNew;

  while True do
    begin

      P := Pos(UTF8String(Delimiter),
               FReadBuffer);

      if (P > 65537) or ((P = 0) and (Length(FReadBuffer) > 65536)) then
        begin

          ErrorText := 'Receiver reply too long.';

          Exit;
        end;

      if P > 0 then
        begin

          Line := string(Copy(FReadBuffer,
                              1,
                              P - 1));

          Delete(FReadBuffer,
                 1,
                 P);

          Exit(True);
        end;

      Remaining := TimeoutMs - Integer(Timer.ElapsedMilliseconds);
      // A normal poll timeout preserves partial TCP input for the next call.

      if Remaining <= 0 then
        Exit(True);

      if Remaining > 50 then
        Remaining := 50;

      if not TrySocketReady(FSocket,
                            False,
                            Remaining,
                            Ready,
                            ErrorText) then
        Exit;

      if not Ready then
        Continue;

      N := recv(FSocket,
                Buffer,
                SizeOf(Buffer),
                0);

      if N = SOCKET_ERROR then
        begin

          ErrorText := SocketError('Receiver read failed',
                                   WSAGetLastError);

          Exit;
        end;

      if N = 0 then
        begin

          if FReadBuffer <> '' then
            ErrorText := 'Receiver closed connection before completing reply.'
          else
            ErrorText := 'Receiver closed connection.';

          Exit;
        end;

      SetString(Chunk,
                PAnsiChar(@Buffer[0]),
                N);

      FReadBuffer := FReadBuffer + Chunk;
    end;
end;


function TryReadHeader(S: TSocket;
                       out Header: string;
                       out ErrorText: string): Boolean;
var
  Ch: AnsiChar;
  Data: AnsiString;
  Timer: TStopwatch;
  N: Integer;
  Ready: Boolean;

begin

  Result := False;

  Header := '';

  ErrorText := '';

  Data := '';

  Timer := TStopwatch.StartNew;

  while Timer.ElapsedMilliseconds < 3000 do
    begin

      if not TrySocketReady(S,
                            False,
                            100,
                            Ready,
                            ErrorText) then
        Exit;

      if not Ready then
        Continue;

      N := recv(S,
                Ch,
                1,
                0);

      if N = SOCKET_ERROR then
        begin

          ErrorText := SocketError('HTTP header read failed',
                                   WSAGetLastError);

          Exit;
        end;

      if N = 0 then
        begin

          ErrorText := 'HTTP client closed.';

          Exit;
        end;

      Data := Data + Ch;

      if Pos(AnsiString(#13#10#13#10),
             Data) > 0 then
        begin

          Header := string(Data);

          Exit(True);
        end;

      if Length(Data) > 16384 then
        begin

          ErrorText := 'HTTP header too long.';

          Exit;
        end;
    end;

  ErrorText := 'HTTP header timeout.';
end;


function ProbeReceiver(const Host: string;
                       Port: Word;
                       TimeoutMs: Integer;
                       out ErrorText: string): Boolean;
var
  Connection: THEOSConnection;

begin

  Result := THEOSConnection.TryConnect(Host,
                                       Port,
                                       TimeoutMs,
                                       Connection,
                                       ErrorText);

  Connection.Free;
end;


function TryLocalAddressFor(const Receiver: string;
                            out Address: string;
                            out ErrorText: string): Boolean;
var
  S: TSocket;
  Addr: TSockAddrIn;
  Local: TSockAddrIn;
  Len: Integer;
  Host: AnsiString;

begin

  Result := False;

  Address := '';

  ErrorText := '';

  if not IPv4Valid(Receiver) then
    begin

      ErrorText := 'Invalid receiver IPv4 address.';

      Exit;
    end;

  S := socket(AF_INET,
              SOCK_DGRAM,
              IPPROTO_UDP);

  if S = INVALID_SOCKET then
    begin

      ErrorText := SocketError('Cannot create route socket',
                               WSAGetLastError);

      Exit;
    end;

  try

    FillChar(Addr,
             SizeOf(Addr),
             0);

    Host := AnsiString(Receiver);

    Addr.sin_family := AF_INET;

    Addr.sin_port := htons(1255);

    Addr.sin_addr.S_addr := inet_addr(PAnsiChar(Host));

    if connect(S,
               Addr,
               SizeOf(Addr)) = SOCKET_ERROR then
      begin

        ErrorText := SocketError('Cannot find receiver route',
                                 WSAGetLastError);

        Exit;
      end;

    Len := SizeOf(Local);

    if getsockname(S,
                   Local,
                   Len) = SOCKET_ERROR then
      begin

        ErrorText := SocketError('Cannot find local address',
                                 WSAGetLastError);

        Exit;
      end;

    Address := string(AnsiString(inet_ntoa(Local.sin_addr)));

    Result := IPv4Valid(Address);

    if not Result then
      ErrorText := 'No valid local IPv4 address for receiver route.';
  finally

    closesocket(S);
  end;
end;

// Legacy wrappers remain available for source compatibility. Expected live

// failures are handled through the result-returning functions above.


procedure SocketCheck(Code: Integer;
                      const Operation: string);

begin

  if Code = SOCKET_ERROR then
    raise EDenonSocket.Create(SocketError(Operation,
                                          WSAGetLastError));
end;


function SocketReady(S: TSocket;
                     Writing: Boolean;
                     TimeoutMs: Integer): Boolean;
var
  ErrorText: string;

begin

  if not TrySocketReady(S,
                        Writing,
                        TimeoutMs,
                        Result,
                        ErrorText) then
    Result := False;
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


procedure SendBytes(S: TSocket;
                    Data: Pointer;
                    Count: Integer);
var
  ErrorText: string;

begin

  if not TrySendBytes(S,
                      Data,
                      Count,
                      ErrorText) then
    raise EDenonSocket.Create(ErrorText);
end;


procedure SendText(S: TSocket;
                   const Text: AnsiString);

begin

  if Text <> '' then
    SendBytes(S,
              PAnsiChar(Text),
              Length(Text));
end;


procedure THEOSConnection.Send(const Text: AnsiString);
var
  ErrorText: string;

begin

  if not TrySend(Text,
                 ErrorText) then
    raise EDenonSocket.Create(ErrorText);
end;


function THEOSConnection.ReadLine(Delimiter: AnsiChar;
                                  TimeoutMs: Integer): string;
var
  ErrorText: string;

begin

  if not TryReadLine(Delimiter,
                     TimeoutMs,
                     Result,
                     ErrorText) then
    raise EDenonSocket.Create(ErrorText);
end;


function ReadHeader(S: TSocket): string;
var
  ErrorText: string;

begin

  if not TryReadHeader(S,
                       Result,
                       ErrorText) then
    raise EDenonSocket.Create(ErrorText);
end;


function LocalAddressFor(const Receiver: string): string;
var
  ErrorText: string;

begin

  if not TryLocalAddressFor(Receiver,
                            Result,
                            ErrorText) then
    raise EDenonSocket.Create(ErrorText);
end;


initialization

  // Leave initialization failures available as normal connection results.
  StartupError := WSAStartup($0202,
                            WsaData);

finalization

  if StartupError = 0 then
    WSACleanup;

end.
