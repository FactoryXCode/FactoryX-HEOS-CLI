// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: FactoryX HEOS CLI
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HeosCliDemo.dpr
// Kind: Pascal Unit
// Release date: 28-10-2026
// Language: ENU
//
// Revision Version: 1.0.0.1
// Description: Read-only HEOS CLI console example.
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
program HeosCliDemo;

{$APPTYPE CONSOLE}

uses

  System.SysUtils,
  System.Classes,
  System.Diagnostics,
  Heos.Cli in '..\Source\Heos.Cli.pas',
  Heos.Commands in '..\Source\Heos.Commands.pas',
  Heos.Sockets in '..\Source\Heos.Sockets.pas';

var
  Client: THeosClient;
  Message: THeosMessage;
  Timer: TStopwatch;
  Completed: Integer;
  WatchSeconds: Integer;

begin

  Client := nil;
  try
    if (ParamCount < 1) then
      begin
        Writeln('Usage: HeosCliDemo RECEIVER-IP [WATCH-SECONDS]');
        Writeln('Reads players, sources and groups. Optional watch duration: 1 to 300 seconds.');
        Exit;
      end;
    WatchSeconds := 0;
    if (ParamCount > 1) then
      if not TryStrToInt(ParamStr(2), WatchSeconds) or
         (WatchSeconds < 0) or (WatchSeconds > 300) then
        raise EArgumentException.Create('Watch duration must be 0 to 300 seconds');

    Client := THeosClient.Create(ParamStr(1));
    Client.Enqueue(THeosCommands.GetPlayers());
    Client.Enqueue(THeosCommands.GetMusicSources());
    Client.Enqueue(THeosCommands.GetGroups());
    Completed := 0;
    Timer := TStopwatch.StartNew;
    while (Completed < 3) do
      begin
        while Client.TakeMessage(Message) do
          try
            if (Message.Kind in [hmReply, hmError]) and (Message.RequestId <> 0) then
              begin
                Inc(Completed);
                if Message.Success then
                  Writeln(Message.Root.ToJSON())
                else
                  begin
                    Writeln('Request ', Message.RequestId, ': ', Message.ErrorText);
                    ExitCode := 1;
                  end;
              end;
          finally
            Message.Free;
          end;
        if (Timer.ElapsedMilliseconds > 50000) then
          raise Exception.Create('HEOS demo timed out');
        Sleep(10);
      end;

    if (WatchSeconds > 0) and (ExitCode = 0) then
      begin
        Client.Enqueue(THeosCommands.RegisterForChangeEvents(True));
        Timer := TStopwatch.StartNew;
        while (Timer.ElapsedMilliseconds < Int64(WatchSeconds) * 1000) do
          begin
            while Client.TakeMessage(Message) do
              try
                if Assigned(Message.Root) then
                  Writeln(Message.Root.ToJSON())
                else if (Message.Kind = hmError) then
                  Writeln(Message.ErrorText);
              finally
                Message.Free;
              end;
            Sleep(10);
          end;
      end;
  except
    on E: Exception do
      begin
        Writeln(E.ClassName, ': ', E.Message);
        ExitCode := 1;
      end;
  end;
  Client.Free;
end.
