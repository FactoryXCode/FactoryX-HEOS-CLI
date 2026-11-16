// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: HEOS Remote.
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: Heos.Files.pas
// Kind: Pascal Unit
// Release date: 24-01-2026
// Language: ENU
//
// Revision Version: 4.1.0
// Description: Checked INI persistence for live HEOS controls.
//
// Company: FactoryX
// Intiator(s): Tony (maXcomX), Carmen (carmenh).
// Contributor(s): Tony Kalf (maXcomX), Carmen (carmenh).
//
//------------------------------------------------------------------------------
// CHANGE LOG
// Date       Person              Reason
// ---------- ------------------- ----------------------------------------------
// 15/11/2026 All                 Eels release  SDK 10.0.28000.2705 (Windows 11)
//------------------------------------------------------------------------------
//
// Remarks: Requires Windows 10 or higher.
//          Please, read documentation carefully!
//
// Related objects: -
// Related projects: MfPackX410
// Known Issues: -
//
// Compiler version: 23 up to 35
// SDK version: 10.0.28000.2705
//
// Todo: -
//
// =============================================================================
// Source: FactoryX.Code
//         HARMAN International (HEOS_CLI_ProtocolSpecification-Version-1.17)
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
unit Heos.Files;

interface
uses System.Classes, System.SysUtils, System.IniFiles;

// INI persistence for live controls: OS failures return status, never a dialog.
function TryLoadHeosIni(const FileName: string; Ini: TMemIniFile; out ErrorText: string): Boolean;
function TrySaveHeosIni(const FileName: string; Ini: TMemIniFile; out ErrorText: string;
  Encoding: TEncoding = nil): Boolean;

implementation
uses WinApi.Windows;

function FileError(const Operation: string): string;
begin
  Result := Format('%s (Windows error %d)', [Operation, GetLastError]);
end;

function TryLoadHeosIni(const FileName: string; Ini: TMemIniFile; out ErrorText: string): Boolean;
var Handle: THandle; Size, ReadCount: DWORD; HighSize: DWORD;
  Bytes: TBytes; Text: string; Lines: TStringList; Error: DWORD;
begin
  Result := False;
  ErrorText := '';
  Handle := CreateFile(PChar(FileName), GENERIC_READ,
                       FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE,
                       nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if Handle = INVALID_HANDLE_VALUE then
    begin
      Error := GetLastError;
      if (Error = ERROR_FILE_NOT_FOUND) or (Error = ERROR_PATH_NOT_FOUND) then Exit(True);
      ErrorText := Format('Cannot read HEOS settings (Windows error %d)', [Error]);
      Exit;
    end;
  try
    HighSize := 0;
    Size := GetFileSize(Handle, @HighSize);
    if (Size = INVALID_FILE_SIZE) or (HighSize <> 0) or (Size > 8 * 1024 * 1024) then
      begin ErrorText := 'Cannot read HEOS settings: file is invalid or exceeds 8 MB'; Exit; end;
    SetLength(Bytes, Size);
    if Size > 0 then
      begin
        if not ReadFile(Handle, Bytes[0], Size, ReadCount, nil) then
          begin ErrorText := FileError('Cannot read HEOS settings'); Exit; end;
        if ReadCount <> Size then
          begin ErrorText := 'HEOS settings changed while reading'; Exit; end;
      end;
    if (Size >= 3) and (Bytes[0] = $EF) and (Bytes[1] = $BB) and (Bytes[2] = $BF) then
      Text := TEncoding.UTF8.GetString(Bytes, 3, Size - 3)
    else if (Size >= 2) and (Bytes[0] = $FF) and (Bytes[1] = $FE) then
      Text := TEncoding.Unicode.GetString(Bytes, 2, Size - 2)
    else if (Size >= 2) and (Bytes[0] = $FE) and (Bytes[1] = $FF) then
      Text := TEncoding.BigEndianUnicode.GetString(Bytes, 2, Size - 2)
    else
      Text := TEncoding.Default.GetString(Bytes);
    Lines := TStringList.Create;
    try
      Lines.Text := Text;
      Ini.SetStrings(Lines);
    finally Lines.Free; end;
    Result := True;
  finally CloseHandle(Handle); end;
end;

function TrySaveHeosIni(const FileName: string; Ini: TMemIniFile; out ErrorText: string; Encoding: TEncoding): Boolean;
var Handle: THandle; Lines: TStringList; Bytes, Preamble: TBytes;
  Written: DWORD; TempName: string; Id: TGUID; Committed: Boolean;
begin
  Result := False;
  ErrorText := '';
  if Encoding = nil then Encoding := TEncoding.UTF8;
  if FileName = '' then
    begin ErrorText := 'HEOS settings filename is empty'; Exit; end;
  if not ForceDirectories(ExtractFilePath(ExpandFileName(FileName))) then
    begin ErrorText := 'Cannot create HEOS settings directory'; Exit; end;
  Lines := TStringList.Create;
  try
    Ini.GetStrings(Lines);
    Bytes := Encoding.GetBytes(Lines.Text);
  finally Lines.Free; end;
  CreateGUID(Id);
  TempName := FileName + '.' + GUIDToString(Id) + '.tmp';
  Handle := CreateFile(PChar(TempName), GENERIC_WRITE, 0, nil, CREATE_NEW,
                       FILE_ATTRIBUTE_NORMAL, 0);
  if Handle = INVALID_HANDLE_VALUE then
    begin ErrorText := FileError('Cannot create HEOS settings file'); Exit; end;
  Committed := False;
  try
    try
      Preamble := Encoding.GetPreamble;
      if Length(Preamble) > 0 then
        if not WriteFile(Handle, Preamble[0], Length(Preamble), Written, nil) or
           (Written <> DWORD(Length(Preamble))) then
          begin ErrorText := FileError('Cannot write HEOS settings'); Exit; end;
      if Length(Bytes) > 0 then
        if not WriteFile(Handle, Bytes[0], Length(Bytes), Written, nil) or
           (Written <> DWORD(Length(Bytes))) then
          begin ErrorText := FileError('Cannot write HEOS settings'); Exit; end;
      if not FlushFileBuffers(Handle) then
        begin ErrorText := FileError('Cannot flush HEOS settings'); Exit; end;
    finally CloseHandle(Handle); end;
    if not MoveFileEx(PChar(TempName), PChar(FileName), MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH) then
      begin ErrorText := FileError('Cannot replace HEOS settings'); Exit; end;
    Committed := True;
    Result := True;
  finally
    if not Committed then WinApi.Windows.DeleteFile(PChar(TempName));
  end;
end;
end.
