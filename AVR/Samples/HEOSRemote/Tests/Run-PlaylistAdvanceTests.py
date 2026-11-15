"""Check playlist auto-advance using completed test replies; no receiver is contacted."""
from pathlib import Path
import argparse
import os
import subprocess
import wave

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--mfpack-root', required=True)
parser.add_argument('--heos-cli-root', required=True)
parser.add_argument('--avr-source-path')
parser.add_argument('--delphi-root', default=r'C:\Program Files (x86)\Embarcadero\Studio\15.0')
parser.add_argument('--output-root', required=True)
options = parser.parse_args()
sample = Path(__file__).resolve().parent.parent
output = Path(options.output_root).resolve()
fixture = output / 'Fixture'
fixture.mkdir(parents=True, exist_ok=True)
for name in ('MainForm.pas', 'Heos.pas'):
    text = (sample / name).read_text(encoding='utf-8-sig').replace('  private', '  public')
    (fixture / name).write_bytes(text.replace('\n', '\r\n').encode())
(fixture / 'MainForm.dfm').write_bytes((sample / 'MainForm.dfm').read_bytes())
audio = output / 'Audio'
audio.mkdir(exist_ok=True)
for number in range(1, 5):
    with wave.open(str(audio / f'{number}.wav'), 'wb') as target:
        target.setparams((2, 2, 44100, 0, 'NONE', 'not compressed'))
        target.writeframes(b'\0' * 44100 * 4)
bds = Path(options.delphi_root)
api = Path(options.heos_cli_root)
avr = Path(options.avr_source_path) if options.avr_source_path else api / 'AVR/Source'
for platform in ('win32', 'win64'):
    target = output / platform
    dcu = target / 'dcu'
    dcu.mkdir(parents=True, exist_ok=True)
    profile = target / 'Profile'
    profile.mkdir(exist_ok=True)
    paths = [fixture, sample, sample / 'Controls', api / 'Source', api / 'AVR/Source', avr,
             Path(options.mfpack_root) / 'src', bds / 'lib' / platform / 'release']
    command = [str(bds / 'bin' / ('dcc32.exe' if platform == 'win32' else 'dcc64.exe')),
               '-B', '-Q', '-NSSystem;Winapi;Vcl;Vcl.Imaging;Data;Xml;System.Win;Data.Win;Xml.Win',
               '-U' + ';'.join(map(str, paths)), '-N0' + str(dcu), '-E' + str(target),
               str(sample / 'Tests/HeosPlaylistAdvanceTests.dpr')]
    result = subprocess.run(command, cwd=fixture, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)
    env = os.environ.copy()
    env['LOCALAPPDATA'] = env['APPDATA'] = str(profile)
    result = subprocess.run([str(target / 'HeosPlaylistAdvanceTests.exe'), str(audio)],
                            capture_output=True, text=True, env=env, timeout=40)
    print(platform, result.stdout, result.stderr, flush=True)
    if result.returncode:
        raise RuntimeError('Playlist advancement regression failed')
