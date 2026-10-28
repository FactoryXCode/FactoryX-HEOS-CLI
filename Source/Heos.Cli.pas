// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: FactoryX HEOS CLI
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: Heos.Cli.pas
// Kind: Pascal Unit
// Release date: 28-10-2026
// Language: ENU
//
// Revision Version: 1.0.0.1
// Description: Asynchronous HEOS CLI transport and JSON responses.
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
unit Heos.Cli;

{$B-}

interface

uses

  System.Classes,
  System.SysUtils,
  System.JSON,
  System.SyncObjs,
  System.Generics.Collections,
  Heos.Sockets;

type

  EHeosProtocol = class(Exception);

  THeosMessageKind = (hmReply,
                       hmEvent,
                       hmProgress,
                       hmError,
                       hmConnection);

  THeosEventKind = (heUnknown,
                     heSourcesChanged,
                     hePlayersChanged,
                     heGroupsChanged,
                     hePlayerStateChanged,
                     heNowPlayingChanged,
                     heNowPlayingProgress,
                     hePlaybackError,
                     heQueueChanged,
                     hePlayerVolumeChanged,
                     heRepeatModeChanged,
                     heShuffleModeChanged,
                     heGroupVolumeChanged,
                     heUserChanged);

  THeosParameter = record
    Name: string;
    Value: string;
    Encoded: Boolean;
  end;

  THeosCommand = record
  private
    FPath: string;
    FParameters: TArray<THeosParameter>;

  public
    class function Create(const Path: string): THeosCommand; static;
    procedure Add(const Name: string;
                    const Value: string;
                    Encoded: Boolean = False);
    function Parameter(const Name: string): string;
    function WireText(): string;
    property Path: string read FPath;
  end;

  THeosMessage = class
  private
    FRoot: TJSONObject;
    FFields: TDictionary<string, string>;
    FCommand: string;
    FResult: string;
    FMessage: string;
    function GetPayload(): TJSONValue;
    function GetSuccess(): Boolean;
    function GetErrorId(): Integer;
    function GetErrorText(): string;
    function GetEventKind(): THeosEventKind;

  public
    Kind: THeosMessageKind;
    RequestId: UInt64;
    DeliveryUnknown: Boolean;
    LocalError: string;
    constructor Create();
    destructor Destroy(); override;
    class function Parse(const Json: string): THeosMessage; static;
    function Parameter(const Name: string;
                         const Default: string = ''): string;
    function IntegerParameter(const Name: string;
                                Default: Int64 = 0): Int64;
    property Command: string read FCommand;
    property ResultText: string read FResult;
    property MessageText: string read FMessage;
    property Root: TJSONObject read FRoot;
    property Payload: TJSONValue read GetPayload;
    property Success: Boolean read GetSuccess;
    property ErrorId: Integer read GetErrorId;
    property ErrorText: string read GetErrorText;
    property EventKind: THeosEventKind read GetEventKind;
  end;

  THeosMessageEvent = procedure(Sender: TObject;
                                 Message: THeosMessage) of object;

  THeosClient = class;

  THeosPending = record
    Id: UInt64;
    Command: THeosCommand;
  end;

  THeosWorker = class(TThread)
  private
    FOwner: THeosClient;
    FConnection: THeosConnection;
    FBuffer: UTF8String;
    FGeneration: Cardinal;
    FSubscribed: Boolean;
    FLastActivity: UInt64;
    FRetryAt: UInt64;
    FRetryDelay: Cardinal;
    procedure CloseConnection();
    procedure OpenConnection();
    function Cancelled(): Boolean;
    function ReadFrame(TimeoutMs: Integer): string;
    function ExtractFrame(): string;
    function Exchange(const Command: THeosCommand;
                        Id: UInt64): THeosMessage;

  protected
    procedure Execute(); override;

  public
    constructor Create(Owner: THeosClient);
  end;

  THeosClient = class
  private
    FHost: string;
    FPort: Word;
    FTimeoutMs: Integer;
    FConnectTimeoutMs: Integer;
    FLock: TCriticalSection;
    FWake: TEvent;
    FPending: TQueue<THeosPending>;
    FMessages: TQueue<THeosMessage>;
    FWorker: THeosWorker;
    FNextId: UInt64;
    FGeneration: Cardinal;
    FConnected: Boolean;
    FDroppedNotifications: UInt64;
    FOnReply: THeosMessageEvent;
    FOnEvent: THeosMessageEvent;
    FOnProgress: THeosMessageEvent;
    FOnError: THeosMessageEvent;
    FOnConnection: THeosMessageEvent;
    procedure Post(Message: THeosMessage);
    procedure SetConnected(Value: Boolean);
    function Pop(out Pending: THeosPending): Boolean;
    function HasPending(): Boolean;
    function GetConnected(): Boolean;
    function GetDroppedNotifications(): UInt64;
    function Generation(): Cardinal;
    procedure SetTimeoutMs(Value: Integer);

  public
    constructor Create(const Host: string;
                         Port: Word = 1255;
                         ConnectTimeoutMs: Integer = 2500);
    destructor Destroy(); override;
    function Enqueue(const Command: THeosCommand): UInt64;
    function Connect(): UInt64;
    procedure Disconnect();
    function TakeMessage(out Message: THeosMessage): Boolean;
    procedure Dispatch(Maximum: Integer = 100); reintroduce;
    property Host: string read FHost;
    property Port: Word read FPort;
    property Connected: Boolean read GetConnected;
    property DroppedNotifications: UInt64 read GetDroppedNotifications;
    property TimeoutMs: Integer read FTimeoutMs write SetTimeoutMs;
    property OnReply: THeosMessageEvent read FOnReply write FOnReply;
    property OnEvent: THeosMessageEvent read FOnEvent write FOnEvent;
    property OnProgress: THeosMessageEvent read FOnProgress write FOnProgress;
    property OnError: THeosMessageEvent read FOnError write FOnError;
    property OnConnection: THeosMessageEvent read FOnConnection write FOnConnection;
  end;

