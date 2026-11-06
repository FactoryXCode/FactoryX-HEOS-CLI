// FactoryX
//
// Copyright: (c) FactoryX. All rights reserved.
//
// Project: HEOS Remote.
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module:  HEOSLoopback.pas
// Kind: Pascal / Delphi unit
// Release date: 13-08-2025
// Language: ENU
//
// Revision Version: 4.0.0
// Description: Loopback capturer.
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
// captures stereo PCM and encodes the selected AAC bitrate/channel format.
unit HEOSLoopback;

interface

uses

  {WinApi}
  WinApi.Windows,
  {System}
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  {Application}
  HEOSAudioServer;

type

  THEOSLoopback = class(TThread)
  private
    FServer: THEOSAudioServer;
    FReady: TEvent;
    FError: string;
    FInitializeOnly: Boolean;
    FBitrateKbps: Integer;
    FChannels: Integer;
    FInitialized: Boolean;

  protected
    procedure Execute(); override;

  public

    constructor Create(Server: THEOSAudioServer;
                       InitializeOnly: Boolean = False;
                       ABitrateKbps: Integer = 192; AChannels: Integer = 2);
    destructor Destroy; override;

    function Ready(): Boolean;

    property Initialized: Boolean read FInitialized;
    property ErrorText: string read FError;
  end;


implementation

uses

  {WinApi}
  WinApi.WinError,
  WinApi.ComBaseApi,
  WinApi.WinApiTypes,
  WinApi.ActiveX.ObjBase,
  {System}
  System.Diagnostics,
  {MediaFoundationApi}
  WinApi.MediaFoundationApi.MfApi,
  WinApi.CoreAudioApi.MMDeviceApi,
  {CoreAudioApi}
  WinApi.CoreAudioApi.AudioClient,
  WinApi.CoreAudioApi.AudioSessionTypes,
  WinApi.WinMM.MMeApi,
  {Application}
  HEOSAacEncoder;

constructor THEOSLoopback.Create(Server: THEOSAudioServer; InitializeOnly: Boolean;
                                 ABitrateKbps: Integer; AChannels: Integer);
begin

  inherited Create(True);

  FreeOnTerminate := False;
  FServer := Server;
  FInitializeOnly := InitializeOnly;
  FBitrateKbps := ABitrateKbps;
  FChannels := AChannels;
  FReady := TEvent.Create(nil, True, False, '');
end;

destructor THEOSLoopback.Destroy;
begin

  Terminate;

  if Suspended then
    Start();

  WaitFor();
  FReady.Free;

  inherited;
end;


function THEOSLoopback.Ready(): Boolean;
begin

  Result := FReady.WaitFor(0) = wrSignaled;
end;


procedure THEOSLoopback.Execute();
var
  Enumerator: IMMDeviceEnumerator;
  Device: IMMDevice;
  Audio: IAudioClient;
  Capture: IAudioCaptureClient;
  Format: WAVEFORMATEX;
  Encoder: THEOSAacEncoder;
  Settings: TDenonAudioSettings;
  Frames: UINT32;
  Available: UINT32;
  Flags: AUDCLNT_BUFFERFLAGS;
  Data: PByte;
  Samples: TArray<Single>;
  Encoded: TBytes;
  I: Integer;
  PCM: PSmallInt;
  CoReady: Boolean;
  MfReady: Boolean;
  Running: Boolean;
  Clock: TStopwatch;
  SentFrames,
  DueFrames: Int64;

  function CheckHR(HR: HRESULT; const Operation: string): Boolean;
  begin
    Result := Succeeded(HR);
    if not Result then FError := System.SysUtils.Format('%s failed (0x%.8x)', [Operation, Cardinal(HR)]);
  end;

  function Encode(Count: Integer;
                   Silent: Boolean;
                   Buffer: PByte): Boolean;
  var
    Index: Integer;

  begin

    Result := False;
    if Count <= 0 then Exit(True);
    SetLength(Samples,
              Count * FChannels);

    if Silent then
      FillChar(Samples[0],
               Count * FChannels * SizeOf(Single),
               0)
    else
      begin
        PCM := PSmallInt(Buffer);
        if (FChannels = 1) then
          for Index := 0 to Count - 1 do
            begin
              // Average both captured channels without altering the device mix.
              Samples[Index] := PCM^ / 65536.0;
              Inc(PCM);
              Samples[Index] := Samples[Index] + PCM^ / 65536.0;
              Inc(PCM);
            end
        else
          for Index := 0 to Count * 2 - 1 do
            begin
              Samples[Index] := PCM^ / 32768.0;
              Inc(PCM);
            end;
      end;

    if not CheckHR(Encoder.EncodeInterleavedFloat32(@Samples[0],
                                                    Count,
                                                    Encoded),
                                                    'Encode AAC') then
      Exit;

    FServer.Push(Encoded);
    Inc(SentFrames,
        Count);
    Result := True;
  end;

