// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: Media Foundation - MFPack - Samples
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HEOS.UPnP.pas
// Kind: Pascal Unit
// Release date: 24-01-2026
// Language: ENU
//
// Revision Version: 4.0.0
// Description: Native UPnP AVTransport seeking for the HEOS receiver.
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
//          Please, read documentation carefully!
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
unit HEOS.UPnP;

interface

procedure SeekReceiverPosition(const AHost: string;
                                 const APositionMs: Int64;
                                 APort: Word = 60006);


implementation

uses

  {WinApi}
  Winapi.Windows,
  Winapi.ActiveX,
  {System}
  System.SysUtils,
  System.Classes,
  System.Win.ComObj,
  {Xml}
  Xml.XMLDoc,
  Xml.XMLIntf,
  Xml.Win.msxmldom;

type

  HINTERNET = Pointer;

function WinHttpOpen(Agent: PWideChar; AccessType: DWORD; ProxyName,
                      ProxyBypass: PWideChar; Flags: DWORD): HINTERNET; stdcall; external 'winhttp.dll';
function WinHttpConnect(Session: HINTERNET; ServerName: PWideChar;
                         ServerPort: Word; Reserved: DWORD): HINTERNET; stdcall; external 'winhttp.dll';
function WinHttpOpenRequest(Connection: HINTERNET; Verb, ObjectName,
                             Version, Referrer: PWideChar; AcceptTypes: Pointer;
                             Flags: DWORD): HINTERNET; stdcall; external 'winhttp.dll';
function WinHttpSendRequest(Request: HINTERNET; Headers: PWideChar;
                             HeadersLength: DWORD; Optional: Pointer;
                             OptionalLength, TotalLength: DWORD;
                             Context: NativeUInt): BOOL; stdcall; external 'winhttp.dll';
function WinHttpReceiveResponse(Request: HINTERNET; Reserved: Pointer): BOOL; stdcall; external 'winhttp.dll';
function WinHttpReadData(Request: HINTERNET; Buffer: Pointer;
                          BytesToRead: DWORD; var BytesRead: DWORD): BOOL; stdcall; external 'winhttp.dll';
function WinHttpQueryHeaders(Request: HINTERNET; InfoLevel: DWORD;
                              Name: PWideChar; Buffer: Pointer;
                              var BufferLength: DWORD; Index: Pointer): BOOL; stdcall; external 'winhttp.dll';
function WinHttpSetTimeouts(Session: HINTERNET; ResolveTimeout,
                             ConnectTimeout, SendTimeout,
                             ReceiveTimeout: Integer): BOOL; stdcall; external 'winhttp.dll';
function WinHttpCloseHandle(Handle: HINTERNET): BOOL; stdcall; external 'winhttp.dll';


function FindNode(const ANode: IXMLNode;
                    const AName: string): IXMLNode;
var
  i: Integer;

begin

  Result := nil;

  if (ANode = nil) then
    Exit;

  if SameText(ANode.LocalName,
                AName) then
    Exit(ANode);

  for i := 0 to ANode.ChildNodes.Count - 1 do
    begin

      Result := FindNode(ANode.ChildNodes[i],
                           AName);
      if (Result <> nil) then
        Exit;
    end;
end;


function NodeText(const ANode: IXMLNode;
                    const AName: string): string;
var
  Node: IXMLNode;

begin

  Result := '';
  Node := FindNode(ANode,
                     AName);

  if (Node <> nil) then
    Result := Node.Text;
end;


function FindTransportService(const ANode: IXMLNode): IXMLNode;
var
  i: Integer;

begin

  Result := nil;

  if (ANode = nil) then
    Exit;

  if SameText(ANode.LocalName,
                'service') and
     (Pos('urn:schemas-upnp-org:service:AVTransport:',
            NodeText(ANode, 'serviceType')) = 1) then
    Exit(ANode);

  for i := 0 to ANode.ChildNodes.Count - 1 do
    begin

      Result := FindTransportService(ANode.ChildNodes[i]);
      if (Result <> nil) then
        Exit;
    end;
end;


function HttpExchange(const AHost: string;
                        APort: Word;
                        const APath,
                              ABody,
                              ASoapAction: string;
                        out AStatus: DWORD): string;
var
  Session: HINTERNET;
  Connection: HINTERNET;
  Request: HINTERNET;
  Data: TMemoryStream;
  Body: UTF8String;
  Headers: string;
  Verb: string;
  Buffer: array[0..4095] of Byte;
  BytesRead: DWORD;
  Size: DWORD;

