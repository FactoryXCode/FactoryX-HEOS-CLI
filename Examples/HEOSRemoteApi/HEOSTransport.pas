// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: HEOS Remote.
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HEOSTransport.pas
// Kind: Pascal Unit
// Release date: 24-01-2026
// Language: ENU
//
// Revision Version: 4.0.0
// Description: Remote receiver requests using the FactoryX AVR API.
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
unit HEOSTransport;

interface

uses

  {System}
  System.Classes,
  System.SysUtils,
  {FactoryX API}
  Avr.Client,
  Avr.Commands;

type

  TDenonRequest = class(TThread)
  private

    FHost: string;
    FPort: Integer;
    FCommands: TStringList;
    FLines: TStringList;
    FError: string;
    FStopOnVolumeReply: Boolean;
    FStopOnChannelReply: Boolean;
    FStopOnZoneReply: Boolean;
    FStopOnToneReply: Boolean;

    procedure RunCommand(Client: TAvrClient;
                             const Command: TAvrCommand);

  protected

    procedure Execute(); override;

  public

    constructor Create(const Host: string;
                           const Commands: array of string;
                           Port: Integer = 23;
                           StopOnVolumeReply: Boolean = False;
                           StopOnChannelReply: Boolean = False;
                           StopOnZoneReply: Boolean = False;
                           StopOnToneReply: Boolean = False);
    destructor Destroy(); override;

    property Lines: TStringList read FLines;
    property ErrorText: string read FError;
  end;

implementation

uses

  {System}
  System.Diagnostics,
  System.StrUtils;

function ApiCommand(const Text: string): TAvrCommand;
var
  Level: Double;
  Value: Integer;

begin

  if (Text = 'PW?') then
    Exit(TAvrCommands.GetPower());
  if (Text = 'PWON') or (Text = 'PWSTANDBY') then
    Exit(TAvrCommands.SetPower(Text = 'PWON'));
  if (Text = 'ZM?') then
    Exit(TAvrCommands.GetMainZonePower());
  if (Text = 'ZMON') or (Text = 'ZMOFF') then
    Exit(TAvrCommands.SetMainZonePower(Text = 'ZMON'));
  if (Text = 'Z2?') then
    Exit(TAvrCommands.GetZone2Power());
  if (Text = 'Z2ON') or (Text = 'Z2OFF') then
    Exit(TAvrCommands.SetZone2Power(Text = 'Z2ON'));
  if (Text = 'MV?') then
    Exit(TAvrCommands.GetVolume());
  if StartsStr('MV', Text) and TryAvrLevel(Copy(Text, 3, MaxInt), Level) then
    Exit(TAvrCommands.SetVolume(Level));
  if (Text = 'MU?') then
    Exit(TAvrCommands.GetMute());
  if (Text = 'MUON') or (Text = 'MUOFF') then
    Exit(TAvrCommands.SetMute(Text = 'MUON'));
  if (Text = 'SI?') then
    Exit(TAvrCommands.GetInput());
  if StartsStr('SI', Text) then
    Exit(TAvrCommands.SetInput(Copy(Text, 3, MaxInt)));
  if (Text = 'CV?') then
    Exit(TAvrCommand.Raw(Text, 'CVEND'));
  if StartsStr('CVFL ', Text) and TryAvrLevel(Copy(Text, 6, MaxInt), Level) then
    Exit(TAvrCommands.SetFrontLeft(Level - 50));
  if StartsStr('CVFR ', Text) and TryAvrLevel(Copy(Text, 6, MaxInt), Level) then
    Exit(TAvrCommands.SetFrontRight(Level - 50));
  if (Text = 'PSTONE CTRL ?') then
    Exit(TAvrCommands.GetToneControl());
  if (Text = 'PSTONE CTRL ON') or (Text = 'PSTONE CTRL OFF') then
    Exit(TAvrCommands.SetToneControl(Text = 'PSTONE CTRL ON'));
  if (Text = 'PSBAS ?') then
    Exit(TAvrCommands.GetBass());
  if StartsStr('PSBAS ', Text) and TryStrToInt(Copy(Text, 7, MaxInt), Value) then
    Exit(TAvrCommands.SetBass(Value - 50));
  if (Text = 'PSTRE ?') then
    Exit(TAvrCommands.GetTreble());
  if StartsStr('PSTRE ', Text) and TryStrToInt(Copy(Text, 7, MaxInt), Value) then
    Exit(TAvrCommands.SetTreble(Value - 50));
  if (Text = 'MS?') then
    Exit(TAvrCommands.GetSurroundMode());
  if (Text = 'PSDYNEQ ?') then
    Exit(TAvrCommands.GetDynamicEq());

  raise EArgumentException.Create('No AVR API mapping for command: ' + Text);
