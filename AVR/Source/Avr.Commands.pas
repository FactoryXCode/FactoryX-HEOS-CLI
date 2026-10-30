// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: FactoryX HEOS CLI
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: Avr.Commands.pas
// Kind: Pascal Unit
// Release date: 28-10-2026
// Language: ENU
//
// Revision Version: 1.0.0.1
// Description: Typed AVR control commands and reply values.
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
unit Avr.Commands;

interface

uses

  System.SysUtils;

type

  TAvrValueKind = (avUnknown,
                   avPower,
                   avMainZonePower,
                   avZone2Power,
                   avVolume,
                   avVolumeLimit,
                   avZone2Volume,
                   avMute,
                   avZone2Mute,
                   avInput,
                   avZone2Input,
                   avFrontLeft,
                   avFrontRight,
                   avToneControl,
                   avBass,
                   avTreble,
                   avSurroundMode,
                   avDynamicEq);

  TAvrValue = record
    Kind: TAvrValueKind;
    RawText: string;
    Value: string;
    HasNumber: Boolean;
    Number: Double;
    HasSwitch: Boolean;
    Enabled: Boolean;
  end;

  TAvrCommand = record
    Text: string;
    ReplyKind: TAvrValueKind;
    ExpectedValue: string;
    ExpectedPrefix: string;
    DelayMs: Integer;

    class function Raw(const AText: string;
                       const AReplyPrefix: string;
                       const AExpectedValue: string = ''): TAvrCommand; static;

    procedure Validate();
  end;

  TAvrCommands = class
  private

    class function Make(const AText: string;
                        AKind: TAvrValueKind;
                        const AExpected: string = ''): TAvrCommand; static;

  public

    class function GetPower(): TAvrCommand; static;
    class function SetPower(AEnabled: Boolean): TAvrCommand; static;
    class function GetMainZonePower(): TAvrCommand; static;
    class function SetMainZonePower(AEnabled: Boolean): TAvrCommand; static;
    class function GetZone2Power(): TAvrCommand; static;
    class function SetZone2Power(AEnabled: Boolean): TAvrCommand; static;
    class function GetVolume(AZone2: Boolean = False): TAvrCommand; static;
    
    class function SetVolume(ALevel: Double;
                             AZone2: Boolean = False): TAvrCommand; static;
    
    class function ChangeVolume(AUp: Boolean;
                                AZone2: Boolean = False): TAvrCommand; static;
    
    class function GetMute(AZone2: Boolean = False): TAvrCommand; static;
    
    class function SetMute(AEnabled: Boolean;
                           AZone2: Boolean = False): TAvrCommand; static;
    
    class function GetInput(AZone2: Boolean = False): TAvrCommand; static;
    
    class function SetInput(const AInput: string;
                            AZone2: Boolean = False): TAvrCommand; static;
    
    class function GetFrontLeft(): TAvrCommand; static;
    class function GetFrontRight(): TAvrCommand; static;
    class function SetFrontLeft(ADb: Double): TAvrCommand; static;
    class function SetFrontRight(ADb: Double): TAvrCommand; static;
    
    class function SetBalance(ADb: Double;
                              ALeftBaseDb: Double = 0;
                              ARightBaseDb: Double = 0): TArray<TAvrCommand>; static;
    
    class function GetToneControl(): TAvrCommand; static;
    class function SetToneControl(AEnabled: Boolean): TAvrCommand; static;
    class function GetBass(): TAvrCommand; static;
    class function SetBass(ADb: Integer): TAvrCommand; static;
    class function GetTreble(): TAvrCommand; static;
    class function SetTreble(ADb: Integer): TAvrCommand; static;
    class function GetSurroundMode(): TAvrCommand; static;
    class function SetSurroundMode(const AMode: string): TAvrCommand; static;
    class function GetDynamicEq(): TAvrCommand; static;
    class function SetDynamicEq(AEnabled: Boolean): TAvrCommand; static;
  end;

  function ParseAvrValue(const ALine: string): TAvrValue;
  
  function AvrLevelText(ALevel: Double;
                        AMinimum: Double;
                        AMaximum: Double): string;
  
  function TryAvrLevel(const AText: string;
                       out ALevel: Double): Boolean;


implementation

uses

  {System}
  System.Math,
  System.StrUtils;
  

function TryAvrLevel(const AText: string; 
                     out ALevel: Double): Boolean;
var
  i: Integer;
  Value: Integer;

begin

  Result := False;
  ALevel := 0;
  if not (Length(AText) in [2, 3]) then
    Exit;

  for i := 1 to Length(AText) do
    if not CharInSet(AText[i], ['0'..'9']) then
      Exit;

  if (Length(AText) = 3) and (AText[3] <> '5') then
    Exit;

  if not TryStrToInt(AText, Value) then
    Exit;

  ALevel := Value;
  if (Length(AText) = 3) then
    ALevel := ALevel / 10;
  Result := True;
