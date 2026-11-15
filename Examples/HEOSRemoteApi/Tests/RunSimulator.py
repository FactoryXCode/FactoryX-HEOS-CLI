"""Exercise the full sample's API adapters using local HEOS and AVR simulators."""
import argparse
import json
from pathlib import Path
import socketserver
import subprocess
import threading
import time
import urllib.parse

commands=[]
errors=[]

class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address=True
    daemon_threads=True

class HeosReceiver(socketserver.StreamRequestHandler):
    def send(self, command, message='', payload=None, result='success'):
        root={'heos':{'command':command,'result':result,'message':message}}
        if payload is not None:
            root['payload']=payload
        self.wfile.write((json.dumps(root)+'\r\n').encode())
        self.wfile.flush()

    def handle(self):
        try:
            while True:
                line=self.rfile.readline()
                if not line:
                    return
                wire=line.decode().strip()
                url=urllib.parse.urlsplit(wire)
                command=url.netloc+url.path
                # HEOS percent-decodes values and preserves literal plus signs.
                params={urllib.parse.unquote(k):urllib.parse.unquote(v)
                        for k,v in (part.split('=',1) for part in url.query.split('&') if '=' in part)}
                commands.append((command,params))
                if command=='player/get_players':
                    self.send(command,payload=[{'pid':777,'ip':'127.0.0.99'}, {'pid':-42,'ip':'127.0.0.1'}])
                elif command=='player/get_play_state':
                    self.send('player/get_volume','pid=-42&level=30')
                    self.send(command,'pid=-42&state=pause')
                elif command=='browse/play_stream':
                    assert params['pid']=='-42', 'Wrong HEOS player selected'
                    if params['url']=='http://reject/':
                        self.send(command,'eid=2&text=rejected',result='fail')
                    else:
                        assert params['url']=='http://127.0.0.1/music/caf\u00e9.flac?x=1&name=a+b%20c', params
                        self.send(command,'pid=-42')
                elif command=='system/register_for_change_events':
                    self.send(command,'enable=on')
                    time.sleep(.2)
                    self.send('event/player_now_playing_progress','pid=777&cur_pos=999&duration=999')
                    self.send('event/player_now_playing_progress','pid=-42&cur_pos=bad&duration=54321')
                    self.send('event/player_now_playing_progress','pid=-42&cur_pos=12345&duration=54321')
                else:
                    assert command=='player/set_play_state', wire
                    assert params['pid']=='-42', params
                    self.send(command,'pid=-42&state='+params['state'])
        except (ConnectionError,OSError):
            pass
        except Exception as e:
            errors.append(str(e))

class AvrReceiver(socketserver.StreamRequestHandler):
    def handle(self):
        data=b''
        try:
            while True:
                chunk=self.rfile.read1(4096)
                if not chunk:
                    return
                assert b'\n' not in chunk, 'AVR framing changed'
                data+=chunk
                while b'\r' in data:
                    raw,data=data.split(b'\r',1)
                    cmd=raw.decode()
                    commands.append(cmd)
                    reply={
                        'PW?':'PWSTANDBY', 'ZM?':'ZMON', 'Z2?':'Z225\rZ2OFF',
                        'MV?':'MV80\rMVMAX 80', 'MV815':'MV30\rMV80\rMVMAX 80',
                        'MU?':'MUOFF', 'SI?':'SINET',
                        'CV?':'CVFL 495\rCVC 50\rCVFR 50\rCVEND',
                        'MS?':'MSSTEREO', 'PSDYNEQ ?':'PSDYNEQ OFF',
                        'PSTONE CTRL ?':'PSTONE CTRL OFF', 'PSBAS ?':'PSBAS 49',
                        'PSTRE ?':'PSTRE 52', 'PSTONE CTRL ON':'?',
                    }.get(cmd,cmd)
                    self.wfile.write((reply+'\r').encode())
                    self.wfile.flush()
        except (ConnectionError,OSError):
            pass
        except Exception as e:
            errors.append(str(e))

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--exe', action='append', required=True, type=Path)
args=parser.parse_args()
with Server(('127.0.0.1',0),HeosReceiver) as heos, Server(('127.0.0.1',0),AvrReceiver) as avr:
    threading.Thread(target=heos.serve_forever,daemon=True).start()
    threading.Thread(target=avr.serve_forever,daemon=True).start()
    for exe in args.exe:
        commands.clear()
        errors.clear()
        result=subprocess.run([str(exe.resolve()),str(heos.server_address[1]),str(avr.server_address[1])],capture_output=True,text=True,timeout=40)
        print(str(exe)+':\n'+result.stdout,flush=True)
        assert result.returncode==0,(result.stdout+result.stderr,errors,commands)
        assert not errors,errors
        assert 'PSBAS 51' not in commands, 'Command after a rejected write was sent'
        assert commands.count('PSTONE CTRL ON')==1,'Rejected command was replayed'
        states=[item[1]['state'] for item in commands if isinstance(item,tuple) and item[0]=='player/set_play_state']
        assert states==['pause','play','stop'], states
    heos.shutdown()
    avr.shutdown()
