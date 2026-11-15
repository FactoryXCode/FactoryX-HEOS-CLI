// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: HEOS Remote.
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HeosAacSettingsTests.dpr
// Kind: Pascal Unit
// Release date: 24-01-2026
// Language: ENU
//
// Revision Version: 4.0.0
// Description: Split out from MfIcecastBroadcastEngine.
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
// Source: FactoryX.Code / MfPack
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

program HeosAacSettingsTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.Math, System.IniFiles,
  WinApi.Windows, WinApi.ComBaseApi, WinApi.ActiveX.ObjBase,
  WinApi.MediaFoundationApi.MfApi,
  Vcl.Forms, HEOSAacEncoder, HEOSLoopback, MainForm;

procedure Require(Condition: Boolean; const MessageText: string);
begin
  if not Condition then
    raise Exception.Create(MessageText);
end;

procedure CheckAdts(const Bytes: TBytes; Rate, Channels: Integer;
                    var PacketCount: Integer);
var
  Offset, PacketSize, FrequencyIndex: Integer;
begin
  Offset := 0;
  if Rate = 44100 then FrequencyIndex := 4 else FrequencyIndex := 3;
  while Offset < Length(Bytes) do
    begin
      Require(Length(Bytes) - Offset >= 7, 'Truncated ADTS header');
      Require((Bytes[Offset] = $FF) and ((Bytes[Offset + 1] and $F6) = $F0), 'Invalid ADTS sync');
      Require((Bytes[Offset + 2] shr 6) = 1, 'Expected AAC-LC');
      Require(((Bytes[Offset + 2] shr 2) and $F) = FrequencyIndex, 'Wrong sample rate');
      Require((((Bytes[Offset + 2] and 1) shl 2) or (Bytes[Offset + 3] shr 6)) = Channels, 'Wrong channel configuration');
      PacketSize := ((Bytes[Offset + 3] and 3) shl 11) or
                    (Bytes[Offset + 4] shl 3) or (Bytes[Offset + 5] shr 5);
      Require((PacketSize >= 7) and (Offset + PacketSize <= Length(Bytes)), 'Invalid ADTS packet length');
      Inc(PacketCount);
      Inc(Offset, PacketSize);
    end;
end;

procedure CheckEncoder;
const
  Rates: array[0..1] of Integer = (44100, 48000);
  Bitrates: array[0..3] of Integer = (96, 128, 160, 192);
var
  Encoder: THEOSAacEncoder;
  Settings: TDenonAudioSettings;
  Samples: array[0..2047] of Single;
  Bytes: TBytes;
  R, B, C, I, Block, Packets: Integer;
begin
  Encoder := THEOSAacEncoder.Create;
  try
    for R := 0 to High(Rates) do
      for B := 0 to High(Bitrates) do
        for C := 1 to 2 do
          begin
            Settings.SampleRate := Rates[R];
            Settings.BitrateKbps := Bitrates[B];
            Settings.Channels := C;
            Require(Succeeded(Encoder.Initialize(Settings)), 'Encoder rejected offered format');
            Packets := 0;
            for Block := 0 to 15 do
              begin
                for I := 0 to 1024 * C - 1 do
                  Samples[I] := 0.25 * Sin((Block * 1024 + I div C) * 2 * Pi * 440 / Settings.SampleRate);
                Require(Succeeded(Encoder.EncodeInterleavedFloat32(@Samples[0], 1024, Bytes)), 'Encoding failed');
                CheckAdts(Bytes, Settings.SampleRate, C, Packets);
              end;
            Encoder.Flush(Bytes);
            CheckAdts(Bytes, Settings.SampleRate, C, Packets);
            Require(Packets >= 15, 'Missing AAC output');
            Writeln('PASS ', Settings.SampleRate, ' Hz / ', Settings.BitrateKbps, ' kbps / ', C, ' channels');
          end;
    Settings.BitrateKbps := 320;
    Require(Failed(Encoder.Initialize(Settings)), 'Unsupported bitrate accepted');
    Require(Failed(Encoder.EncodeInterleavedFloat32(@Samples[0], 1024, Bytes)), 'Rejected initialization left encoder active');
    Settings.BitrateKbps := 192;
    Settings.Channels := 3;
    Require(Failed(Encoder.Initialize(Settings)), 'Unsupported channels accepted');
    Settings.Channels := 2;
    Settings.SampleRate := 22050;
    Require(Failed(Encoder.Initialize(Settings)), 'Unsupported sample rate accepted');
  finally
    Encoder.Free;
  end;
end;

type
  TNoCaptureLoopback = class(THEOSLoopback)
  protected
    procedure Execute; override;
  end;

procedure TNoCaptureLoopback.Execute;
begin
  // The UI state checks must not capture the user's audio.
end;

procedure CheckSetup;
var
  Form: THEOSForm;
  Ini: TMemIniFile;
  Settings: TDenonAudioSettings;
  FileName, OriginalHost: string;
  ChangeEvent: TMethod;
