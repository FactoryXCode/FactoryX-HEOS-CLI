// FactoryX
//
// Copyright: (c) FactoryX. All rights reserved.
//
// Project: HEOS Remote.
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module:  Heos.pas
// Kind: Pascal / Delphi unit
// Release date: 13-08-2025
// Language: ENU
//
// Revision Version: 4.0.0
// Description: Remote playback and progress using the FactoryX HEOS CLI API.
//
//
// Organisation: FactoryX
// Initiator(s): Tony (maXcomX), Peter (OzShips)
// Contributor(s): Carmen (carmenh), Tony Kalf (maXcomX)
//
//------------------------------------------------------------------------------
// CHANGE LOG
// Date       Person              Reason
// ---------- ------------------- ----------------------------------------------
// 24/08/2026 All                 Moby release  SDK 10.0.28000.2705  (Windows 11)
//------------------------------------------------------------------------------
//
// Remarks: -
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
//==============================================================================
// Source: -
//
// Copyright (c) FactoryX. All rights reserved.
//==============================================================================
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
unit Heos;

interface

uses

  {System}
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.SyncObjs,
  {FactoryX API}
  Heos.Cli,
  Heos.Commands;

type

  THeosProgress = record
    PositionMs: Int64;
    DurationMs: Int64;
    Sequence: Cardinal;
  end;

  THeosApiThread = class(TThread)
  protected

    function Exchange(Client: THeosClient;
                         const Command: THeosCommand): THeosMessage;
    function FindPlayer(Client: THeosClient;
                           const Host: string): Int64;
  end;

  THeosProgressMonitor = class(THeosApiThread)
  private

    FHost: string;
    FPort: Word;
    FLock: TCriticalSection;
    FProgress: THeosProgress;
    procedure Listen(Client: THeosClient);

  protected

    procedure Execute(); override;

  public

    constructor Create(const Host: string;
                           Port: Word = 1255);
    destructor Destroy(); override;
    function Snapshot(): THeosProgress;
  end;

  THeosAction = (haPlayUrl,
                  haPause,
                  haResume,
                  haStop,
                  haGetState,
                  haSeek);

  THeosRequest = class(THeosApiThread)
  private

    FHost: string;
    FUrl: string;
    FError: string;
    FSummary: string;
    FAction: THeosAction;
    FPort: Word;
    FPlayState: string;
    FSeekPositionMs: Int64;

  protected

    procedure Execute(); override;

  public

    constructor Create(const Host: string;
                           Action: THeosAction;
                           const Url: string = '';
                           Port: Word = 1255;
                           SeekPositionMs: Int64 = 0);
    property ErrorText: string read FError;
    property Summary: string read FSummary;
    property PlayState: string read FPlayState;
  end;

implementation

uses

  {System}
  System.Diagnostics,
  {Application}
  HEOS.UPnP;

function JsonText(Obj: TJSONObject;
                     const Name: string): string;
var
  Value: TJSONValue;

begin

  Result := '';
  if (Obj = nil) then
    Exit;

  Value := Obj.GetValue(Name);
  if (Value <> nil) then
    Result := Value.Value;
end;


function THeosApiThread.Exchange(Client: THeosClient;
                                    const Command: THeosCommand): THeosMessage;
var
  Id: UInt64;
  Message: THeosMessage;
  Timer: TStopwatch;

begin

  if Terminated then
    raise EAbort.Create('HEOS request cancelled.');

  Id := Client.Enqueue(Command);
  Timer := TStopwatch.StartNew();
  while not Terminated and (Timer.ElapsedMilliseconds < 10000) do
    begin

      if not Client.TakeMessage(Message) then
        begin

          Sleep(10);
          Continue;
        end;

      try

        // Events and progress replies cannot complete a queued command.
        if (Message.RequestId <> Id) or
           not (Message.Kind in [hmReply, hmError]) then
          Continue;

        if not Message.Success then
          begin

            if Message.DeliveryUnknown then
              raise EHeosProtocol.Create(Message.ErrorText +
                                          ' Delivery is uncertain; command was not replayed.');
            raise EHeosProtocol.Create(Message.ErrorText);
          end;

        Result := Message;
        Message := nil;
        Exit;
      finally
        Message.Free;
      end;
    end;

  raise EHeosProtocol.Create('HEOS response timed out or request was cancelled.');
end;


function THeosApiThread.FindPlayer(Client: THeosClient;
                                      const Host: string): Int64;
var
  Reply: THeosMessage;
  Players: TJSONArray;
  Player: TJSONObject;
  I: Integer;

begin

  Reply := Exchange(Client, THeosCommands.GetPlayers());
  try

    if not (Reply.Payload is TJSONArray) then
      raise EHeosProtocol.Create('No HEOS players returned.');

    Players := TJSONArray(Reply.Payload);
    for I := 0 to Players.Count - 1 do
      if (Players.Items[I] is TJSONObject) then
        begin

          Player := TJSONObject(Players.Items[I]);
          if (JsonText(Player, 'ip') = Host) and
             TryStrToInt64(JsonText(Player, 'pid'), Result) then
            Exit;
        end;

    if (Players.Count = 1) and (Players.Items[0] is TJSONObject) and
       TryStrToInt64(JsonText(TJSONObject(Players.Items[0]), 'pid'), Result) then
      Exit;

    raise EHeosProtocol.Create('Could not identify this receiver in HEOS.');
  finally
    Reply.Free;
  end;