end;


constructor TDenonRequest.Create(const Host: string;
                                     const Commands: array of string;
                                     Port: Integer;
                                     StopOnVolumeReply: Boolean;
                                     StopOnChannelReply: Boolean;
                                     StopOnZoneReply: Boolean;
                                     StopOnToneReply: Boolean);
var
  I: Integer;

begin

  inherited Create(True);
  FreeOnTerminate := False;
  FHost := Host;
  FPort := Port;
  FStopOnVolumeReply := StopOnVolumeReply;
  FStopOnChannelReply := StopOnChannelReply;
  FStopOnZoneReply := StopOnZoneReply;
  FStopOnToneReply := StopOnToneReply;
  FCommands := TStringList.Create;
  FLines := TStringList.Create;
  for I := Low(Commands) to High(Commands) do
    FCommands.Add(Commands[I]);
end;


destructor TDenonRequest.Destroy();
begin

  FCommands.Free;
  FLines.Free;
  inherited;
end;


procedure TDenonRequest.RunCommand(Client: TAvrClient;
                                       const Command: TAvrCommand);
var
  Id: UInt64;
  Message: TAvrMessage;
  Timer: TStopwatch;

begin

  if Terminated then
    raise EAbort.Create('AVR request cancelled.');

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

        if (Message.Value.RawText <> '') and
           ((FLines.Count = 0) or (FLines[FLines.Count - 1] <> Message.Value.RawText)) then
          FLines.Add(Message.Value.RawText);

        if (Message.RequestId <> Id) then
          Continue;

        if (Message.Kind = amError) then
          begin

            if Message.DeliveryUnknown then
              raise EInvalidOperation.Create(Message.ErrorText +
                                               ' Delivery is uncertain; command was not replayed.');
            raise EInvalidOperation.Create(Message.ErrorText);
          end;

        if (Message.Kind = amReply) then
          Exit;
      finally
        Message.Free;
      end;
    end;

  raise EInvalidOperation.Create('AVR response timed out or request was cancelled.');
end;


procedure TDenonRequest.Execute();
var
  Client: TAvrClient;
  Command: string;
  Line: string;
  Message: TAvrMessage;
  Timer: TStopwatch;
  Received: set of TAvrValueKind;

begin

  Client := nil;
  try
    try

      if (FPort < 1) or (FPort > 65535) then
        raise EArgumentOutOfRangeException.Create('Invalid AVR port.');

      Client := TAvrClient.Create(FHost, FPort);
      // Keep commands serial: a failed write must not send the next command.
      for Command in FCommands do
        begin

          if Terminated then
            Exit;
          RunCommand(Client, ApiCommand(Command));
        end;

      // Capture trailing notifications, including MVMAX after an MV reply.
      Timer := TStopwatch.StartNew();
      while not Terminated and (Timer.ElapsedMilliseconds < 200) do
        begin

          if not Client.TakeMessage(Message) then
            begin

              Sleep(10);
              Continue;
            end;

          try
            if (Message.Value.RawText <> '') and
               ((FLines.Count = 0) or (FLines[FLines.Count - 1] <> Message.Value.RawText)) then
              FLines.Add(Message.Value.RawText);
          finally
            Message.Free;
          end;
        end;

      Received := [];
      for Line in FLines do
        Include(Received, ParseAvrValue(Line).Kind);

      if FStopOnVolumeReply and not (avVolume in Received) then
        raise EInvalidOperation.Create('Receiver did not confirm a volume value.');
      if FStopOnChannelReply and not ([avFrontLeft, avFrontRight] <= Received) then
        raise EInvalidOperation.Create('Receiver did not confirm both front channel levels.');
      if FStopOnZoneReply and not ([avMainZonePower, avZone2Power] <= Received) then
        raise EInvalidOperation.Create('Receiver did not confirm both zone power states.');
      if FStopOnToneReply and not
         ([avToneControl, avBass, avTreble, avSurroundMode, avDynamicEq] <= Received) then
        raise EInvalidOperation.Create('Receiver did not confirm tone settings. Check the sound mode, Dynamic EQ and audio signal.');
    except
      on E: Exception do
        FError := E.Message;
    end;
  finally
    Client.Free;
  end;
end;

end.
