// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: FactoryX HEOS CLI
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: AvrApiTests.dpr
// Kind: Pascal Unit
// Release date: 28-10-2026
// Language: ENU
//
// Revision Version: 1.0.0.1
// Description: AVR API validation and receiver simulator tests.
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
program AvrApiTests;
{$APPTYPE CONSOLE}
uses
  System.SysUtils, System.Classes, System.Diagnostics, Winapi.Windows,
  Avr.Commands in '..\Source\Avr.Commands.pas',
  Avr.Client in '..\Source\Avr.Client.pas',
  Heos.Sockets in '..\..\Source\Heos.Sockets.pas';
type
  TCallbackSink = class
  public
    ThreadId: Cardinal;
    Count: Integer;
    procedure Reply(Sender: TObject; Message: TAvrMessage);
  end;
procedure TCallbackSink.Reply(Sender: TObject; Message: TAvrMessage);
begin
  ThreadId := GetCurrentThreadId;
  Inc(Count);
end;
procedure Require(Value: Boolean; const Text: string);
begin
  if not Value then raise Exception.Create(Text);
end;
function WaitReply(Client: TAvrClient; Id: UInt64): TAvrMessage;
var Message: TAvrMessage; Clock: TStopwatch;
begin
  Clock := TStopwatch.StartNew;
  repeat
    Require(Clock.ElapsedMilliseconds < 7000, 'Test reply timed out');
    if Client.TakeMessage(Message) then
    begin
      if Message.RequestId = Id then Exit(Message);
      Message.Free;
    end
    else Sleep(5);
  until False;
end;
procedure Confirm(Client: TAvrClient; const Command: TAvrCommand; const Expected: string);
var Message: TAvrMessage;
begin
  Message := WaitReply(Client, Client.Enqueue(Command));
  try
    Require(Message.Kind = amReply, Message.ErrorText);
    Require(Message.Value.RawText = Expected, 'Wrong response: ' + Message.Value.RawText);
  finally Message.Free; end;
end;
var
  Value: TAvrValue;
  Command: TAvrCommand;
  Batch: TArray<TAvrCommand>;
  Client: TAvrClient;
  Message: TAvrMessage;
  Clock: TStopwatch;
  Failed: Boolean;
  Port: Integer;
  Id: UInt64;
  Sink: TCallbackSink;
  MessageCount: Integer;
  Completed: Boolean;
