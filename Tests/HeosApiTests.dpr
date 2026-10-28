// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: FactoryX HEOS CLI
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HeosApiTests.dpr
// Kind: Pascal Unit
// Release date: 28-10-2026
// Language: ENU
//
// Revision Version: 1.0.0.1
// Description: HEOS CLI localhost protocol regression tests.
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
program HeosApiTests;
{$APPTYPE CONSOLE}

uses

  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Diagnostics,
  System.SyncObjs,
  WinApi.Windows,
  WinApi.WinSock,
  Heos.Cli in '..\Source\Heos.Cli.pas',
  Heos.Commands in '..\Source\Heos.Commands.pas',
  Heos.Sockets in '..\Source\Heos.Sockets.pas';

procedure Require(Value: Boolean;
                    const Text: string);
begin

  if not Value then
    raise Exception.Create(Text);
end;


type

  TMockHeos = class(TThread)
  private
    FSocket: TSocket;
    function ReadCommand(Client: TSocket): string;
    procedure Session(Client: TSocket);

  protected
    procedure Execute(); override;

  public
    RegisterCount: Integer;
    StateCount: Integer;
    MuteCount: Integer;
    DropState: Boolean;
    DelayMute: Boolean;
    constructor Create();
    destructor Destroy(); override;
  end;

  TEvents = class
  public
    Count: Integer;
    ThreadId: Cardinal;
    procedure Event(Sender: TObject;
                       Message: THeosMessage);
  end;


procedure TEvents.Event(Sender: TObject;
                           Message: THeosMessage);
begin

  Inc(Count);
  ThreadId := GetCurrentThreadId;
end;


constructor TMockHeos.Create();
var
  Address: TSockAddrIn;
  Reuse: Integer;

begin

  inherited Create(True);
  FSocket := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  Reuse := 1;
  setsockopt(FSocket, SOL_SOCKET, SO_REUSEADDR, PAnsiChar(@Reuse), SizeOf(Reuse));
  FillChar(Address, SizeOf(Address), 0);
  Address.sin_family := AF_INET;
  Address.sin_port := htons(12557);
  Address.sin_addr.S_addr := inet_addr('127.0.0.1');
  SocketCheck(bind(FSocket, Address, SizeOf(Address)), 'Bind HEOS mock');
  SocketCheck(listen(FSocket, 8), 'Listen HEOS mock');
end;


destructor TMockHeos.Destroy();
begin

  Terminate;
  WaitFor;
  closesocket(FSocket);
  inherited;
end;


function TMockHeos.ReadCommand(Client: TSocket): string;
var
  Item: AnsiChar;

