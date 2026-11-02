// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: FactoryX HEOS CLI
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: Avr.Capabilities.pas
// Kind: Pascal Unit
// Release date: 31-10-2026
// Language: ENU
//
// Revision Version: 1.0.0.1
// Description: Asynchronous AVR capability discovery and identity cache.
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
unit Avr.Capabilities;

interface

uses

  {System}
  System.Classes,
  System.SysUtils,
  System.Generics.Collections;

type

  TAvrSupport = (asUnknown,
                 asSupported,
                 asUnsupported);

  TAvrFeature = (afMainZone,
                 afZone2,
                 afVolume,
                 afMute,
                 afBalance,
                 afTone,
                 afBass,
                 afTreble);

  TAvrCapabilityData = record
    DeviceId: string;
    Model: string;
    Firmware: string;
    RetrievedAt: TDateTime;
    Features: array[TAvrFeature] of TAvrSupport;
  end;

  TAvrCapabilityRequest = class(TThread)
  private

    FHost: string;
    FDeviceId: string;
    FPort: Word;
    FData: TAvrCapabilityData;
    FErrorText: string;
    FSuccess: Boolean;
    FElapsedMs: Int64;

  protected

    procedure Execute(); override;

  public

    constructor Create(const Host: string;
                       const DeviceId: string;
                       Port: Word = 8080);

    property Host: string read FHost;
    property Data: TAvrCapabilityData read FData;
    property Success: Boolean read FSuccess;
    property ErrorText: string read FErrorText;
    property ElapsedMs: Int64 read FElapsedMs;
  end;

  // SelectDevice, Refresh and Poll are called from the owning (normally UI) thread.
  // Workers never call VCL code. Poll returns True when the visible result changes.
  TAvrCapabilityManager = class
  private

    FCacheFile: string;
    FHost: string;
    FDeviceId: string;
    FPort: Word;
    FData: TAvrCapabilityData;
    FFromCache: Boolean;
    FErrorText: string;
    FElapsedMs: Int64;
    FRequest: TAvrCapabilityRequest;
    FRetired: TObjectList<TAvrCapabilityRequest>;

    function CacheSection(): string;
    procedure LoadCache();
    procedure SaveCache();

  public

    constructor Create(const CacheFile: string);
    destructor Destroy(); override;

    procedure SelectDevice(const Host: string;
                           const DeviceId: string;
                           Port: Word = 8080);
    procedure Refresh();
    function Poll(): Boolean;
    function Busy(): Boolean;
    function Support(Feature: TAvrFeature): TAvrSupport;

    class function ParseXml(const Xml: string;
                            const DeviceId: string;
                            out Data: TAvrCapabilityData;
                            out ErrorText: string): Boolean; static;

    property Host: string read FHost;
    property DeviceId: string read FDeviceId;
    property Data: TAvrCapabilityData read FData;
    property FromCache: Boolean read FFromCache;
    property ErrorText: string read FErrorText;
    property ElapsedMs: Int64 read FElapsedMs;
  end;

implementation

uses

  {WinApi}
  WinApi.Windows,
  WinApi.ActiveX,
  {System}
  System.IniFiles,
  System.Diagnostics,
  System.StrUtils,
  {Xml}
  Xml.XMLDoc,
  Xml.XMLIntf;

type

  // Minimal Windows SDK bindings keep this unit compatible with Delphi XE7.
  HINTERNET = Pointer;

function WinHttpOpen(Agent: PWideChar; AccessType: DWORD; ProxyName: PWideChar;
                     ProxyBypass: PWideChar; Flags: DWORD): HINTERNET; stdcall; external 'winhttp.dll';
function WinHttpConnect(Session: HINTERNET; Host: PWideChar; Port: Word;
                        Reserved: DWORD): HINTERNET; stdcall; external 'winhttp.dll';
function WinHttpOpenRequest(Connection: HINTERNET; Verb: PWideChar; Path: PWideChar;
                            Version: PWideChar; Referrer: PWideChar; AcceptTypes: Pointer;
                            Flags: DWORD): HINTERNET; stdcall; external 'winhttp.dll';
function WinHttpSetTimeouts(Session: HINTERNET; ResolveMs: Integer; ConnectMs: Integer;
                            SendMs: Integer; ReceiveMs: Integer): BOOL; stdcall; external 'winhttp.dll';
function WinHttpSetOption(Request: HINTERNET; Option: DWORD; Buffer: Pointer;
                          BufferLength: DWORD): BOOL; stdcall; external 'winhttp.dll';
