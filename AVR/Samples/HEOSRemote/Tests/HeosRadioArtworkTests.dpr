// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: Media Foundation - MFPack - Samples
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: HeosRadioArtworkTests.dpr
// Kind: Pascal Unit
// Release date: 30-10-2026
// Language: ENU
//
// Revision Version: 1.1.2.0
// Description: Localhost station artwork regression checks.
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
program HeosRadioArtworkTests;

{$APPTYPE CONSOLE}

uses

  System.SysUtils,
  System.Classes,
  System.Diagnostics,
  Vcl.Forms,
  Heos.Cli,
  HEOSRadioForm;

procedure Require(Value: Boolean; const Text: string);
begin

  if not Value then
    raise Exception.Create(Text);
end;

var
  Radio: THEOSRadioForm;
  Base: string;
  Clock: TStopwatch;
  Message: THeosMessage;
  LocalLogo: string;
  Item: THeosRadioItem;

procedure SelectStation(Index: Integer);
begin

  Radio.lvStations.Items[Index].Selected := True;
  Radio.SelectArtwork();
end;

procedure WaitForArtwork();
begin

  Clock := TStopwatch.StartNew;
  repeat
    Radio.PollTick(nil);
    Sleep(10);
  until (not Radio.FArtworkPending and not Assigned(Radio.FArtwork)) or
        (Clock.ElapsedMilliseconds > 6000);
  Require(not Radio.FArtworkPending and not Assigned(Radio.FArtwork),
          'Artwork did not finish: ' + Radio.lblArtworkStatus.Caption);
end;

begin

  try
    Application.Initialize;
    Base := 'http://127.0.0.1:' + ParamStr(1);
    Radio := THEOSRadioForm.Create(nil);
    try
      Message := THeosMessage.Parse('{"heos":{"command":"browse/browse","result":"success","message":"count=5"},' +
        '"payload":[' +
        '{"name":"First logo","type":"station","playable":"yes","mid":"1","image_url":"' + HeosEncode(Base + '/redirect') + '"},' +
        '{"name":"Slow logo","type":"station","playable":"yes","mid":"2","image_url":"' + HeosEncode(Base + '/slow-logo') + '"},' +
        '{"name":"Latest logo","type":"station","playable":"yes","mid":"3","image_url":"' + HeosEncode(Base + '/logo-large') + '"},' +
        '{"name":"Missing logo","type":"station","playable":"yes","mid":"4"},' +
        '{"name":"Unavailable logo","type":"station","playable":"yes","mid":"5","image_url":"' + HeosEncode(Base + '/missing') + '"}] }');
      try
        Radio.ReadItems(Message);
      finally
        Message.Free;
      end;
      Require(Assigned(Radio.imgStationArtwork) and Assigned(Radio.imgStationArtwork.Parent),
              'Artwork controls are absent from DFM');
      SelectStation(0);
      WaitForArtwork();
      Require(Assigned(Radio.imgStationArtwork.Picture.Graphic) and
              (Radio.imgStationArtwork.Picture.Width = 2) and
              (Radio.imgStationArtwork.Picture.Height = 3),
              'PNG logo without an extension / HTTP redirect did not load: ' + Radio.lblArtworkStatus.Caption);

      LocalLogo := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Local station logo.png';
      Radio.imgStationArtwork.Picture.SaveToFile(LocalLogo);
      try
        Item := Radio.FItems[0];
        Item.ImageUrl := LocalLogo;
        Radio.FItems[0] := Item;
        SelectStation(0);
        WaitForArtwork();
        Require((Radio.imgStationArtwork.Picture.Width = 2) and
                (Radio.imgStationArtwork.Picture.Height = 3),
                'Local PNG artwork did not load: ' + Radio.lblArtworkStatus.Caption);
      finally
        DeleteFile(LocalLogo);
      end;
      SelectStation(1);
      Clock := TStopwatch.StartNew;
      repeat
        Radio.PollTick(nil);
        Sleep(10);
      until Assigned(Radio.FArtwork) or (Clock.ElapsedMilliseconds > 2000);
      Require(Assigned(Radio.FArtwork), 'Slow download did not start');
      Clock := TStopwatch.StartNew;
      SelectStation(2);
      Require(Clock.ElapsedMilliseconds < 100, 'Selecting another station blocked on the old download');
      Clock := TStopwatch.StartNew;
      repeat
        Radio.PollTick(nil);
        if Assigned(Radio.imgStationArtwork.Picture.Graphic) then
          Require(Radio.imgStationArtwork.Picture.Width = 3,
                  'A late logo from the previous selection replaced the current station');
        Sleep(10);
      until (not Radio.FArtworkPending and not Assigned(Radio.FArtwork)) or
            (Clock.ElapsedMilliseconds > 6000);
      Require((Radio.imgStationArtwork.Picture.Width = 3) and
              (Radio.imgStationArtwork.Picture.Height = 2) and
              (Radio.lblSelectedStation.Caption = 'Latest logo'), 'Latest selected logo not displayed');
      SelectStation(3);
      Require(not Assigned(Radio.imgStationArtwork.Picture.Graphic) and
              not Radio.FArtworkPending and (Pos('No logo', Radio.lblArtworkStatus.Caption) > 0),
              'Missing artwork did not clear the old picture');
      SelectStation(4);
      WaitForArtwork();
      Require(not Assigned(Radio.imgStationArtwork.Picture.Graphic) and
              (Radio.lblArtworkStatus.Caption <> ''), 'HTTP logo error did not use the placeholder');
      Require(Radio.FRequest = rrNone, 'Artwork changed receiver command state');
    finally
      Radio.Free;
    end;
    Writeln('PASS receiver artwork URL, PNG/redirect, asynchronous loading, latest selection, missing logo and HTTP error fallback.');
  except
    on E: Exception do
      begin
        Writeln(E.ClassName + ': ' + E.Message);
        Halt(1);
      end;
  end;
end.
