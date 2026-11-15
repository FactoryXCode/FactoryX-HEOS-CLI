// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: Media Foundation - MFPack - Samples
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HeosReceiverRecoveryTests.dpr
// Kind: Pascal Unit
// Release date: 30-10-2026
// Language: ENU
//
// Revision Version: 1.1.0.0
// Description: Receiver INI, DHCP recovery and offline status checks.
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
program HeosReceiverRecoveryTests;

{$APPTYPE CONSOLE}

uses

  System.SysUtils,
  System.Classes,
  System.IniFiles,
  System.Diagnostics,
  WinApi.Windows,
  Vcl.Forms,
  MainForm,
  HEOSDiscovery,
  Heos.Sockets,
  Heos.Cli,
  Heos.Commands;

type
  PObservedExceptionRecord = ^TObservedExceptionRecord;
  TObservedExceptionRecord = record
    Code: Cardinal;
  end;
  PObservedExceptionPointers = ^TObservedExceptionPointers;
  TObservedExceptionPointers = record
    ExceptionRecord: PObservedExceptionRecord;
    ContextRecord: Pointer;
  end;

function AddVectoredExceptionHandler(First: Cardinal; Handler: Pointer): Pointer; stdcall;
  external 'kernel32.dll' name 'AddVectoredExceptionHandler';
function RemoveVectoredExceptionHandler(Handle: Pointer): Cardinal; stdcall;
  external 'kernel32.dll' name 'RemoveVectoredExceptionHandler';

var
  DelphiExceptions: Integer;

function ObserveException(Info: PObservedExceptionPointers): LongInt; stdcall;
begin

  if (Info.ExceptionRecord.Code = $0EEDFADE) then
    InterlockedIncrement(DelphiExceptions);
  Result := 0;
end;

procedure Require(Value: Boolean; const Text: string);
begin

  if not Value then
    raise Exception.Create(Text);
end;

type

  TEmptyDiscovery = class(THEOSDiscovery)
  protected
    procedure Execute(); override;
  end;

  TTestMain = class(THEOSForm)
  public
    ScanCount: Integer;
    function NewDiscovery(): THEOSDiscovery; override;
  end;

procedure TEmptyDiscovery.Execute();
begin
end;

function TTestMain.NewDiscovery(): THEOSDiscovery;
begin

  Inc(ScanCount);
  Result := TEmptyDiscovery.Create;
end;

procedure Pump(Main: TTestMain);
var
  Clock: TStopwatch;

begin

  Clock := TStopwatch.StartNew;
  repeat
    Main.CompleteReceiverCheck();
    CheckSynchronize(0);
    Sleep(10);
  until (not Assigned(Main.FReceiverCheck) and
         (not Assigned(Main.FDiscovery) or Main.FDiscoveryComplete)) or
        (Clock.ElapsedMilliseconds > 6000);
  Require(not Assigned(Main.FReceiverCheck), 'Cached receiver check did not finish');
end;

procedure WriteSettings(const Path: string; const Host: string);
var
  Settings: TMemIniFile;

begin

  ForceDirectories(ExtractFilePath(Path));
  Settings := TMemIniFile.Create(Path);
  try
    Settings.WriteString('Receiver', 'Host', Host);
    Settings.WriteString('Receiver', 'DeviceId', 'uuid:my-receiver');
    Settings.UpdateFile;
  finally
    Settings.Free;
  end;
end;

procedure CheckOffline(Port: Word);
var
  Connection: Heos.Sockets.THeosConnection;
  Client: THeosClient;
  Text: string;
  Message: THeosMessage;
  Id: UInt64;
  Done: Boolean;
  Clock: TStopwatch;
  Observer: Pointer;

begin

  Observer := AddVectoredExceptionHandler(1, @ObserveException);
  try
    DelphiExceptions := 0;
    Require(not Heos.Sockets.THeosConnection.TryConnect('127.0.0.1', Port, 200,
                                                       Connection, Text), 'Closed port unexpectedly connected');
    Require(not Assigned(Connection) and (Pos(IntToStr(Port), Text) > 0),
            'TryConnect did not release the failed socket/report the endpoint');
    Client := THeosClient.Create('127.0.0.1', Port, 200);
    try
      Id := Client.Enqueue(THeosCommands.GetPlayers());
      Done := False;
      Clock := TStopwatch.StartNew;
      repeat
        while Client.TakeMessage(Message) do
          try
            if (Message.RequestId = Id) then
              begin
                Require((Message.Kind = hmError) and not Message.DeliveryUnknown and
                        (Pos(IntToStr(Port), Message.ErrorText) > 0),
                        'Offline request lost its endpoint/delivery status');
                Done := True;
              end;
          finally
            Message.Free;
          end;
        Sleep(10);
      until Done or (Clock.ElapsedMilliseconds > 3000);
      Require(Done, 'Offline request did not produce an error status');
    finally
      Client.Free;
    end;
    Require(DelphiExceptions = 0, 'An expected connect failure raised a first-chance Delphi exception');
  finally
    RemoveVectoredExceptionHandler(Observer);
  end;
