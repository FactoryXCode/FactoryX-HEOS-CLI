// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: FactoryX HEOS CLI
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: AvrCliDemo.dpr
// Kind: Pascal Unit
// Release date: 28-10-2026
// Language: ENU
//
// Revision Version: 1.0.0.1
// Description: Read-only AVR control API example.
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
program AvrCliDemo;

{$APPTYPE CONSOLE}

uses

  System.SysUtils,
  System.Classes,
  System.Diagnostics,
  Avr.Client in '..\Source\Avr.Client.pas',
  Avr.Commands in '..\Source\Avr.Commands.pas',
  Heos.Sockets in '..\..\Source\Heos.Sockets.pas';

var
  Client: TAvrClient;
  Message: TAvrMessage;
  Ids: TArray<UInt64>;
  Completed: Integer;
  Errors: Integer;
  Timer: TStopwatch;
  Port: Integer;

begin

  Client := nil;
  Errors := 0;

  try

    try

      if (ParamCount < 1) then
        begin

          Writeln('Usage: AvrCliDemo RECEIVER-IP [PORT]');
          Writeln('Read-only AVR status queries; does not activate zones or change settings.');
          Exit;
        end;

      Port := 23;
      if (ParamCount > 1) then
        Port := StrToInt(ParamStr(2));
      if (Port < 1) or (Port > 65535) then
        raise Exception.Create('Port must be 1 to 65535.');

      Client := TAvrClient.Create(ParamStr(1), Port);
      Ids := Client.EnqueueBatch([TAvrCommands.GetPower(),
                                   TAvrCommands.GetMainZonePower(),
                                   TAvrCommands.GetZone2Power(),
                                   TAvrCommands.GetVolume(),
                                   TAvrCommands.GetMute(),
                                   TAvrCommands.GetInput(),
                                   TAvrCommands.GetFrontLeft(),
                                   TAvrCommands.GetFrontRight(),
                                   TAvrCommands.GetToneControl(),
                                   TAvrCommands.GetBass(),
                                   TAvrCommands.GetTreble(),
                                   TAvrCommands.GetSurroundMode(),
                                   TAvrCommands.GetDynamicEq()]);
      Completed := 0;
      Timer := TStopwatch.StartNew;

      while (Completed < Length(Ids)) do
        begin

          if (Timer.ElapsedMilliseconds > Length(Ids) * 6000) then
            raise Exception.Create('AVR example timed out.');

          if not Client.TakeMessage(Message) then
            begin

              Sleep(10);
              Continue;
            end;

          try

            if (Message.Kind = amReply) then
              begin

                Inc(Completed);
                Writeln(Message.CommandText + ' -> ' + Message.Value.RawText);
              end
            else
              if (Message.Kind = amError) and (Message.RequestId <> 0) then
                begin

                  Inc(Completed);
                  Inc(Errors);
                  Writeln(Message.CommandText + ' ! ' + Message.ErrorText);
                end;
          finally

            Message.Free;
          end;
        end;
    except

      on E: Exception do
        begin

          Inc(Errors);
          Writeln(E.ClassName + ': ' + E.Message);
        end;
    end;
  finally

    Client.Free;
  end;

  if (Errors > 0) then
    ExitCode := 1;
end.