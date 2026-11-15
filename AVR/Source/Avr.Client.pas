// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: FactoryX HEOS CLI
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: Avr.Client.pas
// Kind: Pascal Unit
// Release date: 28-10-2026
// Language: ENU
//
// Revision Version: 1.0.0.1
// Description: Asynchronous native AVR control client.
//
// Company: FactoryX
// Intiator(s): Tony (maXcomX), Carmen (carmenh).
// Contributor(s): Tony Kalf (maXcomX), Carmen (carmenh).
//
//------------------------------------------------------------------------------
// CHANGE LOG
// Date       Person              Reason
// ---------- ------------------- ----------------------------------------------
// 15/11/2026 All                 Carmel release  SDK 10.0.28000.2705 (Windows 11)
//------------------------------------------------------------------------------
//
// Remarks: Requires Windows 10 or higher.
//
// Related objects: RDJ Pro
// Related projects: MfPackX410
// Known Issues: -
//
// Compiler version: 23 up to 35
// SDK version: 10.0.28000.2705
//
// Todo: -
//
// =============================================================================
// Source: FactoryX.Code
//         HARMAN International (Denon.com)
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
unit Avr.Client;

interface

uses

  {System}
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,
  {AVR}
  Avr.Commands,
  {HEOS}
  Heos.Sockets;

type

  TAvrMessageKind = (amReply,
                     amEvent,
                     amError,
                     amConnection);

  TAvrMessage = class
  public

    Kind: TAvrMessageKind;
    RequestId: UInt64;
    CommandText: string;
    Value: TAvrValue;
    ErrorText: string;
    DeliveryUnknown: Boolean;
    Connected: Boolean;
  end;

  TAvrMessageEvent = procedure(Sender: TObject;
                               AMessage: TAvrMessage) of object;

  TAvrPending = record
    Id: UInt64;
    Command: TAvrCommand;
  end;

  TAvrClient = class;

  TAvrWorker = class(TThread)
  private

    FOwner: TAvrClient;
    FConnection: THeosConnection;
    FGeneration: Cardinal;
    FNextSendAt: UInt64;
    FMaximumVolume: Double;
    FError: string;

    procedure CloseConnection();
    function OpenConnection(): Boolean;
    function Cancelled(): Boolean;
    
    function ReadValue(ATimeout: Integer; out AValue: TAvrValue): Boolean;
    
    function Matches(const ACommand: TAvrCommand;
                     const AValue: TAvrValue): Boolean;
    
    procedure Process(const APending: TAvrPending);

  protected

    procedure Execute(); override;

  public

    constructor Create(AOwner: TAvrClient);
    destructor Destroy(); override;
  end;

  TAvrClient = class
  private

    FHost: string;
    FPort: Word;
    FConnectTimeoutMs: Integer;
    FTimeoutMs: Integer;
    FLock: TCriticalSection;
    FWake: TEvent;
    FWorker: TAvrWorker;
    FPending: TQueue<TAvrPending>;
    FMessages: TQueue<TAvrMessage>;
    FNextId: UInt64;
    FGeneration: Cardinal;
    FConnected: Boolean;
    FDropped: UInt64;
    FOnReply: TAvrMessageEvent;
    FOnEvent: TAvrMessageEvent;
    FOnError: TAvrMessageEvent;
    FOnConnection: TAvrMessageEvent;

    procedure Post(AMessage: TAvrMessage);
    procedure SetConnected(AValue: Boolean);
    function Pop(out APending: TAvrPending): Boolean;
    function Generation(): Cardinal;
    function GetConnected(): Boolean;
    function GetDropped(): UInt64;
    procedure SetTimeoutMs(AValue: Integer);

  public

    constructor Create(const AHost: string;
                       APort: Word = 23;
                       AConnectTimeoutMs: Integer = 2500);
                       
    destructor Destroy(); override;

    function Connect(): UInt64;
    procedure Disconnect();
    function Enqueue(const ACommand: TAvrCommand): UInt64;
    function EnqueueBatch(const ACommands: array of TAvrCommand): TArray<UInt64>;
    function TakeMessage(out AMessage: TAvrMessage): Boolean;
    procedure Dispatch(AMaximum: Integer = 100); reintroduce;

    property Host: string read FHost;
    property Port: Word read FPort;
    property TimeoutMs: Integer read FTimeoutMs write SetTimeoutMs;
    property Connected: Boolean read GetConnected;
    property DroppedNotifications: UInt64 read GetDropped;
    property OnReply: TAvrMessageEvent read FOnReply write FOnReply;
    property OnEvent: TAvrMessageEvent read FOnEvent write FOnEvent;
    property OnError: TAvrMessageEvent read FOnError write FOnError;
    property OnConnection: TAvrMessageEvent read FOnConnection write FOnConnection;
  end;