end;

var
  Main: TTestMain;
  Settings: TMemIniFile;
  Path: string;
  Devices: TArray<THEOSDevice>;
  PreviousDirectory: string;

begin

  try
    Application.Initialize;
    CheckOffline(StrToInt(ParamStr(1)));
    PreviousDirectory := GetEnvironmentVariable('LOCALAPPDATA');
    SetEnvironmentVariable('LOCALAPPDATA', PChar(ParamStr(2)));
    try
      Path := IncludeTrailingPathDelimiter(ParamStr(2)) + 'FactoryX\HEOSRemote\Receiver.ini';
      WriteSettings(Path, '127.0.0.1');
      Main := TTestMain.Create(nil);
      try
        Require(Main.edHost.Text = '127.0.0.1', 'INI address was not restored before startup');
        Main.FormShow(nil);
        Main.RadioClick(nil);
        Require(Main.FOpenRadioPending and not Assigned(Main.FRadioForm),
                'Radio connected before the cached IP was confirmed');
        Main.FOpenRadioPending := False;
        Pump(Main);
        Require(Main.FReceiverVerified and (Main.ScanCount = 0),
                'Reachable saved HEOS address unnecessarily triggered discovery');
      finally
        Main.Free;
      end;

      WriteSettings(Path, 'invalid-address');
      Main := TTestMain.Create(nil);
      try
        Main.FormShow(nil);
        Pump(Main);
        Require((Main.ScanCount = 1) and not Main.FReceiverVerified,
                'Invalid saved address did not scan or was treated as confirmed');
      finally
        Main.Free;
      end;

      WriteSettings(Path, '127.0.0.2');
      Main := TTestMain.Create(nil);
      try
        Main.FormShow(nil);
        Pump(Main);
        Require((Main.ScanCount = 1) and not Main.FReceiverVerified,
                'Unreachable saved IP did not trigger exactly one scan');
        Main.FOpenRadioPending := True;
        Main.ContinuePendingRadio();
        Require(not Assigned(Main.FRadioForm), 'Failed discovery still opened Radio');
        SetLength(Devices, 2);
        Devices[0].Address := '127.0.0.2';
        Devices[0].Name := 'A different HEOS device at the old IP';
        Devices[0].DeviceId := 'uuid:other';
        Devices[1].Address := '127.0.0.1';
        Devices[1].Name := 'My receiver at its new IP';
        Devices[1].DeviceId := 'uuid:my-receiver';
        Devices[1].AvrAvailable := False;
        Main.ApplyDiscoveredDevices(Devices, '');
        Require(Main.FReceiverVerified and (Main.edHost.Text = '127.0.0.1') and
                (Main.cbxHEOSDevices.ItemIndex = 1),
                'DHCP recovery did not select the same receiver by device ID');
        Settings := TMemIniFile.Create(Path);
        try
          Require((Settings.ReadString('Receiver', 'Host', '') = '127.0.0.1') and
                  (Settings.ReadString('Receiver', 'DeviceId', '') = 'uuid:my-receiver'),
                  'Confirmed new IP/identity were not saved to INI');
        finally
          Settings.Free;
        end;
      finally
        Main.Free;
      end;
      Main := TTestMain.Create(nil);
      try
        Require((Main.edHost.Text = '127.0.0.1') and
                (Main.FPreferredDeviceId = 'uuid:my-receiver') and not Main.FReceiverVerified,
                'Next launch did not restore the last confirmed receiver for checking');
      finally
        Main.Free;
      end;
    finally
      SetEnvironmentVariable('LOCALAPPDATA', PChar(PreviousDirectory));
    end;
    Writeln('PASS exception-free offline status, INI-first startup, no scan for reachable IP, fallback scan, radio deferral and DHCP/identity persistence.');
  except
    on E: Exception do
      begin
        Writeln(E.ClassName + ': ' + E.Message);
        Halt(1);
      end;
  end;
end.