begin
  FileName := IncludeTrailingPathDelimiter(GetEnvironmentVariable('LOCALAPPDATA')) +
              'FactoryX\HEOSRemote\Receiver.ini';
  ForceDirectories(ExtractFilePath(FileName));
  System.SysUtils.DeleteFile(FileName);
  Form := THEOSForm.Create(nil);
  try
    Require(Form.TryReadAacSettings(Settings) and (Settings.BitrateKbps = 192) and
            (Settings.Channels = 2), 'Wrong AAC defaults');
    OriginalHost := Form.edHost.Text;
    ChangeEvent := TMethod(Form.ComboBox1.OnChange);
    Require(ChangeEvent.Code = @THEOSForm.AacSettingsChange, 'Bitrate event still changes receiver');
    ChangeEvent := TMethod(Form.ComboBox2.OnChange);
    Require(ChangeEvent.Code = @THEOSForm.AacSettingsChange, 'Channel event still changes receiver');
    Form.ComboBox1.ItemIndex := 0;
    Form.ComboBox2.ItemIndex := 1;
    Require(Form.TryReadAacSettings(Settings) and (Settings.BitrateKbps = 96) and
            (Settings.Channels = 1), 'Could not parse existing item strings');
    Form.AacSettingsChange(nil);
    Require(Form.edHost.Text = OriginalHost, 'AAC choice changed receiver IP');
    Ini := TMemIniFile.Create(FileName);
    try
      Require(Ini.ReadInteger('AAC', 'BitrateKbps', 0) = 96, 'Unconnected bitrate not saved');
      Require(Ini.ReadInteger('AAC', 'Channels', 0) = 1, 'Unconnected channels not saved');
      Require(not Ini.ValueExists('Receiver', 'Host'), 'Unverified receiver was saved');
      Ini.WriteString('Receiver', 'Host', '192.0.2.1');
      Ini.UpdateFile;
    finally
      Ini.Free;
    end;
    Form.ComboBox1.ItemIndex := 3;
    Form.ComboBox2.ItemIndex := 0;
    Form.LoadReceiverSettings;
    Require(Form.TryReadAacSettings(Settings) and (Settings.BitrateKbps = 96) and
            (Settings.Channels = 1), 'Saved settings did not restore');
    Form.ComboBox1.Text := 'invalid';
    Require(not Form.TryReadAacSettings(Settings), 'Invalid bitrate accepted');
    Form.AacSettingsChange(nil);
    Form.ComboBox1.Text := '128 Kbps';
    Form.ComboBox2.Text := 'Surround';
    Require(not Form.TryReadAacSettings(Settings), 'Invalid channel text accepted');
    Form.LoadReceiverSettings;
    Ini := TMemIniFile.Create(FileName);
    try
      Require(Ini.ReadInteger('AAC', 'BitrateKbps', 0) = 96, 'Typing overwrote valid AAC preference');
      Require(Ini.ReadString('Receiver', 'Host', '') = '192.0.2.1', 'AAC preference overwrote confirmed host');
      Ini.WriteInteger('AAC', 'BitrateKbps', 320);
      Ini.WriteInteger('AAC', 'Channels', 6);
      Ini.UpdateFile;
    finally
      Ini.Free;
    end;
    Form.LoadReceiverSettings;
    Require(Form.TryReadAacSettings(Settings) and (Settings.BitrateKbps = 192) and
            (Settings.Channels = 2), 'Invalid saved settings not defaulted');
    Form.FWaitingForCapture := True;
    Form.UpdateStreamButtons;
    Require(not Form.ComboBox1.Enabled and not Form.ComboBox2.Enabled, 'Controls enabled while capture starts');
    Form.FWaitingForCapture := False;
    Form.FLoopback := TNoCaptureLoopback.Create(nil, True, 96, 1);
    Form.UpdateStreamButtons;
    Require(not Form.ComboBox1.Enabled and not Form.ComboBox2.Enabled, 'Controls enabled while streaming');
    FreeAndNil(Form.FLoopback);
    Form.UpdateStreamButtons;
    Require(Form.ComboBox1.Enabled and Form.ComboBox2.Enabled, 'Controls disabled after stop');
    Writeln('PASS existing DFM, event wiring, item parsing, persistence, invalid input and stream locking');
  finally
    Form.Free;
    System.SysUtils.DeleteFile(FileName);
  end;
end;

begin
  try
    Require(Succeeded(CoInitializeEx(nil, COINIT_APARTMENTTHREADED)), 'COM startup failed');
    try
      Require(Succeeded(MFStartup(MF_VERSION, MFSTARTUP_FULL)), 'MF startup failed');
      try
        CheckEncoder;
        CheckSetup;
      finally
        MFShutdown;
      end;
    finally
      CoUninitialize;
    end;
    Writeln('All HEOS AAC settings checks passed.');
  except
    on E: Exception do
      begin
        Writeln(E.ClassName, ': ', E.Message);
        Halt(1);
      end;
  end;
end.