implementation

uses

  Winapi.Windows,
  System.Math,
  System.StrUtils;

function GetTickCount64: UInt64; stdcall; external 'kernel32.dll';


constructor TAvrClient.Create(const AHost: string;
                              APort: Word;
                              AConnectTimeoutMs: Integer);
begin

  inherited Create;
  if not IPv4Valid(AHost) or (APort = 0) then
    raise EArgumentException.Create('A valid AVR IPv4 address and port are required.');
  
  if (AConnectTimeoutMs < 100) or (AConnectTimeoutMs > 60000) then
    raise EArgumentOutOfRangeException.Create('AVR connect timeout must be 100 to 60000 ms.');

  FHost := AHost;
  FPort := APort;
  FConnectTimeoutMs := AConnectTimeoutMs;
  FTimeoutMs := 2500;
  FLock := TCriticalSection.Create;
  
  FWake := TEvent.Create(nil,
                         False,
                         False,
                         '');
                         
  FPending := TQueue<TAvrPending>.Create;
  FMessages := TQueue<TAvrMessage>.Create;
  FWorker := TAvrWorker.Create(Self);
  FWorker.Start;
end;


destructor TAvrClient.Destroy();
var
  Message: TAvrMessage;

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

  FMessages.Free;
  FPending.Free;
  FWake.Free;
  FLock.Free;
  inherited;
end;


procedure TAvrClient.SetTimeoutMs(AValue: Integer);
begin

  if (AValue < 100) or (AValue > 60000) then
    raise EArgumentOutOfRangeException.Create('AVR reply timeout must be 100 to 60000 ms.');

  FTimeoutMs := AValue;
end;


function TAvrClient.EnqueueBatch(const ACommands: array of TAvrCommand): TArray<UInt64>;
var
  i: Integer;
  Pending: TAvrPending;
  Message: TAvrMessage;

begin

  for i := 0 to High(ACommands) do
    ACommands[i].Validate();

  SetLength(Result, Length(ACommands));
  FLock.Acquire;

  try

    if (FPending.Count + Length(ACommands) > 256) or (FMessages.Count >= 4096) then
      begin
        Message := TAvrMessage.Create;
        Message.Kind := amError;
        Message.ErrorText := 'AVR queue is full; command was not sent.';
        Post(Message);
        SetLength(Result, 0);
        Exit;
      end;

    for i := 0 to High(ACommands) do
      begin

        Inc(FNextId);
        Pending.Id := FNextId;
        Pending.Command := ACommands[i];
        Result[i] := Pending.Id;
        FPending.Enqueue(Pending);
      end;
  finally

    FLock.Release;
  end;

  FWake.SetEvent;
end;


function TAvrClient.Enqueue(const ACommand: TAvrCommand): UInt64;
var
  Ids: TArray<UInt64>;

begin

  Ids := EnqueueBatch([ACommand]);
  if Length(Ids) = 0 then Result := 0 else Result := Ids[0];
end;


function TAvrClient.Connect(): UInt64;
begin

  Result := Enqueue(TAvrCommands.GetPower());
end;


procedure TAvrClient.Disconnect();
var
  Pending: TAvrPending;
  Message: TAvrMessage;

begin

  FLock.Acquire;

  try

    Inc(FGeneration);
    while (FPending.Count > 0) do
      begin

        Pending := FPending.Dequeue;
        Message := TAvrMessage.Create;
        Message.Kind := amError;
        Message.RequestId := Pending.Id;
        Message.CommandText := Pending.Command.Text;
        Message.ErrorText := 'AVR request cancelled before transmission.';
        FMessages.Enqueue(Message);
      end;
  finally

    FLock.Release;
  end;

  FWake.SetEvent;
end;


function TAvrClient.Generation(): Cardinal;
begin

  FLock.Acquire;
  
  try
    Result := FGeneration;
    
  finally
    FLock.Release;
  end;
end;


function TAvrClient.GetConnected(): Boolean;
begin

  FLock.Acquire;
  
  try
    Result := FConnected;
    
  finally
    FLock.Release;
  end;