function HeosEncode(const Value: string): string;
function HeosDecode(const Value: string): string;
function HeosParameter(const Name: string;
                          const Value: string;
                          Encoded: Boolean = False): THeosParameter;

implementation

uses

  WinApi.Windows,
  WinApi.WinSock,
  System.StrUtils,
  System.Diagnostics;

const

  MaximumFrameBytes = 16 * 1024 * 1024;
  MaximumPendingCommands = 256;
  MaximumNotifications = 4096;

function GetTickCount64(): UInt64; stdcall;
  external 'kernel32.dll' name 'GetTickCount64';

function JsonText(Json: TJSONObject;
                    const Name: string): string;
var
  Value: TJSONValue;

begin

  Value := Json.GetValue(Name);
  if Assigned(Value) then
    Result := Value.Value
  else
    Result := '';
end;


function HeosEncode(const Value: string): string;
var
  Bytes: TBytes;
  Item: Byte;

begin

  Result := '';
  Bytes := TEncoding.UTF8.GetBytes(Value);
  for Item in Bytes do
    if (Item < 32) or (Item > 126) or (Item in [37, 38, 61]) then
      Result := Result + '%' + IntToHex(Item, 2)
    else
      Result := Result + Char(Item);
end;


function HeosDecode(const Value: string): string;
var
  Input: UTF8String;
  Bytes: TBytes;
  I: Integer;
  N: Integer;
  Number: Integer;

begin

  Input := UTF8Encode(Value);
  SetLength(Bytes, Length(Input));
  I := 1;
  N := 0;
  while (I <= Length(Input)) do
    begin
      if (Input[I] = '%') and (I + 2 <= Length(Input)) and
         TryStrToInt('$' + string(Copy(Input, I + 1, 2)), Number) then
        begin
          Bytes[N] := Byte(Number);
          Inc(I, 3);
        end
      else
        begin
          Bytes[N] := Byte(Input[I]);
          Inc(I);
        end;
      Inc(N);
    end;
  SetLength(Bytes, N);
  Result := TEncoding.UTF8.GetString(Bytes);