end;


function AvrLevelText(ALevel: Double;
                      AMinimum: Double;
                      AMaximum: Double): string;
var
  HalfSteps: Integer;

begin

  if IsNan(ALevel) or IsInfinite(ALevel) or (ALevel < AMinimum) or (ALevel > AMaximum) then
    raise EArgumentOutOfRangeException.Create('AVR level is outside its supported range.');

  HalfSteps := Round(ALevel * 2);
  
  if (Abs(HalfSteps - ALevel * 2) > 0.000001) then
    raise EArgumentException.Create('AVR levels must use 0.5 steps.');

  Result := Format('%.2d',
                   [HalfSteps div 2]);
  
  if Odd(HalfSteps) then
    Result := Result + '5';
end;


function OnOff(AEnabled: Boolean): string;
begin

  if AEnabled then
    Result := 'ON'
  else
    Result := 'OFF';
end;


procedure CheckAscii(const AText: string;
                     AAllowEmpty: Boolean = False);
var
  i: Integer;

begin

  if ((AText = '') and not AAllowEmpty) or (Length(AText) > 128) then
    raise EArgumentException.Create('AVR text must contain 1 to 128 ASCII characters.');

  for i := 1 to Length(AText) do
    if (Ord(AText[i]) < 32) or (Ord(AText[i]) > 126) then
      raise EArgumentException.Create('AVR text contains a control or non-ASCII character.');
end;


procedure TAvrCommand.Validate();
begin

  CheckAscii(Text);
  CheckAscii(ExpectedValue,
             True);
  CheckAscii(ExpectedPrefix,
             True);
  
  if (ReplyKind = avUnknown) and (ExpectedPrefix = '') then
    raise EArgumentException.Create('A raw AVR command requires a reply prefix.');
  
  if (DelayMs < 80) or (DelayMs > 5000) then
    raise EArgumentOutOfRangeException.Create('AVR command delay must be 80 to 5000 ms.');
end;


class function TAvrCommand.Raw(const AText: string;
                               const AReplyPrefix: string;
                               const AExpectedValue: string): TAvrCommand;
begin

  Result := Default(TAvrCommand);
  Result.Text := AText;
  Result.ExpectedPrefix := AReplyPrefix;
  Result.ExpectedValue := AExpectedValue;
  Result.DelayMs := 80;
  Result.Validate();
end;


class function TAvrCommands.Make(const AText: string;
                                 AKind: TAvrValueKind;
                                 const AExpected: string): TAvrCommand;
begin

  Result := Default(TAvrCommand);
  Result.Text := AText;
  Result.ReplyKind := AKind;
  Result.ExpectedValue := AExpected;
  Result.DelayMs := 80;
  
  if (AText = 'PWON') or (AText = 'ZMON') or (AText = 'Z2ON') then
    Result.DelayMs := 1000;

  Result.Validate();
end;


class function TAvrCommands.GetPower(): TAvrCommand;
begin

  Result := Make('PW?',
                 avPower);
end;


class function TAvrCommands.SetPower(AEnabled: Boolean): TAvrCommand;
var
  Value: string;

begin

  Value := 'STANDBY';
  if AEnabled then
    Value := 'ON';
  Result := Make('PW' + Value,
                 avPower,
                 Value);
end;


class function TAvrCommands.GetMainZonePower(): TAvrCommand;
begin

  Result := Make('ZM?',
                 avMainZonePower);
end;


class function TAvrCommands.SetMainZonePower(AEnabled: Boolean): TAvrCommand;
begin

  Result := Make('ZM' + OnOff(AEnabled),
                 avMainZonePower,
                 OnOff(AEnabled));
end;


class function TAvrCommands.GetZone2Power(): TAvrCommand;
begin

  Result := Make('Z2?',
                 avZone2Power);
end;


class function TAvrCommands.SetZone2Power(AEnabled: Boolean): TAvrCommand;
begin

  Result := Make('Z2' + OnOff(AEnabled),
                 avZone2Power,
                 OnOff(AEnabled));
end;


class function TAvrCommands.GetVolume(AZone2: Boolean): TAvrCommand;
begin

  if AZone2 then
    Result := Make('Z2?',
                   avZone2Volume)
  else
    Result := Make('MV?',
                   avVolume);
end;


class function TAvrCommands.SetVolume(ALevel: Double;
                                      AZone2: Boolean): TAvrCommand;
var
  Value: string;

