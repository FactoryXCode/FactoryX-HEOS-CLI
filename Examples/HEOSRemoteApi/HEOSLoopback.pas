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
// requests a stereo PCM format for the RDJ-derived AAC encoder.
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
    FInitialized: Boolean;

  protected
    procedure Execute(); override;

  public

    constructor Create(Server: THEOSAudioServer;
                       InitializeOnly: Boolean = False);
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

procedure CheckHR(HR: HRESULT; const Operation: string);
begin

  if Failed(HR) then
    raise Exception.CreateFmt('%s failed (0x%.8x)',
                              [Operation, Cardinal(HR)]);
end;

constructor THEOSLoopback.Create(Server: THEOSAudioServer; InitializeOnly: Boolean);
begin

  inherited Create(True);

  FreeOnTerminate := False;
  FServer := Server;
  FInitializeOnly := InitializeOnly;
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

  procedure Encode(Count: Integer;
                   Silent: Boolean;
                   Buffer: PByte);
  var
    Index: Integer;

  begin

    SetLength(Samples,
              Count * 2);

    if Silent then
      FillChar(Samples[0],
               Count * 2 * SizeOf(Single),
               0)
    else
      begin
        PCM := PSmallInt(Buffer);
        for Index := 0 to Count * 2 - 1 do
        begin
          Samples[Index] := PCM^ / 32768.0;
          Inc(PCM);
        end;
      end;

    CheckHR(Encoder.EncodeInterleavedFloat32(@Samples[0],
                                             Count,
                                             Encoded),
           'Encode AAC');

    FServer.Push(Encoded);
    Inc(SentFrames,
        Count);
  end;

begin

  Encoder := nil;
  CoReady := False;
  MfReady := False;
  Running := False;

  try
    try
      CheckHR(CoInitializeEx(nil,
                             COINIT_MULTITHREADED),
              'Initialize audio COM');
      CoReady := True;

      CheckHR(MFStartup(MF_VERSION,
                        MFSTARTUP_FULL),
             'Start Media Foundation');
      MfReady := True;

      CheckHR(CoCreateInstance(CLSID_MMDeviceEnumerator,
                               nil,
                               CLSCTX_INPROC_SERVER,
                               IID_IMMDeviceEnumerator,
                               Enumerator),
             'Create audio device enumerator');

      CheckHR(Enumerator.GetDefaultAudioEndpoint(eRender,
                                                 eMultimedia,
                                                 Device),
              'Find default Windows playback device');

      CheckHR(Device.Activate(IID_IAudioClient,
                              CLSCTX_INPROC_SERVER,
                              nil,
                              Pointer(Audio)),
              'Activate WASAPI loopback');

      FillChar(Format,
               SizeOf(Format),
               0);

      Format.wFormatTag := 1;
      Format.nChannels := 2;
      Format.nSamplesPerSec := 44100;
      Format.wBitsPerSample := 16;
      Format.nBlockAlign := 4;
      Format.nAvgBytesPerSec := 176400;

      CheckHR(Audio.Initialize(AUDCLNT_SHAREMODE_SHARED,
                               AUDCLNT_STREAMFLAGS_LOOPBACK or
                               AUDCLNT_STREAMFLAGS_AUTOCONVERTPCM or
                               AUDCLNT_STREAMFLAGS_SRC_DEFAULT_QUALITY,
                               1000000,
                               0,
                               @Format,
                               nil),
             'Initialize stereo Windows audio capture');

      CheckHR(Audio.GetService(IID_IAudioCaptureClient,
                               Capture),
              'Get audio capture service');

      Encoder := THEOSAacEncoder.Create();
      Settings.SampleRate := 44100;
      Settings.Channels := 2;
      Settings.BitrateKbps := 192;

      CheckHR(Encoder.Initialize(Settings),
              'Initialize Windows AAC encoder');

      // A diagnostic can verify the device and codec without capturing audio.
      if FInitializeOnly then
        Exit;

      CheckHR(Audio.Start(),
              'Start loopback capture');
      Running := True;
      FInitialized := True;
      SentFrames := 0;
      Clock := TStopwatch.StartNew();
      FReady.SetEvent();

      while not Terminated do
        begin
          CheckHR(Capture.GetNextPacketSize(Available),
                  'Read audio packet size');

        while (Available > 0) and not Terminated do
          begin
            CheckHR(Capture.GetBuffer(Data,
                                      Frames,
                                      Flags,
                                      nil,
                                      nil),
                    'Read Windows audio');
            try
              if (Frames > 0) then
                Encode(Frames,
                       ((Flags and AUDCLNT_BUFFERFLAGS_SILENT) <> 0),
                       Data);

          finally
            Capture.ReleaseBuffer(Frames);
          end;

          CheckHR(Capture.GetNextPacketSize(Available),
                  'Read next audio packet size');
        end;

        // WASAPI can stop delivering packets when the output device is idle.
        // Supply paced silence so the receiver's network stream stays alive.
        DueFrames := Clock.ElapsedMilliseconds * 44100 div 1000;
        I := 0;

        while (DueFrames - SentFrames > 4410) and (I < 10) and not Terminated do
          begin
            Encode(1024,
                   True,
                   nil);

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
      CoUninitialize;

    FReady.SetEvent();
  end;
end;

end.