function WinHttpSendRequest(Request: HINTERNET; Headers: PWideChar; HeadersLength: DWORD;
                            Optional: Pointer; OptionalLength: DWORD; TotalLength: DWORD;
                            Context: NativeUInt): BOOL; stdcall; external 'winhttp.dll';
function WinHttpReceiveResponse(Request: HINTERNET; Reserved: Pointer): BOOL; stdcall; external 'winhttp.dll';
function WinHttpQueryHeaders(Request: HINTERNET; InfoLevel: DWORD; Name: PWideChar;
                             Buffer: Pointer; var BufferLength: DWORD;
                             Index: Pointer): BOOL; stdcall; external 'winhttp.dll';
function WinHttpReadData(Request: HINTERNET; Buffer: Pointer; Size: DWORD;
                         var BytesRead: DWORD): BOOL; stdcall; external 'winhttp.dll';
function WinHttpCloseHandle(Handle: HINTERNET): BOOL; stdcall; external 'winhttp.dll';

const

  CapabilityCacheVersion = 1;
  WinHttpAccessTypeNoProxy = 1;
  WinHttpOptionDisableFeature = 63;
  WinHttpDisableRedirects = $00000002;
  WinHttpQueryStatusCode = 19;
  WinHttpQueryFlagNumber = $20000000;
  MaximumCapabilityBytes = 1024 * 1024;

function Child(Node: IXMLNode;
               const Name: string): IXMLNode;
begin

  Result := nil;
  if Assigned(Node) then
    Result := Node.ChildNodes.FindNode(Name);
end;


function TextOf(Node: IXMLNode;
                const Name: string): string;
var
  Value: IXMLNode;

begin

  Result := '';
  Value := Child(Node, Name);
  if Assigned(Value) then
    Result := Trim(Value.Text);
end;


function Flag(Node: IXMLNode): TAvrSupport;
var
  Value: string;

begin

  Result := asUnknown;
  if not Assigned(Node) then
    Exit;
  Value := Trim(Node.Text);
  if (Value = '1') then
    Result := asSupported
  else
    if (Value = '0') then
      Result := asUnsupported;
end;


function ParseCapabilityDocument(const Xml: string;
                                              const DeviceId: string;
                                              out Data: TAvrCapabilityData;
                                              out ErrorText: string): Boolean;
var
  Document: IXMLDocument;
  Root: IXMLNode;
  Setup: IXMLNode;
  Zone: IXMLNode;
  Node: IXMLNode;
  Tone: IXMLNode;
  Channels: IXMLNode;
  Feature: TAvrFeature;
  I: Integer;
  ZoneNumber: Integer;
  Count: Integer;
  LeftFound: Boolean;
  RightFound: Boolean;
  AdvertisedId: string;