begin

  Value := AvrLevelText(ALevel,
                        0,
                        98);
  if AZone2 then
    Result := Make('Z2' + Value,
                   avZone2Volume,
                   Value)
  else
    Result := Make('MV' + Value,
                   avVolume,
                   Value);
end;


class function TAvrCommands.ChangeVolume(AUp: Boolean;
                                         AZone2: Boolean): TAvrCommand;
var
  Value: string;

begin

  Value := 'DOWN';
  
  if AUp then
    Value := 'UP';
  
  if AZone2 then
    Result := Make('Z2' + Value,
                   avZone2Volume)
  else
    Result := Make('MV' + Value,
                    avVolume);
end;


class function TAvrCommands.GetMute(AZone2: Boolean): TAvrCommand;
begin

  if AZone2 then
    Result := Make('Z2MU?',
                   avZone2Mute)
  else
    Result := Make('MU?',
                   avMute);
end;


class function TAvrCommands.SetMute(AEnabled: Boolean;
                                    AZone2: Boolean): TAvrCommand;
begin

  if AZone2 then
    Result := Make('Z2MU' + OnOff(AEnabled),
                   avZone2Mute,
                   OnOff(AEnabled))
  else
    Result := Make('MU' + OnOff(AEnabled),
                   avMute,
                   OnOff(AEnabled));
end;


class function TAvrCommands.GetInput(AZone2: Boolean): TAvrCommand;
begin

  if AZone2 then
    Result := Make('Z2?',
                   avZone2Input)
  else
    Result := Make('SI?',
                   avInput);
end;


class function TAvrCommands.SetInput(const AInput: string;
                                     AZone2: Boolean): TAvrCommand;
var
  Value: string;

begin

  Value := UpperCase(Trim(AInput));
  CheckAscii(Value);

  if (Pos('?',
          Value) > 0) or
     CharInSet(Value[1],
               ['0'..'9']) or
     (Value = 'ON') or
     (Value = 'OFF') or
     StartsText('MU',
                Value) then
    raise EArgumentException.Create('Invalid AVR input token.');

  if AZone2 then
    Result := Make('Z2' + Value,
                   avZone2Input,
                   Value)
  else
    Result := Make('SI' + Value,
                   avInput,
                   Value);
end;


class function TAvrCommands.GetFrontLeft(): TAvrCommand;
begin

  Result := Make('CV?',
                 avFrontLeft);
end;


class function TAvrCommands.GetFrontRight(): TAvrCommand;
begin

  Result := Make('CV?',
                 avFrontRight);
end;


class function TAvrCommands.SetFrontLeft(ADb: Double): TAvrCommand;
var
  Value: string;

begin

  Value := AvrLevelText(50 + ADb,
                        38,
                        62);
                        
  Result := Make('CVFL ' + Value,
                 avFrontLeft,
                 Value);
end;


class function TAvrCommands.SetFrontRight(ADb: Double): TAvrCommand;
var
  Value: string;

begin

  Value := AvrLevelText(50 + ADb,
                        38,
                        62);
                        
  Result := Make('CVFR ' + Value,
                 avFrontRight,
                 Value);
end;


class function TAvrCommands.SetBalance(ADb: Double;
                                       ALeftBaseDb: Double;
                                       ARightBaseDb: Double): TArray<TAvrCommand>;
var
  Left: Double;
  Right: Double;

begin

  AvrLevelText(12 + ADb,
               0,
               24);

  AvrLevelText(50 + ALeftBaseDb,
               38,
               62);

  AvrLevelText(50 + ARightBaseDb,
               38,
               62);

  Left := ALeftBaseDb;
  Right := ARightBaseDb;

  if (ADb > 0) then
    Left := Left - ADb
  else
    Right := Right + ADb;

  SetLength(Result,
            2);
            
  Result[0] := SetFrontLeft(Left);
  Result[1] := SetFrontRight(Right);
end;


class function TAvrCommands.GetToneControl(): TAvrCommand;
begin

  Result := Make('PSTONE CTRL ?',
                 avToneControl);
end;


class function TAvrCommands.SetToneControl(AEnabled: Boolean): TAvrCommand;
begin

  Result := Make('PSTONE CTRL ' + OnOff(AEnabled),
                 avToneControl,
                 OnOff(AEnabled));
end;


class function TAvrCommands.GetBass(): TAvrCommand;
begin

  Result := Make('PSBAS ?',
                 avBass);
end;


class function TAvrCommands.SetBass(ADb: Integer): TAvrCommand;
begin

  if (ADb < -6) or (ADb > 6) then
    raise EArgumentOutOfRangeException.Create('Bass must be -6 to +6 dB.');
    
  Result := Make('PSBAS ' + IntToStr(50 + ADb),
                 avBass,
                 IntToStr(50 + ADb));