end;


function ValidName(const Value: string;
                     AllowSlash: Boolean): Boolean;
var
  Item: Char;

begin

  Result := Value <> '';
  for Item in Value do
    if not CharInSet(Item, ['a'..'z', 'A'..'Z', '0'..'9', '_']) and
       not (AllowSlash and (Item = '/')) then
      Exit(False);
end;


function HeosParameter(const Name: string;
                          const Value: string;
                          Encoded: Boolean): THeosParameter;
begin

  Result.Name := Name;
  Result.Value := Value;
  Result.Encoded := Encoded;
end;


class function THeosCommand.Create(const Path: string): THeosCommand;
begin

  if not ValidName(Path, True) or (Pos('/', Path) <= 1) or
     (Path[Length(Path)] = '/') then
    raise EArgumentException.Create('Invalid HEOS command path');
  Result.FPath := Path;
  Result.FParameters := nil;
end;


procedure THeosCommand.Add(const Name: string;
                             const Value: string;
                             Encoded: Boolean);
var
  Count: Integer;

begin

  if not ValidName(Name, False) then
    raise EArgumentException.Create('Invalid HEOS parameter name');
  if Encoded and ((Pos(#13, Value) > 0) or (Pos(#10, Value) > 0) or
                 (Pos('&', Value) > 0) or (Pos('=', Value) > 0)) then
    raise EArgumentException.Create('Encoded HEOS values contain unescaped delimiters');
  Count := Length(FParameters);
  FParameters := Copy(FParameters);
  SetLength(FParameters, Count + 1);
  FParameters[Count] := HeosParameter(Name, Value, Encoded);
end;


function THeosCommand.Parameter(const Name: string): string;
var
  Item: THeosParameter;

begin

  Result := '';
  for Item in FParameters do
    if SameText(Item.Name, Name) then
      begin
        Result := Item.Value;
        if Item.Encoded then
          Result := HeosDecode(Result);
        Exit;
      end;
end;


function THeosCommand.WireText(): string;
var
  Item: THeosParameter;
  Separator: string;

begin

  if not ValidName(FPath, True) or (Pos('/', FPath) <= 1) then
    raise EArgumentException.Create('Empty or invalid HEOS command');
  Result := 'heos://' + FPath;
  Separator := '?';
  for Item in FParameters do
    begin
      Result := Result + Separator + Item.Name + '=';
      if Item.Encoded then
        Result := Result + Item.Value
      else
        Result := Result + HeosEncode(Item.Value);
      Separator := '&';
    end;
  Result := Result + #13#10;
end;


constructor THeosMessage.Create();
begin

  inherited;
  FFields := TDictionary<string, string>.Create;
end;


destructor THeosMessage.Destroy();
begin

  FRoot.Free;
  FFields.Free;
  inherited;
end;


class function THeosMessage.Parse(const Json: string): THeosMessage;
var
  Value: TJSONValue;
  Header: TJSONObject;
  Part: string;
  P: Integer;

begin

  Result := THeosMessage.Create;
  try
    Value := TJSONObject.ParseJSONValue(Json);
    if not (Value is TJSONObject) then
      begin
        Value.Free;
        raise EHeosProtocol.Create('HEOS response is not a JSON object');
      end;
    Result.FRoot := TJSONObject(Value);
    Value := Result.FRoot.GetValue('heos');
    if not (Value is TJSONObject) then
      raise EHeosProtocol.Create('HEOS response has no valid header');
    Header := TJSONObject(Value);
    Result.FCommand := Trim(JsonText(Header, 'command'));
    Result.FResult := JsonText(Header, 'result');
    Result.FMessage := JsonText(Header, 'message');
    if (Result.FCommand = '') then
      raise EHeosProtocol.Create('HEOS response has no command');
    for Part in Result.FMessage.Split(['&']) do
      begin
        P := Pos('=', Part);
        if (P > 0) then
          Result.FFields.AddOrSetValue(HeosDecode(Copy(Part, 1, P - 1)),
                                      HeosDecode(Copy(Part, P + 1, MaxInt)));
      end;
    Result.Kind := hmReply;
    if StartsText('event/', Result.FCommand) then
      Result.Kind := hmEvent
    else if (Result.FResult <> 'success') and (Result.FResult <> 'fail') then
      raise EHeosProtocol.Create('HEOS response has no valid result')
    else if (Pos('command under process', LowerCase(Result.FMessage)) > 0) then
      Result.Kind := hmProgress;
  except
    Result.Free;
    raise;
  end;
end;


function THeosMessage.GetPayload(): TJSONValue;
begin

  Result := nil;
  if Assigned(FRoot) then
    Result := FRoot.GetValue('payload');
end;


function THeosMessage.GetSuccess(): Boolean;
begin

  Result := (LocalError = '') and ((FResult = 'success') or (Kind = hmEvent));
end;


function THeosMessage.Parameter(const Name: string;
                                 const Default: string): string;
begin

  if not FFields.TryGetValue(Name, Result) then
    Result := Default;
end;


function THeosMessage.IntegerParameter(const Name: string;
                                        Default: Int64): Int64;
begin

  if not TryStrToInt64(Parameter(Name), Result) then
    Result := Default;
end;


function THeosMessage.GetErrorId(): Integer;
begin

  Result := IntegerParameter('eid');
end;


function THeosMessage.GetErrorText(): string;
begin

  Result := LocalError;
  if (Result = '') and (FResult = 'fail') then
    Result := Parameter('text', FMessage);
end;


function THeosMessage.GetEventKind(): THeosEventKind;
const

  Names: array[THeosEventKind] of string = ('',
    'event/sources_changed',
    'event/players_changed',
    'event/groups_changed',
    'event/player_state_changed',
    'event/player_now_playing_changed',
    'event/player_now_playing_progress',
    'event/player_playback_error',
    'event/player_queue_changed',
    'event/player_volume_changed',
    'event/repeat_mode_changed',
    'event/shuffle_mode_changed',
    'event/group_volume_changed',
    'event/user_changed');

begin

  for Result := Low(THeosEventKind) to High(THeosEventKind) do
    if (FCommand = Names[Result]) then
      Exit;
  Result := heUnknown;
end;


constructor THeosClient.Create(const Host: string;
                                 Port: Word;
                                 ConnectTimeoutMs: Integer);
begin

  inherited Create;
  if not IPv4Valid(Host) or (Port = 0) then
    raise EArgumentException.Create('A valid HEOS IPv4 address and port are required');
  if (ConnectTimeoutMs < 100) or (ConnectTimeoutMs > 60000) then
    raise EArgumentOutOfRangeException.Create('Invalid HEOS connection timeout');
  FHost := Host;
  FPort := Port;
  FConnectTimeoutMs := ConnectTimeoutMs;
  FTimeoutMs := 15000;
  FLock := TCriticalSection.Create;
  FWake := TEvent.Create(nil, False, False, '');
  FPending := TQueue<THeosPending>.Create;
  FMessages := TQueue<THeosMessage>.Create;
  FWorker := THeosWorker.Create(Self);
  FWorker.Start();
end;


destructor THeosClient.Destroy();
var
  Message: THeosMessage;

begin

  if Assigned(FWorker) then
    begin
      FWorker.Terminate;
      FWake.SetEvent;
      FWorker.WaitFor;
      FWorker.Free;
    end;
  if Assigned(FMessages) then
    while (FMessages.Count > 0) do
      begin
        Message := FMessages.Dequeue;
        Message.Free;
      end;
  FPending.Free;
  FMessages.Free;
  FWake.Free;
  FLock.Free;
  inherited;
end;


procedure THeosClient.SetTimeoutMs(Value: Integer);
begin

  if (Value < 100) or (Value > 300000) then
    raise EArgumentOutOfRangeException.Create('Invalid HEOS request timeout');
  FLock.Acquire;
  try
    FTimeoutMs := Value;
  finally
    FLock.Release;
  end;
end;


function THeosClient.Enqueue(const Command: THeosCommand): UInt64;
var
  Pending: THeosPending;

begin

  Result := 0;
  Command.WireText();
  FLock.Acquire;
  try
    if (FPending.Count >= MaximumPendingCommands) or
       (FMessages.Count >= MaximumNotifications) then
      raise EHeosProtocol.Create('HEOS queue is full; dispatch or take pending messages');
    Inc(FNextId);
    Pending.Id := FNextId;
    Pending.Command := Command;
    FPending.Enqueue(Pending);
    Result := Pending.Id;
  finally
    FLock.Release;
  end;
  FWake.SetEvent;
end;


function THeosClient.Connect(): UInt64;
begin

  Result := Enqueue(THeosCommand.Create('system/heart_beat'));
end;


procedure THeosClient.Disconnect();
var
  Pending: THeosPending;
  Message: THeosMessage;

begin

  FLock.Acquire;
  try
    Inc(FGeneration);
    while (FPending.Count > 0) do
      begin
        Pending := FPending.Dequeue;
        Message := THeosMessage.Create;
        Message.Kind := hmError;
        Message.RequestId := Pending.Id;
        Message.FCommand := Pending.Command.Path;
        Message.LocalError := 'HEOS request cancelled before transmission';
        FMessages.Enqueue(Message);
      end;
  finally
    FLock.Release;
  end;
  FWake.SetEvent;
end;


function THeosClient.Generation(): Cardinal;
begin

  FLock.Acquire;
  try
    Result := FGeneration;
  finally
    FLock.Release;
  end;
end;


procedure THeosClient.Post(Message: THeosMessage);
begin

  FLock.Acquire;
  try
    if (FMessages.Count >= MaximumNotifications) and
       ((Message.RequestId = 0) or (Message.Kind in [hmEvent, hmProgress])) then
      begin
        Inc(FDroppedNotifications);
        Message.Free;
        Exit;
      end;
    FMessages.Enqueue(Message);
  finally
    FLock.Release;
  end;
end;


procedure THeosClient.SetConnected(Value: Boolean);
var
  Changed: Boolean;
  Message: THeosMessage;

begin

  FLock.Acquire;
  try
    Changed := FConnected <> Value;
    FConnected := Value;
  finally
    FLock.Release;
  end;
  if Changed then
    begin
      Message := THeosMessage.Create;
      Message.Kind := hmConnection;
      if Value then
        Message.FMessage := 'connected'
      else
        Message.FMessage := 'disconnected';
      Post(Message);
    end;
end;


function THeosClient.GetConnected(): Boolean;
begin

  FLock.Acquire;
  try
    Result := FConnected;
  finally
    FLock.Release;
  end;
end;


function THeosClient.GetDroppedNotifications(): UInt64;
begin

  FLock.Acquire;
  try
    Result := FDroppedNotifications;
  finally
    FLock.Release;
  end;
end;


function THeosClient.HasPending(): Boolean;
begin

  FLock.Acquire;
  try
    Result := FPending.Count > 0;
  finally
    FLock.Release;
  end;
end;


function THeosClient.Pop(out Pending: THeosPending): Boolean;
begin

  FLock.Acquire;
  try
    Result := FPending.Count > 0;
    if Result then
      Pending := FPending.Dequeue;
  finally
    FLock.Release;
  end;
end;


function THeosClient.TakeMessage(out Message: THeosMessage): Boolean;
begin

  Message := nil;
  FLock.Acquire;
  try
    Result := FMessages.Count > 0;
    if Result then
      Message := FMessages.Dequeue;
  finally
    FLock.Release;
  end;
end;


procedure THeosClient.Dispatch(Maximum: Integer);
var
  Message: THeosMessage;
  I: Integer;
  Handler: THeosMessageEvent;

begin

  for I := 1 to Maximum do
    begin
      if not TakeMessage(Message) then
        Exit;
      try
        Handler := nil;
        case Message.Kind of
          hmReply: Handler := FOnReply;
          hmEvent: Handler := FOnEvent;
          hmProgress: Handler := FOnProgress;
          hmError: Handler := FOnError;
          hmConnection: Handler := FOnConnection;
        end;
        if Assigned(Handler) then
          Handler(Self, Message);
      finally
        Message.Free;
      end;
    end;
end;


constructor THeosWorker.Create(Owner: THeosClient);
begin

  inherited Create(True);
  FOwner := Owner;
  FRetryDelay := 1000;
end;


procedure THeosWorker.CloseConnection();
begin

  FreeAndNil(FConnection);
  FBuffer := '';
  FOwner.SetConnected(False);
end;


function THeosWorker.Cancelled(): Boolean;
begin

  Result := Terminated or (FGeneration <> FOwner.Generation());
end;


procedure THeosWorker.OpenConnection();
var
  Command: THeosCommand;
  Reply: THeosMessage;

begin

  FConnection := THeosConnection.Create(FOwner.FHost, FOwner.FPort,
                                          FOwner.FConnectTimeoutMs);
  if Cancelled() then
    raise EHeosProtocol.Create('HEOS connection cancelled');
  FOwner.SetConnected(True);
  FLastActivity := GetTickCount64;
  if FSubscribed then
    begin
      Command := THeosCommand.Create('system/register_for_change_events');
      Command.Add('enable', 'on');
      Reply := Exchange(Command, 0);
      try
        if not Reply.Success then
          raise EHeosProtocol.Create('HEOS event subscription could not be restored');
      finally
        Reply.Free;
      end;
    end;
  FRetryDelay := 1000;
end;


function THeosWorker.ExtractFrame(): string;
var
  I: Integer;
  Depth: Integer;
  InString: Boolean;
  Escaped: Boolean;
  Item: AnsiChar;

begin

  Result := '';
  I := 1;
  while (I <= Length(FBuffer)) and (FBuffer[I] in [#9, #10, #13, ' ']) do
    Inc(I);
  if (I > 1) then
    Delete(FBuffer, 1, I - 1);
  if (FBuffer = '') then
    Exit;
  if (FBuffer[1] <> '{') then
    raise EHeosProtocol.Create('Invalid HEOS JSON frame');
  Depth := 0;
  InString := False;
  Escaped := False;
  for I := 1 to Length(FBuffer) do
    begin
      Item := FBuffer[I];
      if InString then
        begin
          if Escaped then
            Escaped := False
          else if (Item = '\') then
            Escaped := True
          else if (Item = '"') then
            InString := False;
        end
      else if (Item = '"') then
        InString := True
      else if (Item = '{') or (Item = '[') then
        Inc(Depth)
      else if (Item = '}') or (Item = ']') then
        begin
          Dec(Depth);
          if (Depth = 0) then
            begin
              if (I > MaximumFrameBytes) then
                raise EHeosProtocol.Create('HEOS JSON frame exceeds 16 MB');
              Result := UTF8ToString(Copy(FBuffer, 1, I));
              Delete(FBuffer, 1, I);
              Exit;
            end;
        end;
    end;
  if (Length(FBuffer) > MaximumFrameBytes) then
    raise EHeosProtocol.Create('HEOS JSON frame exceeds 16 MB');
end;


function THeosWorker.ReadFrame(TimeoutMs: Integer): string;
var
  Buffer: array[0..8191] of AnsiChar;
  Chunk: UTF8String;
  Count: Integer;

begin

  Result := ExtractFrame();
  if (Result <> '') or Cancelled() then
    Exit;
  if not SocketReady(FConnection.Handle, False, TimeoutMs) then
    Exit;
  Count := recv(FConnection.Handle, Buffer, SizeOf(Buffer), 0);
  SocketCheck(Count, 'HEOS read');
  if (Count = 0) then
    raise EHeosProtocol.Create('HEOS connection closed');
  SetString(Chunk, PAnsiChar(@Buffer[0]), Count);
  FBuffer := FBuffer + Chunk;
  Result := ExtractFrame();
end;


function THeosWorker.Exchange(const Command: THeosCommand;
                                Id: UInt64): THeosMessage;
var
  Timer: TStopwatch;
  Line: string;
  Message: THeosMessage;
  Timeout: Integer;

begin

  FOwner.FLock.Acquire;
  try
    Timeout := FOwner.FTimeoutMs;
  finally
    FOwner.FLock.Release;
  end;
  if Cancelled() then
    raise EHeosProtocol.Create('HEOS request cancelled before transmission');
  FConnection.Send(UTF8Encode(Command.WireText()));
  Timer := TStopwatch.StartNew;
  while not Cancelled() do
    begin
      if (Timer.ElapsedMilliseconds >= Timeout) then
        raise EHeosProtocol.Create('HEOS request timed out; command was not replayed');
      Line := ReadFrame(50);
      if (Line = '') then
        Continue;
      Message := THeosMessage.Parse(Line);
      FLastActivity := GetTickCount64;
      if (Message.Kind <> hmEvent) and SameText(Message.Command, Command.Path) then
        begin
          Message.RequestId := Id;
          if (Message.Kind <> hmProgress) then
            Exit(Message);
        end;
      FOwner.Post(Message);
    end;
  raise EHeosProtocol.Create('HEOS request cancelled');
end;


procedure THeosWorker.Execute();
var
  Pending: THeosPending;
  Message: THeosMessage;
  Line: string;
  Active: Boolean;
  Sent: Boolean;
  Command: THeosCommand;

begin

  try
    while not Terminated do
      begin
        Active := False;
        Sent := False;
        if (FGeneration <> FOwner.Generation()) then
          begin
            CloseConnection();
            FSubscribed := False;
            FGeneration := FOwner.Generation();
            FRetryAt := 0;
          end;
        try
          if not Assigned(FConnection) then
            begin
              if not FOwner.HasPending() and not FSubscribed then
                begin
                  FOwner.FWake.WaitFor(50);
                  Continue;
                end;
              if (GetTickCount64 < FRetryAt) then
                begin
                  FOwner.FWake.WaitFor(50);
                  Continue;
                end;
              OpenConnection();
            end;

          if FOwner.Pop(Pending) then
            begin
              Active := True;
              Sent := True;
              Message := Exchange(Pending.Command, Pending.Id);
              if Message.Success and (Pending.Command.Path = 'system/register_for_change_events') then
                FSubscribed := Pending.Command.Parameter('enable') = 'on';
              FOwner.Post(Message);
              Active := False;
            end
          else if (GetTickCount64 - FLastActivity >= 20000) then
            begin
              Command := THeosCommand.Create('system/heart_beat');
              Message := Exchange(Command, 0);
              Message.Free;
            end
          else
            begin
              Line := ReadFrame(50);
              if (Line <> '') then
                begin
                  Message := THeosMessage.Parse(Line);
                  FOwner.Post(Message);
                  FLastActivity := GetTickCount64;
                end;
            end;
        except
          on E: Exception do
            begin
              CloseConnection();
              if Terminated then
                Exit;
              Message := THeosMessage.Create;
              Message.Kind := hmError;
              Message.LocalError := E.Message;
              if Active then
                begin
                  Message.RequestId := Pending.Id;
                  Message.FCommand := Pending.Command.Path;
                  Message.DeliveryUnknown := Sent;
                end;
              FOwner.Post(Message);
              if not Active then
                while FOwner.Pop(Pending) do
                  begin
                    Message := THeosMessage.Create;
                    Message.Kind := hmError;
                    Message.RequestId := Pending.Id;
                    Message.FCommand := Pending.Command.Path;
                    Message.LocalError := 'HEOS connection unavailable; command was not sent';
                    FOwner.Post(Message);
                  end;
              FRetryAt := GetTickCount64 + UInt64(FRetryDelay);
              if (FRetryDelay < 30000) then
                FRetryDelay := FRetryDelay * 2;
              if (FRetryDelay > 30000) then
                FRetryDelay := 30000;
            end;
        end;
      end;
  finally
    CloseConnection();
  end;
end;

end.