begin

  Result := '';
  while not Terminated do
    begin
      if not SocketReady(Client, False, 50) then
        Continue;
      if (recv(Client, Item, 1, 0) <> 1) then
        Exit('');
      if (Item = #10) then
        Exit(Trim(Result));
      Result := Result + Char(Item);
    end;
end;


procedure TMockHeos.Session(Client: TSocket);
var
  Wire: string;
  Path: string;
  Reply: UTF8String;
  P: Integer;
  I: Integer;
  N: Integer;

  procedure SendReply(const Command: string;
                        const Message: string = '');
  begin

    SendText(Client, UTF8Encode('{"heos":{"command":"' + Command +
      '","result":"success","message":"' + Message + '"}}'#13#10));
  end;

begin

  while not Terminated do
    begin
      Wire := ReadCommand(Client);
      if (Wire = '') then
        Exit;
      Path := Copy(Wire, 8, MaxInt);
      P := Pos('?', Path);
      if (P > 0) then
        Path := Copy(Path, 1, P - 1);
      if (Path = 'player/get_players') then
        begin
          SendReply(Path, 'command under process');
          SendText(Client, '{"heos":{"command":"event/player_state_changed","message":"pid=-12&state=play"}}'#13#10);
          Reply := UTF8Encode('{'#13#10'  "heos": {"command":"player/get_players","result":"success"},'#13#10 +
                              '  "payload": [{"pid":-12,"name":"Caf' + Char($E9) + ' {room}"}]'#13#10'}'#13#10);
          I := 1;
          while (I <= Length(Reply)) do
            begin
              N := 3;
              if (I + N > Length(Reply)) then
                N := Length(Reply) - I + 1;
              SendBytes(Client, @Reply[I], N);
              Inc(I, N);
            end;
        end
      else if (Path = 'player/get_player_info') then
        begin
          Reply := UTF8Encode('{"heos":{"command":"player/get_player_info","result":"success"},' +
                                '"payload":{"name":"' + StringOfChar('x', 100000) + '"}}'#13#10);
          SendBytes(Client, PAnsiChar(Reply), Length(Reply));
        end
      else if (Path = 'player/get_volume') then
        SendText(Client, '{"heos":{"command":"player/get_volume","result":"fail","message":"eid=9&text=Out%20of%20range&syserrno=-1232"}}'#13#10)
      else if (Path = 'browse/get_music_sources') then
        begin
          Reply := '';
          for I := 1 to 5000 do
            Reply := Reply + '{"heos":{"command":"event/player_now_playing_progress","message":"pid=-12&cur_pos=1&duration=2"}}'#13#10;
          SendBytes(Client, PAnsiChar(Reply), Length(Reply));
          SendReply(Path);
        end
      else if (Path = 'player/get_play_state') then
        begin
          Inc(StateCount);
          if DropState then
            begin
              DropState := False;
              Exit;
            end;
          SendReply(Path, 'pid=-12&state=play');
        end
      else if (Path = 'player/set_mute') then
        begin
          Inc(MuteCount);
          if DelayMute then
            begin
              DelayMute := False;
              Sleep(400);
            end;
          if (Pos('state=on', Wire) > 0) then
            SendReply(Path, 'pid=-12&state=on')
          else
            SendReply(Path, 'pid=-12&state=off');
        end
      else if (Path = 'system/register_for_change_events') then
        begin
          Inc(RegisterCount);
          SendReply(Path, 'enable=on');
          SendText(Client, '{"heos":{"command":"event/player_volume_changed","message":"pid=-12&level=30&mute=off"}}'#13#10);
        end
      else
        SendReply(Path);
    end;
end;


procedure TMockHeos.Execute();
var
  Client: TSocket;

begin

  while not Terminated do
    begin
      if not SocketReady(FSocket, False, 50) then
        Continue;
      Client := accept(FSocket, nil, nil);
      try
        try
          Session(Client);
        except
          // Clients intentionally disconnect during timeout and cancellation tests.
        end;
      finally
        closesocket(Client);
      end;
    end;
end;


function WaitReply(Client: THeosClient;
                      Id: UInt64): THeosMessage;
var
  Timer: TStopwatch;
  Message: THeosMessage;

begin

  Timer := TStopwatch.StartNew;
  repeat
    while Client.TakeMessage(Message) do
      begin
        if (Message.RequestId = Id) and (Message.Kind in [hmReply, hmError]) then
          Exit(Message);
        Message.Free;
      end;
    Sleep(5);
    Require(Timer.ElapsedMilliseconds < 8000, 'Timed out waiting for request ' + UIntToStr(Id));
  until False;
end;


procedure CheckWire(const Command: THeosCommand;
                       const Expected: string);
begin

  Require(Command.WireText() = 'heos://' + Expected + #13#10,
            'Wrong wire command: ' + Command.WireText());
end;


var
  Mock: TMockHeos;
  Client: THeosClient;
  Message: THeosMessage;
  Command: THeosCommand;
  CopyCommand: THeosCommand;
  Events: TEvents;
  Timer: TStopwatch;
  BurstId: UInt64;

begin

  try
    CheckWire(THeosCommands.SignIn('u&=+%', 'p'#13#10'&='),
                'system/sign_in?un=u%26%3D+%25&pw=p%0D%0A%26%3D');
    CheckWire(THeosCommands.PlayUrl(-12, 'http://pc:8890/a.mp3?x=1&y=50%'),
                'browse/play_stream?pid=-12&url=http://pc:8890/a.mp3?x%3D1%26y%3D50%25');
    CheckWire(THeosCommands.SetGroup([-12, 23]), 'group/set_group?pid=-12,23');
    CheckWire(THeosCommands.MoveQueueItem(-12, [2, 4], 1),
                'player/move_queue_item?pid=-12&sqid=2,4&dqid=1');
    CheckWire(THeosCommands.Browse(1024, 'folder&file', 0, 49),
                'browse/browse?sid=1024&cid=folder%26file&range=0,49');
    CheckWire(THeosCommands.AddTrackToQueue(-12, 1024, 'folder', 'song', haReplaceAndPlay),
                'browse/add_to_queue?pid=-12&sid=1024&cid=folder&mid=song&aid=4');
    Command := THeosCommands.GetPlayerInfo(-12);
    CopyCommand := Command;
    CopyCommand.Add('SEQUENCE', '9');
    Require(Pos('SEQUENCE', Command.WireText()) = 0, 'Record copies share mutable parameters');
    Require(HeosDecode(HeosEncode('Caf' + Char($E9) + ' + &=%')) = 'Caf' + Char($E9) + ' + &=%', 'UTF-8 round trip failed');
    Message := THeosMessage.Parse('{"heos":{"command":"event/user_changed","message":"signed_in&un=a%26b%253D"}}');
    try
      Require(Message.EventKind = heUserChanged, 'User event not recognized');
      Require(Message.Parameter('un') = 'a&b%3D', 'Message decoding did not preserve single encoding layer');
    finally
      Message.Free;
    end;
    Writeln('PASS HEOS wire encoding, identifiers, paging, add modes, record copies and events');

    Mock := TMockHeos.Create;
    Client := nil;
    Events := TEvents.Create;
    try
      Mock.Start;
      Client := THeosClient.Create('127.0.0.1', 12557, 500);
      Client.TimeoutMs := 1500;
      Message := WaitReply(Client, Client.Enqueue(THeosCommands.GetPlayers()));
      try
        Require(Message.Success, 'GetPlayers failed');
        Require(Message.Payload is TJSONArray, 'Player payload missing');
        Require(TJSONObject(TJSONArray(Message.Payload).Items[0]).GetValue('name').Value =
                  'Caf' + Char($E9) + ' {room}', 'Fragmented UTF-8 or pretty JSON corrupted');
      finally
        Message.Free;
      end;
      Writeln('PASS partial TCP reads, interleaved events, preliminary responses and pretty JSON');

      Message := WaitReply(Client, Client.Enqueue(THeosCommands.GetPlayerInfo(-12)));
      try
        Require(Message.Success and (Length(TJSONObject(Message.Payload).GetValue('name').Value) = 100000),
                  'Large payload was truncated');
      finally
        Message.Free;
      end;
      Message := WaitReply(Client, Client.Enqueue(THeosCommands.GetPlayerVolume(-12)));
      try
        Require(not Message.Success and (Message.ErrorId = 9) and
                  (Message.ErrorText = 'Out of range') and
                  (Message.IntegerParameter('syserrno') = -1232), 'HEOS error fields lost');
      finally
        Message.Free;
      end;
      Writeln('PASS payloads above 64 KB and HEOS error/system error reporting');

      BurstId := Client.Enqueue(THeosCommands.GetMusicSources());
      Timer := TStopwatch.StartNew;
      while (Client.DroppedNotifications = 0) do
        begin
          Sleep(5);
          Require(Timer.ElapsedMilliseconds < 5000, 'Notification overflow not bounded');
        end;
      Message := WaitReply(Client, BurstId);
      try
        Require(Message.Success, 'Overflow lost command completion');
      finally
        Message.Free;
      end;
      Writeln('PASS bounded event backlog preserves command replies');

      Client.OnEvent := Events.Event;
      Message := WaitReply(Client, Client.Enqueue(THeosCommands.RegisterForChangeEvents(True)));
      Message.Free;
      Timer := TStopwatch.StartNew;
      repeat
        Client.Dispatch();
        Sleep(5);
        Require(Timer.ElapsedMilliseconds < 2000, 'Event callback missing');
      until Events.Count > 0;
      Require(Events.ThreadId = GetCurrentThreadId, 'Event callback ran on socket thread');
      Writeln('PASS callbacks dispatched on calling thread');

      Mock.DelayMute := True;
      Client.TimeoutMs := 100;
      Message := WaitReply(Client, Client.Enqueue(THeosCommands.SetPlayerMute(-12, True)));
      try
        Require((Message.Kind = hmError) and Message.DeliveryUnknown, 'Timeout must mark delivery uncertain');
      finally
        Message.Free;
      end;
      Client.TimeoutMs := 1500;
      Message := WaitReply(Client, Client.Enqueue(THeosCommands.SetPlayerMute(-12, False)));
      try
        Require(Message.Success and (Message.Parameter('state') = 'off'), 'Late reply completed a newer request');
      finally
        Message.Free;
      end;
      Require(Mock.MuteCount = 2, 'Timed-out command was replayed');
      Writeln('PASS timeout disconnect, no write replay and late-reply isolation');

      Mock.DropState := True;
      Message := WaitReply(Client, Client.Enqueue(THeosCommands.GetPlayState(-12)));
      try
        Require(Message.Kind = hmError, 'Connection loss not reported');
      finally
        Message.Free;
      end;
      Timer := TStopwatch.StartNew;
      repeat
        Sleep(10);
        Require(Timer.ElapsedMilliseconds < 5000, 'Subscription not restored after reconnect');
      until Client.Connected and (Mock.RegisterCount >= 3);
      Require(Mock.StateCount = 1, 'Lost request was replayed');
      Writeln('PASS reconnect and event subscription restoration');

      Client.Disconnect();
      Timer := TStopwatch.StartNew;
      while Client.Connected do
        begin
          Sleep(5);
          Require(Timer.ElapsedMilliseconds < 2000, 'Disconnect stalled');
        end;
      Message := WaitReply(Client, Client.Enqueue(THeosCommands.HeartBeat()));
      Message.Free;
      Mock.DelayMute := True;
      Client.Enqueue(THeosCommands.SetPlayerMute(-12, True));
      Timer := TStopwatch.StartNew;
      while (Mock.MuteCount < 3) do
        begin
          Sleep(5);
          Require(Timer.ElapsedMilliseconds < 2000, 'Mute request did not start');
        end;
      Timer := TStopwatch.StartNew;
      FreeAndNil(Client);
      Require(Timer.ElapsedMilliseconds < 2000, 'Shutdown blocked on a long request');
      Writeln('PASS explicit disconnect and responsive shutdown');
      Writeln('ALL TESTS PASSED');
    finally
      Client.Free;
      Mock.Free;
      Events.Free;
    end;
  except
    on E: Exception do
      begin
        Writeln(E.ClassName + ': ' + E.Message);
        Halt(1);
      end;
  end;
end.