begin

  Result := False;
  ErrorText := '';
  Data := Default(TAvrCapabilityData);
  if (Length(Xml) > MaximumCapabilityBytes) or
     ContainsText(Xml, '<!DOCTYPE') or ContainsText(Xml, '<!ENTITY') then
    begin
      ErrorText := 'Unsupported or oversized device capability XML.';
      Exit;
    end;

  try
    Document := LoadXMLData(Xml);
    Root := Document.DocumentElement;
    if not Assigned(Root) or (Root.NodeName <> 'Device_Info') then
      raise Exception.Create('Not a Denon/Marantz device capability document.');

    // The caller supplies the SSDP identity. Do not derive it from MacAddress:
    // the UUID and capability document can refer to different network interfaces.
    AdvertisedId := TextOf(Root, 'UDN');
    if (DeviceId <> '') and (AdvertisedId <> '') and
       not SameText(DeviceId, AdvertisedId) then
      raise Exception.Create('Capability identity does not match the selected receiver.');

    Data.DeviceId := DeviceId;
    Data.Model := TextOf(Root, 'ModelName');
    Data.Firmware := TextOf(Root, 'UpgradeVersion');
    Data.RetrievedAt := Now;
    Setup := Child(Child(Root, 'DeviceCapabilities'), 'Setup');
    Tone := Child(Setup, 'ToneControl');
    Data.Features[afTone] := Flag(Child(Tone, 'Control'));
    if (Data.Features[afTone] = asUnsupported) then
      begin
        Data.Features[afBass] := asUnsupported;
        Data.Features[afTreble] := asUnsupported;
      end
    else
      if (Data.Features[afTone] = asSupported) then
        begin
          Node := Child(Tone, 'ToneControlSet_AVR');
          if Assigned(Child(Node, 'BassMin')) and Assigned(Child(Node, 'BassMax')) then
            Data.Features[afBass] := asSupported;
          if Assigned(Child(Node, 'TrebleMin')) and Assigned(Child(Node, 'TrebleMax')) then
            Data.Features[afTreble] := asSupported;
        end;

    Node := Child(Setup, 'ChannelLevel');
    Data.Features[afBalance] := Flag(Child(Node, 'Control'));
    if (Data.Features[afBalance] = asSupported) then
      begin
        // MainForm implements balance using both front-channel trim controls.
        Channels := Child(Node, 'ChLists');
        LeftFound := False;
        RightFound := False;
        if Assigned(Channels) then
          for I := 0 to Channels.ChildNodes.Count - 1 do
            begin
              LeftFound := LeftFound or (TextOf(Channels.ChildNodes[I], 'Name') = 'FL');
              RightFound := RightFound or (TextOf(Channels.ChildNodes[I], 'Name') = 'FR');
            end;
        if not Assigned(Channels) then
          Data.Features[afBalance] := asUnknown
        else
          if not (LeftFound and RightFound) then
            Data.Features[afBalance] := asUnsupported;
      end;

    if TryStrToInt(TextOf(Root, 'DeviceZones'), Count) and (Count = 1) then
      Data.Features[afZone2] := asUnsupported;
    for I := 0 to Root.ChildNodes.Count - 1 do
      begin
        Zone := Root.ChildNodes[I];
        if (Zone.NodeName <> 'DeviceZoneCapabilities') then
          Continue;
        if not TryStrToInt(TextOf(Child(Zone, 'Zone'), 'No'), ZoneNumber) then
          Continue;
        if (ZoneNumber = 0) then
          begin
            Data.Features[afMainZone] := Flag(Child(Child(Zone, 'Power'), 'Control'));
            Data.Features[afVolume] := Flag(Child(Child(Zone, 'Volume'), 'Control'));
            Data.Features[afMute] := Flag(Child(Child(Zone, 'Mute'), 'Control'));
          end
        else
          if (ZoneNumber = 1) then
            Data.Features[afZone2] := Flag(Child(Child(Zone, 'Power'), 'Control'));
      end;

    Count := 0;
    for Feature := Low(TAvrFeature) to High(TAvrFeature) do
      if (Data.Features[Feature] <> asUnknown) then
        Inc(Count);
    if (Count = 0) then
      raise Exception.Create('No recognized AVR capability flags were returned.');
    Result := True;
  except
    on E: Exception do
      begin
        ErrorText := E.Message;
        Data := Default(TAvrCapabilityData);
      end;
  end;
end;


class function TAvrCapabilityManager.ParseXml(const Xml: string;
                                              const DeviceId: string;
                                              out Data: TAvrCapabilityData;
                                              out ErrorText: string): Boolean;
var
  ComResult: HRESULT;

begin

  ComResult := CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
    // All XML interfaces, including compiler-created temporaries, must be
    // finalized before this thread releases its COM apartment.
    Result := ParseCapabilityDocument(Xml, DeviceId, Data, ErrorText);
  finally
    if (ComResult = S_OK) or (ComResult = S_FALSE) then
      CoUninitialize();
  end;
end;


constructor TAvrCapabilityRequest.Create(const Host: string;
                                          const DeviceId: string;
                                          Port: Word);
begin

  inherited Create(True);
  FreeOnTerminate := False;
  FHost := Host;
  FDeviceId := DeviceId;
  FPort := Port;
end;


procedure TAvrCapabilityRequest.Execute();
var
  Session: HINTERNET;
  Connection: HINTERNET;
  Request: HINTERNET;
  Status: DWORD;
  Size: DWORD;
  DisabledFeatures: DWORD;
  Count: DWORD;
  Buffer: array[0..8191] of Byte;
  Stream: TMemoryStream;
  Clock: TStopwatch;
  Bytes: TBytes;

  procedure Fail(const Operation: string);
  begin

    FErrorText := Format('Device capability %s failed (Windows error %d).',
                          [Operation, GetLastError()]);
  end;

