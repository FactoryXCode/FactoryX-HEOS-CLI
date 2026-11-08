"""Run AVR TCP simulator tests using Python's standard library only."""
import argparse
import pathlib
import socketserver
import subprocess
import threading
import time

commands = []
class Receiver(socketserver.StreamRequestHandler):
    def handle(self):
        data = b''
        while True:
            chunk = self.rfile.read1(4096)
            if not chunk:
                return
            assert b'\n' not in chunk, 'AVR commands must use CR, not CR/LF'
            data += chunk
            while b'\r' in data:
                raw, data = data.split(b'\r', 1)
                command = raw.decode('ascii')
                commands.append(command)
                if command == 'TESTTIMEOUT?':
                    time.sleep(.35)
                    reply = 'TESTTIMEOUTlate\r'
                elif command == 'TESTFLOOD?':
                    reply = 'SSUNKNOWN 1\r' * 5000 + 'TESTFLOODDONE\r'
                elif command == 'TESTWAIT?':
                    continue
                elif command == 'TESTREJECT?':
                    reply = '?\r'
                else:
                    reply = {
                        'PW?': 'MV475\rPWON\r',
                        'MV?': 'MV475\rMVMAX 80\r',
                        'MV815': 'MV30\rMV80\rMVMAX 80\r',
                        'Z2?': 'Z225\rZ2NET\rZ2MUOFF\rZ2OFF\r',
                        'CV?': 'CVFL 50\rCVC 50\rCVFR 50\r',
                        'PSTONE CTRL ON': 'PSBAS 50\rPSTONE CTRL ON\r',
                        'MU?': 'MUOFF\r',
                        'SI?': 'SINET\r',
                        'TESTRAW?': 'OTHER1\rTESTRAW42\r',
                    }.get(command, command + '\r')
                try:
                    encoded = reply.encode('ascii')
                    self.wfile.write(encoded[:2]); self.wfile.flush()
                    time.sleep(.005)
                    self.wfile.write(encoded[2:]); self.wfile.flush()
                except (ConnectionError, OSError):
                    return

class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--platform', choices=('Win32','Win64','both'), default='both')
args = parser.parse_args()
root = pathlib.Path(__file__).resolve().parents[2]
server = Server(('127.0.0.1', 0), Receiver)
threading.Thread(target=server.serve_forever, daemon=True).start()
try:
    targets = ('Win32','Win64') if args.platform == 'both' else (args.platform,)
    for platform in targets:
        commands.clear()
        executable = root / 'Build' / platform / 'AvrApiTests.exe'
        result = subprocess.run([str(executable), str(server.server_address[1])],
                                capture_output=True, text=True, timeout=25)
        print(platform + ':\n' + result.stdout, flush=True)
        if result.returncode:
            raise RuntimeError(result.stdout + result.stderr)
        assert 'TESTATOMIC?' not in commands, 'Invalid batch was partly sent'
        assert commands.count('TESTTIMEOUT?') == 1, 'Timed-out command was replayed'
        assert commands.count('TESTWAIT?') == 2, 'Cancellation/shutdown fixture did not execute'
finally:
    server.shutdown()
    server.server_close()