end;


class function TAvrCommands.GetTreble(): TAvrCommand;
begin

  Result := Make('PSTRE ?',
                 avTreble);
end;


class function TAvrCommands.SetTreble(ADb: Integer): TAvrCommand;
begin

  if (ADb < -6) or (ADb > 6) then
    raise EArgumentOutOfRangeException.Create('Treble must be -6 to +6 dB.');
    
  Result := Make('PSTRE ' + IntToStr(50 + ADb),
                 avTreble,
                 IntToStr(50 + ADb));
end;


class function TAvrCommands.GetSurroundMode(): TAvrCommand;
begin

  Result := Make('MS?',
                 avSurroundMode);
end;


class function TAvrCommands.SetSurroundMode(const AMode: string): TAvrCommand;
var
  Value: string;

begin

  Value := UpperCase(Trim(AMode));
  CheckAscii(Value);
  
  if (Pos('?', Value) > 0) then
    raise EArgumentException.Create('A surround mode must not contain a query.');
    
  Result := Make('MS' + Value,
                 avSurroundMode, Value);
end;


class function TAvrCommands.GetDynamicEq(): TAvrCommand;
begin

  Result := Make('PSDYNEQ ?',
                 avDynamicEq);
end;


class function TAvrCommands.SetDynamicEq(AEnabled: Boolean): TAvrCommand;
begin

  Result := Make('PSDYNEQ ' + OnOff(AEnabled),
                 avDynamicEq,
                 OnOff(AEnabled));
end;


function ParseAvrValue(const ALine: string): TAvrValue;
var
  Prefix: string;
  Level: Double;
  i: Integer;
  
  const Prefixes: array[0..15] of string = ('PSTONE CTRL ',
                                            'PSDYNEQ ',
                                            'MVMAX ',
                                            'CVFL ',
                                            'CVFR ',
                                            'PSBAS ',
                                            'PSTRE ',
                                            'Z2MU',
                                            'PW',
                                            'ZM',
                                            'MV',
                                            'MU',
                                            'SI',
                                            'MS',
                                            'Z2MAX ',
                                            'Z2');
  
  const Kinds: array[0..15] of TAvrValueKind = (avToneControl,
                                                avDynamicEq,
                                                avVolumeLimit,
                                                avFrontLeft,
                                                avFrontRight,
                                                avBass,
                                                avTreble,
                                                avZone2Mute,
                                                avPower,
                                                avMainZonePower,
                                                avVolume,
                                                avMute,
                                                avInput,
                                                avSurroundMode,
                                                avUnknown,
                                                avZone2Input);

begin

  Result := Default(TAvrValue);
  Result.RawText := Trim(ALine);
  
  for i := 0 to High(Prefixes) do
    if StartsStr(Prefixes[i],
                 Result.RawText) then
      begin

        Prefix := Prefixes[i];
        Result.Kind := Kinds[i];
        Result.Value := Copy(Result.RawText,
                             Length(Prefix) + 1,
                             MaxInt);
        Break;
      end;

  if (Result.Kind = avZone2Input) then
    begin

      if (Result.Value = 'ON') or (Result.Value = 'OFF') then
        Result.Kind := avZone2Power
      else
        if TryAvrLevel(Result.Value, Level) and (Level <= 98) then
          Result.Kind := avZone2Volume;
    end;

  if Result.Kind in [avPower, avMainZonePower, avZone2Power, avMute, avZone2Mute, avToneControl, avDynamicEq] then
    begin

      Result.HasSwitch := (Result.Value = 'ON') or (Result.Value = 'OFF') or
                          ((Result.Kind = avPower) and (Result.Value = 'STANDBY'));

      Result.Enabled := (Result.Value = 'ON');

      if not Result.HasSwitch then
        Result.Kind := avUnknown;
    end;

  if Result.Kind in [avVolume, avVolumeLimit, avZone2Volume, avFrontLeft, avFrontRight, avBass, avTreble] then
    begin

      Result.HasNumber := TryAvrLevel(Result.Value,
                                      Level);
      if Result.HasNumber then
        begin

          case Result.Kind of
            avFrontLeft,
            avFrontRight: begin
                            Result.HasNumber := (Level >= 38) and (Level <= 62);
                            Level := Level - 50;
                          end;
              
            avBass,
            avTreble:     begin
                            Result.HasNumber := (Level >= 44) and (Level <= 56) and (Frac(Level) = 0);
                            Level := Level - 50;
                          end;
            else
              Result.HasNumber := (Level <= 98);
          end;
          
          Result.Number := Level;
        end;
        
      if not Result.HasNumber then
        Result.Kind := avUnknown;
    end;
end;

end.