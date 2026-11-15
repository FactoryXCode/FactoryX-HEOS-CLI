"""Build and test Tone recovery with a local AVR simulator; no real receiver is used."""
from pathlib import Path
import argparse
import os
import socketserver
import subprocess
import threading

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

# Follow the radio tests: private state is exposed only in test fixture copies.
text = (sample / 'MainForm.pas').read_text(encoding='utf-8-sig').replace('  private', '  public')
start = text.index('function THEOSForm.CreateReceiverRequest(')
end = text.index('destructor THEOSForm.Destroy', start)
factory = text[start:end].replace(
    '  Allowed := TList<string>.Create;',
    "  Port := StrToIntDef(GetEnvironmentVariable('HEOS_TONE_TEST_PORT'), Port);\n"
    '  Allowed := TList<string>.Create;', 1)
assert factory != text[start:end]
text = text[:start] + factory + text[end:]
(fixture / 'MainForm.pas').write_bytes(text.replace('\n', '\r\n').encode())
(fixture / 'MainForm.dfm').write_bytes((sample / 'MainForm.dfm').read_bytes())
text = (sample / 'HEOSTransport.pas').read_text(encoding='utf-8-sig').replace('  private', '  public')
(fixture / 'HEOSTransport.pas').write_bytes(text.replace('\n', '\r\n').encode())
bds = Path(options.delphi_root)
api = Path(options.heos_cli_root)
avr = Path(options.avr_source_path) if options.avr_source_path else api / 'AVR/Source'

class Receiver(socketserver.StreamRequestHandler):
    def handle(self):
        data = b''
        ignore = False
        while True:
            chunk = self.rfile.read1(4096)
            if not chunk:
                return
            data += chunk
            while b'\r' in data:
                raw, data = data.split(b'\r', 1)
                command = raw.decode('ascii')
                self.server.commands.append(command)
                reply = ''
                if command in ('ZMON', 'ZMOFF'):
                    self.server.power = command == 'ZMON'
                    reply = command
                elif command == 'ZM?':
                    reply = 'ZMON' if self.server.power else 'ZMOFF'
                elif command == 'Z2?':
                    reply = 'Z2OFF'
                elif command in ('PSTONE CTRL ON', 'PSTONE CTRL OFF'):
                    self.server.tone = command.endswith(' ON')
                    if command.endswith(' ON') and not self.server.write_dropped:
                        self.server.write_dropped = True
                        ignore = True
                    if not ignore:
                        reply = command
                elif command == 'MS?':
                    if not self.server.read_dropped:
                        self.server.read_dropped = True
                        ignore = True
                    if not ignore:
                        reply = 'MSSTEREO'
                elif not ignore:
                    reply = {
                        'PSDYNEQ ?': 'PSDYNEQ OFF',
                        'PSTONE CTRL ?': 'PSTONE CTRL ON' if self.server.tone else 'PSTONE CTRL OFF',
                        'PSBAS ?': 'PSBAS 50',
                        'PSTRE ?': 'PSTRE 50',
                    }.get(command, '')
                if reply:
                    try:
                        self.wfile.write((reply + '\r').encode())
                        self.wfile.flush()
                    except (ConnectionError, OSError):
                        return

class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True

for platform in ('win32', 'win64'):
    target = output / platform
    dcu = target / 'dcu'
    dcu.mkdir(parents=True, exist_ok=True)
    profile = target / 'Profile'
    profile.mkdir(exist_ok=True)
    paths = [fixture, sample, sample / 'Controls', api / 'Source', avr,
             Path(options.mfpack_root) / 'src', bds / 'lib' / platform / 'release']
    command = [str(bds / 'bin' / ('dcc32.exe' if platform == 'win32' else 'dcc64.exe')),
               '-B', '-Q', '-NSSystem;Winapi;Vcl;Vcl.Imaging;Data;Xml;System.Win;Data.Win;Xml.Win',
               '-U' + ';'.join(map(str, paths)), '-N0' + str(dcu), '-E' + str(target),
               str(sample / 'Tests/HeosToneRecoveryTests.dpr')]
    result = subprocess.run(command, cwd=fixture, capture_output=True, text=True)
    print(platform, result.stdout, result.stderr, flush=True)
    if result.returncode:
        raise RuntimeError('Tone regression test compilation failed')
    with Server(('127.0.0.1', 0), Receiver) as receiver:
        receiver.commands = []
        receiver.power = True
        receiver.tone = False
        receiver.read_dropped = False
        receiver.write_dropped = False
        threading.Thread(target=receiver.serve_forever, daemon=True).start()
        env = os.environ.copy()
        env['HEOS_TONE_TEST_PORT'] = str(receiver.server_address[1])
        env['LOCALAPPDATA'] = env['APPDATA'] = str(profile)
        result = subprocess.run([str(target / 'HeosToneRecoveryTests.exe')],
                                capture_output=True, text=True, env=env, timeout=35)
        print(platform, result.stdout, result.stderr, flush=True)
        receiver.shutdown()
        if result.returncode:
            raise RuntimeError('Tone recovery checks failed: ' + repr(receiver.commands))
        assert receiver.read_dropped and receiver.write_dropped, 'Transient failures were not exercised'
        assert receiver.commands.count('PSTONE CTRL ON') == 1, 'Uncertain Tone On command was replayed'
        assert receiver.commands.count('PSTONE CTRL OFF') == 1, 'Tone Off was omitted or replayed'
        first_write = receiver.commands.index('PSTONE CTRL ON')
        assert receiver.commands[:first_write].count('PSTONE CTRL ?') == 2, 'Tone write preceded successful recovery read'
        print(platform + ': PASS read-only retries; no automatic replay of Tone writes.', flush=True)
