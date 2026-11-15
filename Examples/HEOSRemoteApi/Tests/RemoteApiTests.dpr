program RemoteApiTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.Diagnostics,
  Heos,
  HEOSTransport;

procedure Require(Value: Boolean; const Text: string);
begin

  if not Value then
    raise Exception.Create(Text);
end;

procedure PlayRequest(Action: THeosAction;
                          const Url: string = '');
var
  Request: THeosRequest;

begin

  Request := THeosRequest.Create('127.0.0.1', Action, Url, StrToInt(ParamStr(1)));
  try
    Request.Start;
    Request.WaitFor;
    if (Url = 'http://reject/') then
      Require(Pos('rejected', Request.ErrorText) > 0, 'HEOS rejection not returned')
    else
      Require(Request.ErrorText = '', Request.ErrorText);

    if (Action = haGetState) then
      Require(Request.PlayState = 'pause', 'Wrong HEOS state reply matched');
  finally
    Request.Free;
  end;
end;

procedure AvrRequest(const Commands: array of string;
                         Volume: Boolean = False;
                         Channels: Boolean = False;
                         Zones: Boolean = False;
                         Tone: Boolean = False;
                         Rejected: Boolean = False);
var
  Request: TDenonRequest;

begin

  Request := TDenonRequest.Create('127.0.0.1', Commands, StrToInt(ParamStr(2)),
                                    Volume, Channels, Zones, Tone);
  try
    Request.Start;
    Request.WaitFor;
    if Rejected then
      Require(Pos('rejected', Request.ErrorText) > 0, 'AVR rejection not returned')
    else
      Require(Request.ErrorText = '', Request.ErrorText);

    if Volume then
      begin
        Require(Request.Lines.IndexOf('MV80') >= 0, 'Capped AVR volume not captured');
        Require(Request.Lines.IndexOf('MVMAX 80') >= 0, 'AVR volume limit not captured');
      end;
  finally
    Request.Free;
  end;
end;

var
  Monitor: THeosProgressMonitor;
  Progress: THeosProgress;
  Timer: TStopwatch;

begin

  try
    PlayRequest(haPlayUrl, 'http://127.0.0.1/music/caf' + Char($00E9) + '.flac?x=1&name=a+b%20c');
    PlayRequest(haPause);
    PlayRequest(haResume);
    PlayRequest(haStop);
    PlayRequest(haGetState);
    PlayRequest(haPlayUrl, 'http://reject/');

    Monitor := THeosProgressMonitor.Create('127.0.0.1', StrToInt(ParamStr(1)));
    try
      Monitor.Start;
      Timer := TStopwatch.StartNew();
      repeat
        Sleep(10);
        Progress := Monitor.Snapshot();
      until (Progress.Sequence > 0) or (Timer.ElapsedMilliseconds > 5000);
      Require((Progress.PositionMs = 12345) and (Progress.DurationMs = 54321),
                 'HEOS progress event not filtered/parsed correctly');
      Timer := TStopwatch.StartNew();
      Monitor.Terminate;
      Monitor.WaitFor;
      Require(Timer.ElapsedMilliseconds < 2000, 'Progress shutdown blocked');
    finally
      Monitor.Free;
    end;

    AvrRequest(['PW?', 'ZM?', 'Z2?', 'MV?', 'MU?', 'SI?']);
    AvrRequest(['MV815', 'MV?'], True);
    AvrRequest(['CVFL 495', 'CVFR 50', 'CV?'], False, True);
    AvrRequest(['ZMON', 'Z2OFF', 'ZM?', 'Z2?'], False, False, True);
    AvrRequest(['PSTONE CTRL OFF', 'PSBAS 49', 'PSTRE 52', 'MS?', 'PSDYNEQ ?',
                  'PSTONE CTRL ?', 'PSBAS ?', 'PSTRE ?'], False, False, False, True);
    AvrRequest(['PSTONE CTRL ON', 'PSBAS 51'], False, False, False, False, True);
    Writeln('PASS HEOS playback, state, URL encoding, rejection, player selection, progress and shutdown; AVR status, capped volume, balance, zones, tone and rejection.');
  except
    on E: Exception do
      begin
        Writeln(E.ClassName + ': ' + E.Message);
        Halt(1);
      end;
  end;
end.