begin

  Session := nil;
  Connection := nil;
  Request := nil;
  Data := TMemoryStream.Create;

  try

    Session := WinHttpOpen('HEOSRemote/1.0',
                             1,
                             nil,
                             nil,
                             0);
    if (Session = nil) then
      RaiseLastOSError;

    if not WinHttpSetTimeouts(Session, 2500, 2500, 3000, 3000) then
      RaiseLastOSError;

    Connection := WinHttpConnect(Session,
                                    PWideChar(AHost),
                                    APort,
                                    0);
    if (Connection = nil) then
      RaiseLastOSError;

    Verb := 'GET';
    Headers := '';
    Body := UTF8Encode(ABody);

    if (ASoapAction <> '') then
      begin

        Verb := 'POST';
        Headers := 'Content-Type: text/xml; charset="utf-8"'#13#10 +
                   'SOAPACTION: "' + ASoapAction + '"'#13#10;
      end;

    Request := WinHttpOpenRequest(Connection,
                                    PWideChar(Verb),
                                    PWideChar(APath),
                                    nil,
                                    nil,
                                    nil,
                                    0);
    if (Request = nil) then
      RaiseLastOSError;

    if not WinHttpSendRequest(Request,
                                PWideChar(Headers),
                                Length(Headers),
                                PAnsiChar(Body),
                                Length(Body),
                                Length(Body),
                                0) then
      RaiseLastOSError;

    if not WinHttpReceiveResponse(Request,
                                     nil) then
      RaiseLastOSError;

    Size := SizeOf(AStatus);
    if not WinHttpQueryHeaders(Request,
                                  19 or $20000000,
                                  nil,
                                  @AStatus,
                                  Size,
                                  nil) then
      RaiseLastOSError;

    repeat

      if not WinHttpReadData(Request,
                                @Buffer[0],
                                SizeOf(Buffer),
                                BytesRead) then
        RaiseLastOSError;

      if (Data.Size + BytesRead > 1024 * 1024) then
        raise Exception.Create('Receiver UPnP response is too large.');

      if (BytesRead > 0) then
        Data.WriteBuffer(Buffer,
                            BytesRead);
    until (BytesRead = 0);

    SetLength(Body,
                Data.Size);
    if (Data.Size > 0) then
      Move(Data.Memory^,
             Body[1],
             Data.Size);

    Result := UTF8ToString(Body);
  finally

    if (Request <> nil) then
      WinHttpCloseHandle(Request);
    if (Connection <> nil) then
      WinHttpCloseHandle(Connection);
    if (Session <> nil) then
      WinHttpCloseHandle(Session);
    Data.Free;
  end;
end;


procedure ExecuteReceiverSeek(const AHost: string;
                                 const APositionMs: Int64;
                                 APort: Word);
var
  Doc: IXMLDocument;
  Service: IXMLNode;
  Body: string;
  ControlPath: string;
  ServiceType: string;
  Target: string;
  ErrorText: string;
  Seconds: Int64;
  Status: DWORD;

begin

  if (APositionMs < 0) then
    raise Exception.Create('Seek position must not be negative.');

  try

    Body := HttpExchange(AHost,
                            APort,
                            '/upnp/desc/aios_device/aios_device.xml',
                            '',
                            '',
                            Status);
    if (Status <> 200) then
      raise Exception.CreateFmt('UPnP discovery failed (HTTP %d).', [Status]);

    Doc := LoadXMLData(Body);
    Service := FindTransportService(Doc.DocumentElement);
    if (Service = nil) then
      raise Exception.Create('Receiver has no UPnP AVTransport service.');

    ControlPath := NodeText(Service,
                              'controlURL');
    ServiceType := NodeText(Service,
                              'serviceType');
    if (ControlPath = '') or (ControlPath[1] <> '/') or
       (Copy(ControlPath, 1, 2) = '//') then
      raise Exception.Create('Receiver returned an unsupported UPnP control URL.');

    Seconds := APositionMs div 1000;
    Target := Format('%.2d:%.2d:%.2d',
                       [Seconds div 3600, (Seconds div 60) mod 60, Seconds mod 60]);
    Body := '<?xml version="1.0" encoding="utf-8"?>' +
            '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" ' +
            's:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
            '<s:Body><u:Seek xmlns:u="' + ServiceType + '">' +
            '<InstanceID>0</InstanceID><Unit>REL_TIME</Unit><Target>' + Target +
            '</Target></u:Seek></s:Body></s:Envelope>';
    Body := HttpExchange(AHost,
                            APort,
                            ControlPath,
                            Body,
                            ServiceType + '#Seek',
                            Status);
    Service := nil;
    Doc := nil;

    if (Body <> '') then
      Doc := LoadXMLData(Body);

    if (Status <> 200) or (Doc = nil) or
       (FindNode(Doc.DocumentElement, 'SeekResponse') = nil) then
      begin

        ErrorText := '';
        if (Doc <> nil) then
          ErrorText := NodeText(Doc.DocumentElement, 'errorCode') + ' ' +
                       NodeText(Doc.DocumentElement, 'errorDescription');

        raise Exception.CreateFmt('Receiver seek failed (HTTP %d): %s',
                                     [Status, Trim(ErrorText)]);
      end;
  finally

    Service := nil;
    Doc := nil;
  end;
end;


procedure SeekReceiverPosition(const AHost: string;
                                 const APositionMs: Int64;
                                 APort: Word);
var
  InitResult: HRESULT;

begin

  InitResult := CoInitializeEx(nil,
                                 COINIT_APARTMENTTHREADED);
  OleCheck(InitResult);

  try

    // Release all XML interface temporaries before leaving the COM apartment.
    ExecuteReceiverSeek(AHost,
                           APositionMs,
                           APort);
  finally

    CoUninitialize;
  end;
end;
end.