begin

  Session := nil;
  Connection := nil;
  Request := nil;
  Stream := nil;
  Clock := TStopwatch.StartNew;
  try
    try
      Session := WinHttpOpen('FactoryX AVR capabilities', WinHttpAccessTypeNoProxy, nil, nil, 0);
      if not Assigned(Session) then
        begin
          Fail('session');
          Exit;
        end;
      if not WinHttpSetTimeouts(Session, 500, 1200, 1200, 1200) then
        begin
          Fail('timeout configuration');
          Exit;
        end;
      Connection := WinHttpConnect(Session, PChar(FHost), FPort, 0);
      if not Assigned(Connection) then
        begin
          Fail('connection');
          Exit;
        end;
      Request := WinHttpOpenRequest(Connection, 'GET', '/goform/Deviceinfo.xml',
                                      nil, nil, nil, 0);
      if not Assigned(Request) then
        begin
          Fail('request');
          Exit;
        end;
      DisabledFeatures := WinHttpDisableRedirects;
      if not WinHttpSetOption(Request, WinHttpOptionDisableFeature, @DisabledFeatures, SizeOf(DisabledFeatures)) then
        begin
          Fail('redirect configuration');
          Exit;
        end;
      if Terminated then
        Exit;
      if not WinHttpSendRequest(Request, nil, 0, nil, 0, 0, 0) then
        begin
          Fail('send');
          Exit;
        end;
      if Terminated then
        Exit;
      if not WinHttpReceiveResponse(Request, nil) then
        begin
          Fail('response');
          Exit;
        end;
      Status := 0;
      Size := SizeOf(Status);
      if not WinHttpQueryHeaders(Request, WinHttpQueryStatusCode or WinHttpQueryFlagNumber, nil, @Status, Size, nil) or
         (Status <> 200) then
        begin
          FErrorText := Format('Device capability request returned HTTP %d.', [Status]);
          Exit;
        end;
      Stream := TMemoryStream.Create;
      repeat
        if Terminated then
          Exit;
        if not WinHttpReadData(Request, @Buffer, SizeOf(Buffer), Count) then
          begin
            Fail('download');
            Exit;
          end;
        if (Clock.ElapsedMilliseconds > 4000) then
          begin
            FErrorText := 'Device capability request timed out.';
            Exit;
          end;
        if (Count = 0) then
          Break;
        if (Stream.Size + Count > MaximumCapabilityBytes) then
          begin
            FErrorText := 'Device capability document is too large.';
            Exit;
          end;
        Stream.WriteBuffer(Buffer, Count);
      until False;
      if Terminated then
        Exit;
      SetLength(Bytes, Stream.Size);
      if (Stream.Size > 0) then
        Move(Stream.Memory^, Bytes[0], Stream.Size);
      FSuccess := TAvrCapabilityManager.ParseXml(TEncoding.UTF8.GetString(Bytes),
                                                  FDeviceId, FData, FErrorText);
    except
      on E: Exception do
        FErrorText := E.Message;
    end;
  finally
    Stream.Free;
    if Assigned(Request) then
      WinHttpCloseHandle(Request);
    if Assigned(Connection) then
      WinHttpCloseHandle(Connection);
    if Assigned(Session) then
      WinHttpCloseHandle(Session);
    FElapsedMs := Clock.ElapsedMilliseconds;
  end;
end;


constructor TAvrCapabilityManager.Create(const CacheFile: string);
begin

  inherited Create;
  FCacheFile := CacheFile;
  FRetired := TObjectList<TAvrCapabilityRequest>.Create(True);
end;


destructor TAvrCapabilityManager.Destroy();
var
  Request: TAvrCapabilityRequest;

begin

  if Assigned(FRequest) then
    begin
      FRequest.Terminate;
      FRequest.WaitFor;
      FRequest.Free;
    end;
  for Request in FRetired do
    begin
      Request.Terminate;
      Request.WaitFor;
    end;
  FRetired.Free;
  inherited;
end;


function TAvrCapabilityManager.CacheSection(): string;
var
  C: Char;

begin

  // Hex encoding is stable, collision-free and valid for INI section names.
  Result := 'Device-';
  for C in LowerCase(FDeviceId) do
    Result := Result + IntToHex(Ord(C), 4);
end;


procedure TAvrCapabilityManager.LoadCache();
var
  Settings: TMemIniFile;
  Section: string;
  Feature: TAvrFeature;
  Data: TAvrCapabilityData;
  Value: Integer;

