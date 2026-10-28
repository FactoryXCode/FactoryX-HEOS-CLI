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
// Description: Heos main.
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
// Uses the WASAPI initialization / packet pattern from MfPack's
// Samples/MfCaptureVideoFromGPU II/WasapiLoopbackCapture.pas.
// MfPack: FactoryX, Tony Kalf and contributors, MPL 2.0.
// This standalone worker keeps COM and Media Foundation on one thread and
// requests a stereo PCM format for the RDJ-derived AAC encoder.
unit Heos;

interface

uses

  {System}
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.SyncObjs,
  {Application}
  HEOSSockets;

type
  THeosProgress = record
    PositionMs: Int64;
    DurationMs: Int64;
    Sequence: Cardinal;
  end;

  THEOSProgressMonitor = class(TThread)
  private
    FHost: string;
    FPort: Word;
    FLock: TCriticalSection;
    FProgress: THeosProgress;
    procedure Listen(Client: THEOSConnection);

  protected
    procedure Execute(); override;

  public

    constructor Create(const Host: string;
                       Port: Word = 1255);
    destructor Destroy(); override;

    function Snapshot(): THEOSProgress;
  end;

  THEOSAction = (haPlayUrl,
                 haPause,
                 haResume,
                 haStop,
                 haGetState,
                 haSeek);

  THEOSRequest = class(TThread)
  private
    FHost: string;
    FUrl: string;
    FError: string;
    FSummary: string;
    FAction: THeosAction;
    FPort: Word;
    FPlayState: string;
    FSeekPositionMs: Int64;

    function Exchange(Client: THEOSConnection;
                      const Command,
                      Expected: string): TJSONObject;

  protected
    procedure Execute(); override;

  public

    constructor Create(const Host: string;
                       Action: THEOSAction;
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

function MessageValue(const MessageText: string;
                      const Name: string): string;
var
  Part: string;

begin

  Result := '';

  for Part in MessageText.Split(['&']) do
    if Copy(Part,
            1,
            Length(Name) + 1) = Name + '=' then
      Exit(Copy(Part,
                Length(Name) + 2,
                MaxInt));
end;


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


constructor THEOSProgressMonitor.Create(const Host: string;
                                        Port: Word);
begin

  inherited Create(True);

  FreeOnTerminate := False;
  FHost := Host;
  FPort := Port;
  FLock := TCriticalSection.Create;
end;


destructor THEOSProgressMonitor.Destroy();
begin

  Terminate;
  WaitFor;
  FLock.Free;

  inherited;
end;


function THEOSProgressMonitor.Snapshot(): THeosProgress;
begin

  FLock.Acquire;

  try
    Result := FProgress;

  finally
    FLock.Release;
  end;
end;


procedure THEOSProgressMonitor.Listen(Client: THEOSConnection);
var
  Line: string;
  Command: string;
  MessageText: string;
  Pid: string;
  Value: TJSONValue;
  Root: TJSONObject;
  Header: TJSONObject;
  Player: TJSONObject;
  Players: TJSONArray;
  I: Integer;
  PositionMs: Int64;
  DurationMs: Int64;
  Timer: TStopwatch;
  Heartbeat: TStopwatch;

begin

  Pid := '';
  Client.Send('heos://player/get_players'#13#10);
  Timer := TStopwatch.StartNew();
  Heartbeat := TStopwatch.StartNew();

  while not Terminated do
    begin
      if (Pid = '') and (Timer.ElapsedMilliseconds > 6000) then
        raise Exception.Create('HEOS progress discovery timed out');

      Line := Trim(Client.ReadLine(#10,
                                   250));

      if (Heartbeat.ElapsedMilliseconds > 20000) then
        begin
          Client.Send('heos://system/heart_beat'#13#10);
          Heartbeat := TStopwatch.StartNew();
        end;

      if (Line = '') then
        Continue;

      Value := TJSONObject.ParseJSONValue(Line);

      try
        if not (Value is TJSONObject) then
          Continue;

        Root := TJSONObject(Value);

        if not (Root.GetValue('heos') is TJSONObject) then
          Continue;

        Header := TJSONObject(Root.GetValue('heos'));
        Command := Trim(JsonText(Header,
                                 'command'));

        if (Command = 'player/get_players') then
          begin
            if not (Root.GetValue('payload') is TJSONArray) then
              Continue;

            Players := TJSONArray(Root.GetValue('payload'));

            for I := 0 to Players.Count - 1 do
              if (Players.Items[I] is TJSONObject) then
                begin
                  Player := TJSONObject(Players.Items[I]);
                  if (JsonText(Player,
                               'ip') = FHost) then
                    Pid := JsonText(Player,
                                    'pid');
                end;

            if (Pid = '') and (Players.Count = 1) and (Players.Items[0] is TJSONObject) then
              Pid := JsonText(TJSONObject(Players.Items[0]),
                              'pid');

            if (Pid <> '') then
              Client.Send('heos://system/register_for_change_events?enable=on'#13#10);
          end
        else
          if (Command = 'event/player_now_playing_progress') then
            begin

              MessageText := JsonText(Header,
                                      'message');
              if (Pid = '') or (MessageValue(MessageText,
                                             'pid') <> Pid) then
                Continue;

            if not TryStrToInt64(MessageValue(MessageText,
                                              'cur_pos'),
                                 PositionMs) or not
               TryStrToInt64(MessageValue(MessageText,
                                          'duration'),
               DurationMs) or
               (PositionMs < 0) or
               (DurationMs < 0) then
              Continue;

            FLock.Acquire;

            try
              FProgress.PositionMs := PositionMs;
              FProgress.DurationMs := DurationMs;
              Inc(FProgress.Sequence);

            finally
              FLock.Release;
            end;
          end;

      finally
        Value.Free;
      end;
    end;
end;


procedure THEOSProgressMonitor.Execute();

var
  Client: THEOSConnection;
  I: Integer;

begin

  while not Terminated do
    begin
      Client := nil;

      try
        try
          Client := THEOSConnection.Create(FHost,
                                           FPort);
          Listen(Client);
        except
          // Keep the UI clock usable while the event connection reconnects.
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


function THeosRequest.Exchange(Client: THEOSConnection;
                               const Command: string;
                               const Expected: string): TJSONObject;
var
  Line: string;
  Value: TJSONValue;
  Header: TJSONObject;
  Timer: TStopwatch;

begin

  Client.Send(UTF8Encode('heos://' + Command + #13#10));
  Timer := TStopwatch.StartNew();

  while (not Terminated) and (Timer.ElapsedMilliseconds < 6000) do
  begin
    Line := Trim(Client.ReadLine(#10, 500));

    if (Line = '') then
      Continue;

    Value := TJSONObject.ParseJSONValue(Line);
    try
      if not (Value is TJSONObject) then
        Continue;

      Header := TJSONObject(TJSONObject(Value).GetValue('heos'));

      if (JsonText(Header,
                   'command') <> Expected) then
        Continue;

      if (JsonText(Header,
                   'result') <> 'success') then
        raise Exception.Create('HEOS rejected request: ' + JsonText(Header, 'message'));

      Result := TJSONObject(Value);
      Value := nil;
      Exit;

    finally
      Value.Free;
    end;
  end;

  raise Exception.Create('HEOS response timed out');
end;


procedure THeosRequest.Execute();
var
  Client: THEOSConnection;
  Reply: TJSONObject;
  Players: TJSONArray;
  Player: TJSONObject;
  I: Integer;
  Pid: string;
  State: string;
  Command: string;

begin

  Client := nil;

  try
    try
      if (FAction = haSeek) then
        begin
          SeekReceiverPosition(FHost,
                                  FSeekPositionMs);
          FSummary := 'Receiver accepted seek position.';
          Exit;
        end;

      Client := THEOSConnection.Create(FHost,
                                        FPort);

      Reply := Exchange(Client,
                        'player/get_players',
                        'player/get_players');

      try
        Players := TJSONArray(Reply.GetValue('payload'));

        if (Players = nil) then
          raise Exception.Create('No HEOS players returned');

        Pid := '';

        for I := 0 to Players.Count - 1 do
          begin
            Player := TJSONObject(Players.Items[I]);

            if (JsonText(Player,
                         'ip') = FHost) then
              Pid := JsonText(Player, 'pid');
          end;

        if (Pid = '') and (Players.Count = 1) then
          Pid := JsonText(TJSONObject(Players.Items[0]),
                                      'pid');

        if (Pid = '') then
          raise Exception.Create('Could not identify this receiver in HEOS');

      finally
        Reply.Free;
      end;

      if Terminated then
        Exit;

      if (FAction = haPlayUrl) then
        begin
          Command := 'browse/play_stream?pid=' + Pid + '&url=' + FUrl;
          Reply := Exchange(Client, Command, 'browse/play_stream');
          Reply.Free;
          FSummary := 'HEOS accepted the stream URL. Playback may take a few seconds.';
        end
      else
        if (FAction = haGetState) then
          begin
            Reply := Exchange(Client,
                              'player/get_play_state?pid=' + Pid,
                              'player/get_play_state');
            try
              Command := JsonText(TJSONObject(Reply.GetValue('heos')),
                                  'message');

              for State in Command.Split(['&']) do
                if Copy(State,
                        1,
                        6) = 'state=' then
                  FPlayState := Copy(State,
                                     7,
                                     MaxInt);
              FSummary := 'Playback state: ' + FPlayState;

            finally
              Reply.Free;
            end;
          end
        else
          begin
            case FAction of
              haPause: State := 'pause';
              haResume: State := 'play';
            else
              State := 'stop';
          end;

        Reply := Exchange(Client,
                          'player/set_play_state?pid=' + Pid + '&state=' + State,
                          'player/set_play_state');
        Reply.Free;
        FSummary := 'HEOS accepted playback state: ' + State;
      end;

    except on E: Exception do
      FError := E.Message;
    end;

  finally
    Client.Free;
  end;
end;

end.