end;


function TAvrClient.GetDropped(): UInt64;
begin

  FLock.Acquire;
  
  try
    Result := FDropped;
    
  finally
    FLock.Release;
  end;
end;


procedure TAvrClient.SetConnected(AValue: Boolean);
var
  Changed: Boolean;
  Message: TAvrMessage;

begin

  FLock.Acquire;
  
  try
    Changed := (FConnected <> AValue);
    FConnected := AValue;
    
  finally
    FLock.Release;
  end;

  if Changed then
    begin

      Message := TAvrMessage.Create;
      Message.Kind := amConnection;
      Message.Connected := AValue;
      Post(Message);
    end;
end;


procedure TAvrClient.Post(AMessage: TAvrMessage);
begin

  FLock.Acquire;
  try

    if (FMessages.Count >= 4096) and ((AMessage.Kind in [amEvent, amConnection]) or
       ((AMessage.Kind = amError) and (AMessage.RequestId = 0))) then
      begin

        Inc(FDropped);
        AMessage.Free;
      end
    else
      FMessages.Enqueue(AMessage);
      
  finally
    FLock.Release;
  end;
end;


function TAvrClient.Pop(out APending: TAvrPending): Boolean;
begin

  FLock.Acquire;
  try

    Result := (FPending.Count > 0);
    if Result then
      APending := FPending.Dequeue;
      
  finally
    FLock.Release;
  end;
end;


function TAvrClient.TakeMessage(out AMessage: TAvrMessage): Boolean;
begin

  AMessage := nil;
  FLock.Acquire;
  try

    Result := (FMessages.Count > 0);
    if Result then
      AMessage := FMessages.Dequeue;
      
  finally
    FLock.Release;
  end;
end;


procedure TAvrClient.Dispatch(AMaximum: Integer);
var
  Message: TAvrMessage;
  i: Integer;

begin

  for i := 1 to AMaximum do
    begin

      if not TakeMessage(Message) then
        Exit;

      try

        case Message.Kind of
          amReply: if Assigned(FOnReply) then
                     FOnReply(Self,
                              Message);
          amEvent: if Assigned(FOnEvent) then
                     FOnEvent(Self,
                              Message);
          amError: if Assigned(FOnError) then
                     FOnError(Self,
                              Message);
          amConnection: if Assigned(FOnConnection) then
                          FOnConnection(Self,
                                        Message);
        end;

      finally

        Message.Free;
      end;
    end;
end;


constructor TAvrWorker.Create(AOwner: TAvrClient);
begin

  inherited Create(True);
  
  FOwner := AOwner;
  FreeOnTerminate := False;
  FMaximumVolume := 98;
end;


destructor TAvrWorker.Destroy();
begin

  FConnection.Free;
  
  inherited;
end;


function TAvrWorker.Cancelled(): Boolean;
begin

  Result := Terminated or (FGeneration <> FOwner.Generation());
end;


procedure TAvrWorker.CloseConnection();
begin

  FreeAndNil(FConnection);
  FMaximumVolume := 98;
  FOwner.SetConnected(False);
end;


function TAvrWorker.OpenConnection(): Boolean;
begin

  if not Assigned(FConnection) then
    begin

      if not THeosConnection.TryConnect(FOwner.FHost, FOwner.FPort,
                                        FOwner.FConnectTimeoutMs, FConnection, FError) then Exit(False);
      FOwner.SetConnected(True);
    end;
  Result := True;
end;


function TAvrWorker.ReadValue(ATimeout: Integer;
                              out AValue: TAvrValue): Boolean;
var
  Line: string;
  Message: TAvrMessage;