begin

  if (FDeviceId = '') or (FCacheFile = '') or not FileExists(FCacheFile) then
    Exit;
  Settings := TMemIniFile.Create(FCacheFile, TEncoding.UTF8);
  try
    Section := CacheSection();
    if (Settings.ReadInteger(Section, 'Schema', 0) <> CapabilityCacheVersion) or
       not SameText(Settings.ReadString(Section, 'DeviceId', ''), FDeviceId) then
      Exit;
    Data := Default(TAvrCapabilityData);
    Data.DeviceId := FDeviceId;
    Data.Model := Settings.ReadString(Section, 'Model', '');
    Data.Firmware := Settings.ReadString(Section, 'Firmware', '');
    Data.RetrievedAt := Settings.ReadDateTime(Section, 'RetrievedAt', 0);
    for Feature := Low(TAvrFeature) to High(TAvrFeature) do
      begin
        Value := Settings.ReadInteger(Section, 'Feature' + IntToStr(Ord(Feature)), 0);
        if (Value < Ord(Low(TAvrSupport))) or (Value > Ord(High(TAvrSupport))) then
          Exit;
        Data.Features[Feature] := TAvrSupport(Value);
      end;
    if (Data.RetrievedAt = 0) then
      Exit;
    FData := Data;
    FFromCache := True;
  finally
    Settings.Free;
  end;
end;


procedure TAvrCapabilityManager.SaveCache();
var
  Settings: TMemIniFile;
  Section: string;
  Feature: TAvrFeature;
  TemporaryFile: string;

begin

  if (FDeviceId = '') or (FCacheFile = '') then
    Exit;
  if not ForceDirectories(ExtractFilePath(ExpandFileName(FCacheFile))) then
    raise Exception.Create('Cannot create the capability cache directory.');
  TemporaryFile := FCacheFile + '.tmp';
  if FileExists(FCacheFile) then
    if not CopyFile(PChar(FCacheFile), PChar(TemporaryFile), False) then
      RaiseLastOSError();
  Settings := TMemIniFile.Create(TemporaryFile, TEncoding.UTF8);
  try
    Section := CacheSection();
    Settings.EraseSection(Section);
    Settings.WriteInteger(Section, 'Schema', CapabilityCacheVersion);
    Settings.WriteString(Section, 'DeviceId', FDeviceId);
    Settings.WriteString(Section, 'Model', FData.Model);
    Settings.WriteString(Section, 'Firmware', FData.Firmware);
    Settings.WriteDateTime(Section, 'RetrievedAt', FData.RetrievedAt);
    for Feature := Low(TAvrFeature) to High(TAvrFeature) do
      Settings.WriteInteger(Section, 'Feature' + IntToStr(Ord(Feature)),
                              Ord(FData.Features[Feature]));
    Settings.UpdateFile;
  finally
    Settings.Free;
  end;
  if not MoveFileEx(PChar(TemporaryFile), PChar(FCacheFile),
                     MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH) then
    RaiseLastOSError();
end;


procedure TAvrCapabilityManager.SelectDevice(const Host: string;
                                             const DeviceId: string;
                                             Port: Word);
begin

  if SameText(FHost, Host) and SameText(FDeviceId, DeviceId) and (FPort = Port) then
    Exit;
  if Assigned(FRequest) then
    begin
      FRequest.Terminate;
      FRetired.Add(FRequest);
      FRequest := nil;
    end;
  FHost := Host;
  FDeviceId := DeviceId;
  FPort := Port;
  FData := Default(TAvrCapabilityData);
  FData.DeviceId := DeviceId;
  FFromCache := False;
  FErrorText := '';
  FElapsedMs := 0;
  try
    LoadCache();
  except
    on E: Exception do
      FErrorText := 'Capability cache: ' + E.Message;
  end;
end;


procedure TAvrCapabilityManager.Refresh();
begin

  if Assigned(FRequest) or (FHost = '') then
    Exit;
  FErrorText := '';
  FRequest := TAvrCapabilityRequest.Create(FHost, FDeviceId, FPort);
  FRequest.Start;
end;


function TAvrCapabilityManager.Poll(): Boolean;
var
  I: Integer;

begin

  Result := False;
  for I := FRetired.Count - 1 downto 0 do
    if FRetired[I].Finished then
      FRetired.Delete(I);
  if not Assigned(FRequest) or not FRequest.Finished then
    Exit;
  FErrorText := FRequest.ErrorText;
  FElapsedMs := FRequest.ElapsedMs;
  try
    if FRequest.Success then
      begin
        FData := FRequest.Data;
        FFromCache := False;
        try
          SaveCache();
        except
          on E: Exception do
            FErrorText := 'Capability cache: ' + E.Message;
        end;
      end;
  finally
    FreeAndNil(FRequest);
  end;
  Result := True;
end;


function TAvrCapabilityManager.Busy(): Boolean;
begin

  Result := Assigned(FRequest);
end;


function TAvrCapabilityManager.Support(Feature: TAvrFeature): TAvrSupport;
begin

  Result := FData.Features[Feature];
end;

end.