begin
  try
    Require(TAvrCommands.SetVolume(47.5).Text = 'MV475', 'Half-step volume encoding');
    Require(TAvrCommands.SetVolume(80).Text = 'MV80', 'Whole volume encoding');
    Require(TAvrCommands.SetVolume(30, True).Text = 'Z230', 'Zone2 volume encoding');
    Require(TAvrCommands.SetPower(False).Text = 'PWSTANDBY', 'Standby encoding');
    Require(TAvrCommands.SetBass(-6).Text = 'PSBAS 44', 'Bass encoding');
    Batch := TAvrCommands.SetBalance(2.5, 1, -1);
    Require((Batch[0].Text = 'CVFL 485') and (Batch[1].Text = 'CVFR 49'), 'Baseline balance');
    Value := ParseAvrValue('MV475'); Require((Value.Kind = avVolume) and (Value.Number = 47.5), 'Volume parse');
    Value := ParseAvrValue('MVMAX 80'); Require((Value.Kind = avVolumeLimit) and (Value.Number = 80), 'Max confused with MV');
    Value := ParseAvrValue('CVFL 485'); Require((Value.Kind = avFrontLeft) and (Value.Number = -1.5), 'Channel trim parse');
    Value := ParseAvrValue('PSBAS 44'); Require((Value.Kind = avBass) and (Value.Number = -6), 'Tone parse');
    Value := ParseAvrValue('Z2ON'); Require((Value.Kind = avZone2Power) and Value.Enabled, 'Zone2 power parse');
    Value := ParseAvrValue('Z2475'); Require((Value.Kind = avZone2Volume) and (Value.Number = 47.5), 'Zone2 volume parse');
    Value := ParseAvrValue('Z2MUON'); Require(Value.Kind = avZone2Mute, 'Zone2 mute parse');
    Value := ParseAvrValue('Z2NET'); Require(Value.Kind = avZone2Input, 'Zone2 input parse');
    Value := ParseAvrValue('MVabc'); Require(Value.Kind = avUnknown, 'Malformed numeric reply accepted');
    Failed := False; try Command := TAvrCommands.SetVolume(30.25); except on E: Exception do Failed := True; end;
    Require(Failed, 'Quarter-step accepted');
    Failed := False; try Command := TAvrCommand.Raw('PWON'#13'Z2ON', 'PW'); except on E: Exception do Failed := True; end;
    Require(Failed, 'CR command injection accepted');
    Failed := False; try Command := TAvrCommands.SetBass(7); except on E: Exception do Failed := True; end;
    Require(Failed, 'Invalid tone accepted');
    Writeln('PASS AVR command encoding, validation, numeric values, zones, balance baselines and tone');
    if (ParamCount = 0) then Exit;
    Port := StrToInt(ParamStr(1));
    Client := TAvrClient.Create('127.0.0.1', Port);
    try
      Confirm(Client, TAvrCommands.GetPower(), 'PWON');
      Confirm(Client, TAvrCommands.GetVolume(), 'MV475');
      Confirm(Client, TAvrCommands.SetVolume(81.5), 'MV80');
      Confirm(Client, TAvrCommands.GetZone2Power(), 'Z2OFF');
      Confirm(Client, TAvrCommands.GetVolume(True), 'Z225');
      Confirm(Client, TAvrCommands.GetFrontRight(), 'CVFR 50');
      Confirm(Client, TAvrCommands.SetToneControl(True), 'PSTONE CTRL ON');
      Confirm(Client, TAvrCommand.Raw('TESTRAW?', 'TESTRAW'), 'TESTRAW42');
      Writeln('PASS fragmented CR replies, unsolicited lines, capped MV/MVMAX, Zone2 matching, raw extension');
      Sink := TCallbackSink.Create;
      try
        Client.OnReply := Sink.Reply;
        Client.Enqueue(TAvrCommands.GetPower());
        Clock := TStopwatch.StartNew;
        repeat
          Client.Dispatch;
          Sleep(5);
          Require(Clock.ElapsedMilliseconds < 2000, 'Callback missing');
        until Sink.Count > 0;
        Require(Sink.ThreadId = GetCurrentThreadId, 'Callback ran on worker thread');
        Client.OnReply := nil;
      finally Sink.Free; end;
      Batch := [TAvrCommand.Raw('TESTATOMIC?', 'TESTATOMIC'), TAvrCommands.GetPower()];
      Batch[1].Text := '';
      Failed := False;
      try Client.EnqueueBatch(Batch); except on E: Exception do Failed := True; end;
      Require(Failed, 'Invalid batch accepted');
      Id := Client.Enqueue(TAvrCommand.Raw('TESTFLOOD?', 'TESTFLOOD'));
      Clock := TStopwatch.StartNew;
      while Client.DroppedNotifications = 0 do
      begin
        Sleep(10);
        Require(Clock.ElapsedMilliseconds < 2500, 'Event backlog did not reach its bound');
      end;
      Sleep(200);
      Failed := False;
      try Client.Enqueue(TAvrCommands.GetPower()); except on E: Exception do Failed := True; end;
      Require(Failed, 'Full notification backlog did not reject new work');
      MessageCount := 0;
      Completed := False;
      while Client.TakeMessage(Message) do
      begin
        Inc(MessageCount);
        if (Message.RequestId = Id) and (Message.Kind = amReply) then Completed := True;
        Message.Free;
      end;
      Require((MessageCount <= 4097) and Completed, 'Bounded backlog lost request completion');
      Writeln('PASS caller-thread callbacks, atomic batch validation and bounded notifications');
      Client.TimeoutMs := 100;
      Message := WaitReply(Client, Client.Enqueue(TAvrCommand.Raw('TESTTIMEOUT?', 'TESTTIMEOUT')));
      try Require((Message.Kind = amError) and Message.DeliveryUnknown, 'Timeout delivery uncertainty missing'); finally Message.Free; end;
      Client.TimeoutMs := 2500;
      Confirm(Client, TAvrCommands.GetMute(), 'MUOFF');
      Message := WaitReply(Client, Client.Enqueue(TAvrCommand.Raw('TESTREJECT?', 'TESTREJECT')));
      try Require(Message.Kind = amError, 'Receiver rejection not reported'); finally Message.Free; end;
      Confirm(Client, TAvrCommands.GetInput(), 'SINET');
      Writeln('PASS timeout isolation, reconnect without replay, receiver rejection');
      Id := Client.Enqueue(TAvrCommand.Raw('TESTWAIT?', 'TESTWAIT'));
      Sleep(120);
      Client.Disconnect;
      Message := WaitReply(Client, Id);
      try Require((Message.Kind = amError) and Message.DeliveryUnknown, 'Active cancellation missing'); finally Message.Free; end;
      Confirm(Client, TAvrCommands.GetPower(), 'PWON');
      Client.Enqueue(TAvrCommand.Raw('TESTWAIT?', 'TESTWAIT'));
      Sleep(100);
      Clock := TStopwatch.StartNew;
      FreeAndNil(Client);
      Require(Clock.ElapsedMilliseconds < 1000, 'Worker shutdown stalled');
      Writeln('PASS disconnect cancellation and bounded worker shutdown');
    finally Client.Free; end;
    Writeln('ALL AVR TESTS PASSED');
  except on E: Exception do begin Writeln(E.ClassName + ': ' + E.Message); Halt(1); end; end;
end.