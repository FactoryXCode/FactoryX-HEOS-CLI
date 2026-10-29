program HEOSRemote;

uses
  Vcl.Forms,
  HEOSTransport in 'HEOSTransport.pas',
  HEOSAudioServer in 'HEOSAudioServer.pas',
  Heos in 'Heos.pas',
  HEOSLoopback in 'HEOSLoopback.pas',
  HEOSSockets in 'HEOSSockets.pas',
  HEOSDiscovery in 'HEOSDiscovery.pas',
  HEOSPlaylist in 'HEOSPlaylist.pas',
  HEOSPlaylistForm in 'HeOsPlaylistForm.pas' {HEOSPlaylistEditor},
  HEOSRdjBridge in 'HEOSRdjBridge.pas',
  LWFileBrowserExDlg in 'LWFileBrowserExDlg.pas' {DlgLWFileBrowserEx},
  frmTagEditor in 'frmTagEditor.pas' {frmTagEditor},
  HEOSAacEncoder in 'HEOSAacEncoder.pas',
  RDJ.FilenameParser in 'RDJ.FilenameParser.pas',
  RDJ.LibraryScanner in 'RDJ.LibraryScanner.pas',
  RDJ.LibraryScanThread in 'RDJ.LibraryScanThread.pas',
  RDJ.PlaylistDb in 'RDJ.PlaylistDb.pas',
  RDJ.PlaylistManager in 'RDJ.PlaylistManager.pas',
  RDJ.PlaylistTypes in 'RDJ.PlaylistTypes.pas',
  RDJ.TagReader in 'RDJ.TagReader.pas',
  RDJ.TagWriter in 'RDJ.TagWriter.pas',
  RDJ.TrackLibrary in 'RDJ.TrackLibrary.pas',
  RDJ.TrackQuality in 'RDJ.TrackQuality.pas',
  RDJ_Common in 'RDJ_Common.pas',
  RDJ_NetWorkStationsScanner in 'RDJ_NetWorkStationsScanner.pas',
  MainForm in 'MainForm.pas' {HEOSForm};

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'HEOS Remote';
  Application.CreateForm(THEOSForm, HEOSForm);
  try
    Application.Run;
  finally
    HEOSForm.Free;
    RDJShutdownPlaylistDbFireDAC();
  end;
end.