begin

  Encoder := nil;
  CoReady := False;
  MfReady := False;
  Running := False;

  try
    try
      if not CheckHR(CoInitializeEx(nil,
                                    COINIT_MULTITHREADED),
                     'Initialize audio COM') then
        Exit;
      CoReady := True;

      if not CheckHR(MFStartup(MF_VERSION,
                     MFSTARTUP_FULL),
                     'Start Media Foundation') then
        Exit;

      MfReady := True;

      if not CheckHR(CoCreateInstance(CLSID_MMDeviceEnumerator,
                                      nil,
                                      CLSCTX_INPROC_SERVER,
                                      IID_IMMDeviceEnumerator,
                                      Enumerator),
                     'Create audio device enumerator') then Exit;

      if not CheckHR(Enumerator.GetDefaultAudioEndpoint(eRender,
                                                        eMultimedia,
                                                        Device),
                     'Find default Windows playback device') then
        Exit;

      if not CheckHR(Device.Activate(IID_IAudioClient,
                                     CLSCTX_INPROC_SERVER,
                                     nil,
                                     Pointer(Audio)),
                     'Activate WASAPI loopback') then
        Exit;

      FillChar(Format,
               SizeOf(Format),
               0);

      Format.wFormatTag := 1;
      Format.nChannels := 2;
      Format.nSamplesPerSec := 44100;
      Format.wBitsPerSample := 16;
      Format.nBlockAlign := 4;
      Format.nAvgBytesPerSec := 176400;

      if not CheckHR(Audio.Initialize(AUDCLNT_SHAREMODE_SHARED,
                                      AUDCLNT_STREAMFLAGS_LOOPBACK or
                                      AUDCLNT_STREAMFLAGS_AUTOCONVERTPCM or
                                      AUDCLNT_STREAMFLAGS_SRC_DEFAULT_QUALITY,
                                      1000000,
                                      0,
                                      @Format,
                                      nil),
                    'Initialize stereo Windows audio capture') then
        Exit;

      if not CheckHR(Audio.GetService(IID_IAudioCaptureClient,
                                      Capture),
                    'Get audio capture service') then
        Exit;

      Encoder := THEOSAacEncoder.Create();
      Settings.SampleRate := 44100;
      Settings.Channels := FChannels;
      Settings.BitrateKbps := FBitrateKbps;

      if not CheckHR(Encoder.Initialize(Settings),
                     'Initialize Windows AAC encoder') then
        Exit;

      // A diagnostic can verify the device and codec without capturing audio.
      if FInitializeOnly then
        Exit;

      if not CheckHR(Audio.Start(),
                     'Start loopback capture') then
        Exit;

      Running := True;
      FInitialized := True;
      SentFrames := 0;
      Clock := TStopwatch.StartNew();
      FReady.SetEvent();

      while not Terminated do
        begin
          if not CheckHR(Capture.GetNextPacketSize(Available),
                         'Read audio packet size') then
            Exit;

        while (Available > 0) and not Terminated do
          begin
            if not CheckHR(Capture.GetBuffer(Data,
                                             Frames,
                                             Flags,
                                             nil,
                                             nil),
                           'Read Windows audio') then
              Exit;
            try
              if (Frames > 0) then
                if not Encode(Frames,
                              ((Flags and AUDCLNT_BUFFERFLAGS_SILENT) <> 0),
                              Data) then
                  Exit;

          finally
            Capture.ReleaseBuffer(Frames);
          end;

          if not CheckHR(Capture.GetNextPacketSize(Available),
                                                   'Read next audio packet size') then
            Exit;
        end;

        // WASAPI can stop delivering packets when the output device is idle.
        // Supply paced silence so the receiver's network stream stays alive.
        DueFrames := Clock.ElapsedMilliseconds * 44100 div 1000;
        I := 0;

        while (DueFrames - SentFrames > 4410) and (I < 10) and not Terminated do
          begin
            if not Encode(1024,
                          True,
                          nil) then
              Exit;

            Inc(I);
          end;

        Sleep(5);
      end;

    except on E: Exception do
      FError := E.Message;
    end;

  finally
    if Running then
      Audio.Stop();

    Encoder.Free;
    Capture := nil;
    Audio := nil;
    Device := nil;
    Enumerator := nil;

    if MfReady then
      MFShutdown();

    if CoReady then
      CoUninitialize();

    FReady.SetEvent();
  end;
end;

end.

