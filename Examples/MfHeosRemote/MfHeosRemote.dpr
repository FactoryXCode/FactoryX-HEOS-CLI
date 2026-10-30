program MfHeosRemote;

uses

  Vcl.Forms,
  frmHeosRemote in 'frmHeosRemote.pas' {HeosRemoteFrm},
  MfHeosAudioServer in 'MfHeosAudioServer.pas',
  Heos.Cli in '..\..\Source\Heos.Cli.pas',
  Heos.Commands in '..\..\Source\Heos.Commands.pas',
  Heos.Sockets in '..\..\Source\Heos.Sockets.pas',
  Heos.Discovery in '..\..\Source\Heos.Discovery.pas';

begin

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'MfPack HEOS CLI Remote';
  Application.CreateForm(TfrmHeosRemote, HeosRemoteFrm);
  Application.Run;
end.