end;


constructor THeosProgressMonitor.Create(const Host: string;
                                            Port: Word);
begin

  inherited Create(True);
  FreeOnTerminate := False;
  FHost := Host;
  FPort := Port;
  FLock := TCriticalSection.Create;
end;


destructor THeosProgressMonitor.Destroy();
begin

  Terminate;
  WaitFor;
  FLock.Free;
  inherited;
end;


function THeosProgressMonitor.Snapshot(): THeosProgress;
begin

  FLock.Acquire;
  try
    Result := FProgress;
  finally
    FLock.Release;
  end;
end;


procedure THeosProgressMonitor.Listen(Client: THeosClient);
var
  Pid: Int64;
  Message: THeosMessage;
  PositionMs: Int64;
  DurationMs: Int64;

begin

  Pid := FindPlayer(Client, FHost);
  Message := Exchange(Client, THeosCommands.RegisterForChangeEvents(True));
  Message.Free;

  while not Terminated do
    begin

      if not Client.TakeMessage(Message) then
        begin

          Sleep(10);
          Continue;
        end;

      try

        if (Message.Kind = hmError) then
          raise EHeosProtocol.Create(Message.ErrorText);

        if (Message.Kind = hmEvent) and
           (Message.EventKind = hePlayersChanged) then
          begin

            Pid := FindPlayer(Client, FHost);
            Continue;
          end;

        if (Message.Kind <> hmEvent) or
           (Message.EventKind <> heNowPlayingProgress) or
           (Message.IntegerParameter('pid') <> Pid) then
          Continue;

        if not TryStrToInt64(Message.Parameter('cur_pos'), PositionMs) or
           not TryStrToInt64(Message.Parameter('duration'), DurationMs) or
           (PositionMs < 0) or (DurationMs < 0) then
          Continue;

        FLock.Acquire;
        try
          FProgress.PositionMs := PositionMs;
          FProgress.DurationMs := DurationMs;
          Inc(FProgress.Sequence);
        finally
          FLock.Release;
        end;
      finally
        Message.Free;
      end;
    end;
end;


procedure THeosProgressMonitor.Execute();
var
  Client: THeosClient;
  I: Integer;

begin

  while not Terminated do
    begin

      Client := nil;
      try
        try
          Client := THeosClient.Create(FHost, FPort);
          Client.TimeoutMs := 6000;
          Listen(Client);
        except
          // Re-resolve the player when the event connection is lost.
        end;
      finally
        Client.Free;
      end;

      for I := 1 to 20 do
        begin

          if Terminated then
            Exit;
          Sleep(100);
        end;
    end;
end;


constructor THeosRequest.Create(const Host: string;
                                    Action: THeosAction;
                                    const Url: string;
                                    Port: Word;
                                    SeekPositionMs: Int64);
begin

  inherited Create(True);
  FreeOnTerminate := False;
  FHost := Host;
  FAction := Action;
  FUrl := Url;
  FPort := Port;
  FSeekPositionMs := SeekPositionMs;
end;


procedure THeosRequest.Execute();
var
  Client: THeosClient;
  Reply: THeosMessage;
  Pid: Int64;
  State: THeosPlayState;

begin

  Client := nil;
  try
    try

      if (FAction = haSeek) then
        begin

          SeekReceiverPosition(FHost, FSeekPositionMs);
          FSummary := 'Receiver accepted seek position.';
          Exit;
        end;

      Client := THeosClient.Create(FHost, FPort);
      Client.TimeoutMs := 6000;
      Pid := FindPlayer(Client, FHost);
      if Terminated then
        Exit;

      case FAction of
        haPlayUrl:
          begin

            Reply := Exchange(Client, THeosCommands.PlayUrl(Pid, FUrl));
            Reply.Free;
            FSummary := 'HEOS accepted the stream URL. Playback may take a few seconds.';
          end;
        haGetState:
          begin

            Reply := Exchange(Client, THeosCommands.GetPlayState(Pid));
            try
              FPlayState := Reply.Parameter('state');
              FSummary := 'Playback state: ' + FPlayState;
            finally
              Reply.Free;
            end;
          end;
      else
        begin

          case FAction of
            haPause: State := hpsPause;
            haResume: State := hpsPlay;
          else
            State := hpsStop;
          end;

          Reply := Exchange(Client, THeosCommands.SetPlayState(Pid, State));
          FSummary := 'HEOS accepted playback state: ' + Reply.Parameter('state');
          Reply.Free;
        end;
      end;
    except
      on E: Exception do
        FError := E.Message;
    end;
  finally
    Client.Free;
  end;
end;

end.