begin

  Result := False;
  AValue := Default(TAvrValue);
  if not FConnection.TryReadLine(#13, ATimeout, Line, FError) then Exit;
  Line := Trim(Line);

  Result := (Line <> '');
  AValue := Default(TAvrValue);
  
  if not Result then
    Exit;

  if (Line = '?') or (Line = 'ERROR') then
    begin FError := 'Receiver rejected the AVR command.'; Exit(False); end;

  AValue := ParseAvrValue(Line);
  
  if (AValue.Kind = avVolumeLimit) then
    FMaximumVolume := AValue.Number;

  Message := TAvrMessage.Create();
  Message.Kind := amEvent;
  Message.Value := AValue;
  FOwner.Post(Message);
end;


function TAvrWorker.Matches(const ACommand: TAvrCommand;
                            const AValue: TAvrValue): Boolean;
var
  Expected: Double;
  Value: string;

begin

  if (AValue.RawText = '') then
    Exit(False);

  if (ACommand.ReplyKind = avUnknown) then
    begin

      Result := StartsStr(ACommand.ExpectedPrefix,
                          AValue.RawText);
      Value := Copy(AValue.RawText,
                    Length(ACommand.ExpectedPrefix) + 1,
                    MaxInt);
      
      if (ACommand.ExpectedValue <> '') then
        Result := Result and (Value = ACommand.ExpectedValue);
      
      Exit;
    end;

  Result := (AValue.Kind = ACommand.ReplyKind);
  
  if not Result or (ACommand.ExpectedValue = '') then
    Exit;

  if (ACommand.ReplyKind = avVolume) and AValue.HasNumber and
     TryAvrLevel(ACommand.ExpectedValue,
                 Expected) then
    Result := SameValue(AValue.Number,
                        Min(Expected,
                        FMaximumVolume),
                        0.001)
  else
    Result := (AValue.Value = ACommand.ExpectedValue);
end;


procedure TAvrWorker.Process(const APending: TAvrPending);
var
  Message: TAvrMessage;
  Sent, Success: Boolean;

  function ExecuteCommand(): Boolean;
  var
    Value, Candidate: TAvrValue;
    Deadline: UInt64;
  begin
    Result := False;
    if not OpenConnection() then Exit;
    Deadline := GetTickCount64 + 80;
    while not Cancelled() and (GetTickCount64 < Deadline) do
      if not ReadValue(10, Value) then Break;
    if FError <> '' then Exit;
    while not Cancelled() and (GetTickCount64 < FNextSendAt) do Sleep(10);
    if Cancelled() then
      begin FError := 'AVR request cancelled before transmission.'; Exit; end;
    Sent := True;
    if not FConnection.TrySend(AnsiString(APending.Command.Text) + #13, FError) then Exit;
    FNextSendAt := GetTickCount64 + UInt64(APending.Command.DelayMs);
    Deadline := GetTickCount64 + UInt64(FOwner.FTimeoutMs);
    Candidate := Default(TAvrValue);
    repeat
      if Cancelled() then
        begin FError := 'AVR request cancelled.'; Exit; end;
      if ReadValue(50, Value) then
        begin
          if (Value.Kind = APending.Command.ReplyKind) or (APending.Command.ReplyKind = avUnknown) then
            Candidate := Value;
          if Matches(APending.Command, Candidate) then
            begin Message.Kind := amReply; Message.Value := Candidate; Exit(True); end;
        end;
      if FError <> '' then Exit;
    until GetTickCount64 >= Deadline;
    FError := 'Receiver did not confirm the AVR command before timeout.';
  end;

begin
  Sent := False;
  Success := False;
  FError := '';
  Message := TAvrMessage.Create;
  Message.RequestId := APending.Id;
  Message.CommandText := APending.Command.Text;
  try
    try
      Success := ExecuteCommand();
    except
      on E: Exception do FError := E.Message;
    end;
    if not Success then
      begin
        Message.Kind := amError;
        Message.ErrorText := FError;
        Message.DeliveryUnknown := Sent;
        CloseConnection();
      end;
    FOwner.Post(Message);
    Message := nil;
  finally
    Message.Free;
  end;
end;


procedure TAvrWorker.Execute();
var
  Pending: TAvrPending;
  Value: TAvrValue;
  Message: TAvrMessage;

begin

  try

    while not Terminated do
      begin

        if (FGeneration <> FOwner.Generation()) then
          begin

            CloseConnection();
            FGeneration := FOwner.Generation();
          end;

        if FOwner.Pop(Pending) then
          Process(Pending)
        else
          if Assigned(FConnection) then
            begin

              try

                FError := '';
                ReadValue(50, Value);
                if FError <> '' then
                  begin
                    Message := TAvrMessage.Create;
                    Message.Kind := amError;
                    Message.ErrorText := FError;
                    CloseConnection();
                    FOwner.Post(Message);
                  end;
              except

                on E: Exception do
                  begin

                    Message := TAvrMessage.Create;
                    Message.Kind := amError;
                    Message.ErrorText := E.Message;
                    CloseConnection();
                    FOwner.Post(Message);
                  end;
              end;
            end
          else
            FOwner.FWake.WaitFor(50);
      end;
  finally

    CloseConnection();
  end;
end;

end.