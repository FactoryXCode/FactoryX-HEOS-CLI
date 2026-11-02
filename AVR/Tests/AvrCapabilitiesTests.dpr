// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: FactoryX HEOS CLI
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: AvrCapabilitiesTests.dpr
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
program AvrCapabilitiesTests;

{$APPTYPE CONSOLE}

uses

  System.SysUtils,
  System.Classes,
  System.Diagnostics,
  System.IniFiles,
  WinApi.Windows,
  Avr.Capabilities;

procedure Require(Value: Boolean;
                  const Text: string);
begin

  if not Value then
    raise Exception.Create(Text);
end;


procedure WaitFor(Manager: TAvrCapabilityManager);
var
  Clock: TStopwatch;

begin

  Clock := TStopwatch.StartNew;
  repeat
    Manager.Poll();
    CheckSynchronize(0);
    Sleep(10);
  until not Manager.Busy() or (Clock.ElapsedMilliseconds > 6500);
  Require(not Manager.Busy(), 'Capability request exceeded its time budget');
end;


function ReadText(const FileName: string): string;
var
  Lines: TStringList;

begin

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FileName, TEncoding.UTF8);
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

var
  Xml: string;
  Text: string;
  Data: TAvrCapabilityData;
  Feature: TAvrFeature;
  Manager: TAvrCapabilityManager;
  Clock: TStopwatch;
  Cache: string;
  Settings: TMemIniFile;
  Sections: TStringList;

begin

  try
    Xml := ReadText(ParamStr(1));
    Require(TAvrCapabilityManager.ParseXml(Xml, 'uuid:capability-test', Data, Text), Text);
    for Feature := Low(TAvrFeature) to High(TAvrFeature) do
      Require(Data.Features[Feature] = asSupported,
                'Real X2700H flag not recognized: ' + IntToStr(Ord(Feature)));
    Require(Data.Model = 'AVR-X2700H', 'Model identification failed');
    Require(not TAvrCapabilityManager.ParseXml('<html>error</html>', '', Data, Text),
              'HTML was treated as unsupported features');
    Require(not TAvrCapabilityManager.ParseXml('<Device_Info>', '', Data, Text),
              'Malformed XML was accepted');
    Require(not TAvrCapabilityManager.ParseXml(
              '<!DOCTYPE x [<!ENTITY secret SYSTEM "file:///C:/test">]><Device_Info/>',
              '', Data, Text), 'External XML entities were accepted');
    Require(TAvrCapabilityManager.ParseXml(
              '<Device_Info><DeviceZones>1</DeviceZones></Device_Info>', '', Data, Text) and
              (Data.Features[afZone2] = asUnsupported) and
              (Data.Features[afVolume] = asUnknown),
              'Missing flags were interpreted as unsupported');
    Require(not TAvrCapabilityManager.ParseXml(
              StringReplace(Xml, '<Device_Info>',
                '<Device_Info><UDN>uuid:another-receiver</UDN>', []),
              'uuid:2f21b22f-f71f-1b0b-1234-AABBCCDDEEFF', Data, Text),
              'A different receiver at the saved IP was accepted');

    Cache := ParamStr(2);
    Manager := TAvrCapabilityManager.Create(Cache);
    try
      Manager.SelectDevice('127.0.0.1', 'uuid:capability-test', StrToInt(ParamStr(3)));
      Require(not Manager.Busy(), 'Selecting cached identity sent a network request');
      Clock := TStopwatch.StartNew;
      Manager.Refresh();
      Require(Clock.ElapsedMilliseconds < 150, 'Refresh blocked the caller');
      WaitFor(Manager);
      Require((Manager.ErrorText = '') and FileExists(Cache) and
              (Manager.Support(afBalance) = asSupported), 'Successful refresh was not cached: ' + Manager.ErrorText);
      Manager.SelectDevice('127.0.0.2', 'uuid:capability-test', StrToInt(ParamStr(3)));
      Require(Manager.FromCache and (Manager.Support(afTone) = asSupported),
              'DHCP address change lost identity-based cache');
      Manager.SelectDevice('127.0.0.1', 'uuid:capability-test', StrToInt(ParamStr(4)));
      Manager.Refresh();
      WaitFor(Manager);
      Require(Manager.FromCache and (Manager.ErrorText <> '') and
              (Manager.Support(afVolume) = asSupported), 'HTTP failure destroyed cached capabilities');
      Manager.SelectDevice('127.0.0.1', 'uuid:another-device', StrToInt(ParamStr(4)));
      Require(not Manager.FromCache and (Manager.Support(afVolume) = asUnknown),
              'Another receiver inherited cached capabilities');
      Manager.Refresh();
      WaitFor(Manager);
      Require(Manager.Support(afTone) = asUnknown, 'Unavailable endpoint marked tone unsupported');

      Manager.SelectDevice('127.0.0.1', 'uuid:capability-test', StrToInt(ParamStr(5)));
      Manager.Refresh();
      Sleep(80);
      Clock := TStopwatch.StartNew;
      Manager.SelectDevice('127.0.0.1', 'uuid:capability-test', StrToInt(ParamStr(3)));
      Require(Clock.ElapsedMilliseconds < 150, 'Changing receiver waited for stale HTTP work');
      Manager.Refresh();
      WaitFor(Manager);
      Sleep(650);
      Manager.Poll();
      Require(Manager.Support(afTone) = asSupported, 'Retired result overwrote the selected device');

      Manager.SelectDevice('127.0.0.1', 'uuid:capability-test', StrToInt(ParamStr(6)));
      Manager.Refresh();
      WaitFor(Manager);
      Require((Manager.ErrorText <> '') and (Manager.Support(afVolume) = asSupported),
              'Truncated/timed-out reply: ' + Manager.ErrorText +
              ', support=' + IntToStr(Ord(Manager.Support(afVolume))) +
              ', elapsed=' + IntToStr(Manager.ElapsedMs));
    finally
      Manager.Free;
    end;

    Settings := TMemIniFile.Create(Cache, TEncoding.UTF8);
    Sections := TStringList.Create;
    try
      Settings.ReadSections(Sections);
      Require(Sections.Count > 0, 'Cache contains no devices');
      Settings.WriteInteger(Sections[0], 'Schema', 999);
      Settings.UpdateFile;
    finally
      Sections.Free;
      Settings.Free;
    end;
    Manager := TAvrCapabilityManager.Create(Cache);
    try
      Manager.SelectDevice('127.0.0.1', 'uuid:capability-test');
      Require(not Manager.FromCache and (Manager.Support(afVolume) = asUnknown),
              'Incompatible cache schema was used');
    finally
      Manager.Free;
    end;
    Writeln('PASS capability XML, identity cache, async refresh, stale/corrupt/failed replies, bounded refresh and cache schema validation.');
  except
    on E: Exception do
      begin
        Writeln(E.ClassName + ': ' + E.Message);
        Halt(1);
      end;
  end;
end.
