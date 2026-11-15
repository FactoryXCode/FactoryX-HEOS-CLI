# FactoryX - HEOS Remote 1.1 localhost radio regression checks.
# Builds private-access fixture copies; application units stay unchanged.
from pathlib import Path
import argparse,subprocess,os,tempfile
parser=argparse.ArgumentParser()
parser.add_argument('--mfpack-root',required=True)
parser.add_argument('--heos-cli-root',default=r'D:\GitHub\FactoryX-HEOS-CLI')
parser.add_argument('--delphi-root',default=r'C:\Program Files (x86)\Embarcadero\Studio\15.0')
parser.add_argument('--output-root')
options=parser.parse_args()
root=Path(__file__).resolve().parent.parent
bds=Path(options.delphi_root)
output=Path(options.output_root).resolve() if options.output_root else root.parent.parent.parent/'Build/RadioTests'
output.mkdir(parents=True,exist_ok=True)
fixture=output/'Fixture';fixture.mkdir(exist_ok=True)
for name in ['HEOSRadioForm','MainForm']:
    s=(root/(name+'.pas')).read_text(encoding='utf-8-sig').replace('  private','  public')
    (fixture/(name+'.pas')).write_bytes(s.replace('\n','\r\n').encode())
    (fixture/(name+'.dfm')).write_bytes((root/(name+'.dfm')).read_bytes())
for platform in ['win32','win64']:
    out=output/platform;out.mkdir(exist_ok=True)
    paths=[fixture,root,root/'Controls',Path(options.heos_cli_root)/'Source',Path(options.heos_cli_root)/'AVR/Source',Path(options.mfpack_root)/'src',bds/'lib'/platform/'release']
    args=[str(bds/'bin'/('dcc32.exe' if platform=='win32' else 'dcc64.exe')),'-B','-Q','-NSSystem;Winapi;Vcl;Data;Xml;System.Win;Data.Win;Xml.Win','-U'+';'.join(map(str,paths)),'-N0'+str(out),'-E'+str(out),str(root/'Tests/HeosRadioTests.dpr')]
    for test in ['HeosRadioTests','HeosReceiverRecoveryTests','HeosRadioArtworkTests','HeosStreamProbeErrorTests','HeosPlaybackButtonTests']:
        args[-1]=str(root/'Tests'/(test+'.dpr'))
        r=subprocess.run(args,cwd=root,capture_output=True,text=True)
        print(platform,test,r.stdout,r.stderr,flush=True);assert r.returncode==0

import socket,socketserver,threading,json,urllib.parse,subprocess,http.server,struct,zlib,time,wave
stop_failure=output/"fail-next-stop"
stop_failure.unlink(missing_ok=True)
audio_file=output/"handover.wav"
with wave.open(str(audio_file),"wb") as audio:
    audio.setnchannels(2);audio.setsampwidth(2);audio.setframerate(44100)
    audio.writeframes(b"\0"*(44100*4))
commands=[];errors=[]
category='genre?x=\u00e4&y=1%+space%26'
search='Jazz & \u65e5\u672c\u8a9e + %'
media='s=42&token=100%+\u00e4'
def heos_encode(text):
    return ''.join('%'+format(b,'02X') if b<32 or b>126 or b in (37,38,61) else chr(b) for b in text.encode('utf-8'))
def item(name,**extra):return {'name':heos_encode(name),**{k:heos_encode(v) if isinstance(v,str) else v for k,v in extra.items()}}
class Receiver(socketserver.StreamRequestHandler):
    def handle(self):
        played_here=False
        try:
            while True:
                raw=self.rfile.readline()
                if not raw:return
                wire=raw.decode().strip().removeprefix('heos://')
                path,_,query=wire.partition('?')
                p={k:urllib.parse.unquote(v) for k,v in (part.split('=',1) for part in query.split('&') if '=' in part)}
                commands.append((path,p))
                reply={'heos':{'command':path,'result':'success','message':''}}
                if path=='player/get_players':
                    reply['payload']=[{'pid':2,'ip':'192.168.1.5'},{'pid':-42,'ip':'127.0.0.1'}] if not self.server.mismatch else [{'pid':2,'ip':'192.168.1.5'}]
                elif path=='browse/get_music_sources':
                    reply['payload']=[item('TuneIn',sid=3,available='false'),item('HEOS Favorites',sid=1028,available=True),item('Spotify',sid=4,available=True),item('iHeartRadio',sid=7,available=False),item('SiriusXM',sid=8,available=True)]
                elif path=='browse/get_search_criteria':
                    if p['sid']=='8':reply['heos'].update(result='fail',message='eid=7&text=Login%20required')
                    else:reply['payload']=[item('Artist',scid='1'),item('Station',scid='station & live')]
                elif path=='browse/browse':
                    sid=p['sid'];cid=p.get('cid','')
                    if sid=='8' or cid=='denied':reply['heos'].update(result='fail',message='eid=7&text=Login%20required')
                    elif sid=='1028':
                        reply['payload']=[item('Favorite radio',sid=7,container='no',playable='yes',type='station',mid='favorite&station')]
                        reply['heos']['message']='count=1&returned=1'
                    elif cid=='':
                        assert 'range' not in p
                        reply['payload']=[item('Local & News',cid=category,container='yes',playable='no',type='container'),item('Private',cid='denied',container='yes',playable='no',type='container')]
                    elif cid==category:
                        if p['range']=='0,49':reply['payload']=[item('News',container='no',playable='yes',type='station',mid='news'),item('Podcast song',container='no',playable='yes',type='song',mid='song')]
                        else:
                            assert p['range']=='2,51',p
                            reply['payload']=[]
                        reply['heos']['message']='count=0&returned='+str(len(reply['payload']))
                    else:raise AssertionError(p)
                elif path=='browse/search':
                    assert p['search']==search and p['scid']=='station & live',p
                    reply['payload']=[item('Jazz & Caf\u00e9',container='no',playable='yes',type='station',mid=media)]
                    reply['heos']['message']='count=1&returned=1'
                elif path=='browse/play_stream':
                    played_here=True
                    assert p['pid']=='-42',p
                    assert 'cid' not in p,p
                    if 'url' in p:
                        assert p['url'].startswith('http://127.0.0.1:') and (p['url'].endswith('/live?token=a&b=100%25+test') or p['url'].endswith('/track.wav') or p['url'].endswith('/radio/live.aac')),p
                    elif p['sid']=='3':assert p['mid']==media and p['name']=='Jazz & Caf\u00e9',p
                    else:assert p['sid']=='7' and p['mid']=='favorite&station',p
                elif path=='player/get_play_state':reply['heos']['message']='pid=-42&state='+('unknown' if played_here else 'play')
                elif path=='player/set_play_state':
                    assert p=={'pid':'-42','state':'stop'},p
                    if stop_failure.exists():
                        stop_failure.unlink()
                        reply['heos'].update(result='fail',message='eid=7&text=Mock Stop refused')
                elif path=='system/register_for_change_events':
                    assert p=={'enable':'on'},p
                elif path=='system/heart_beat':pass
                else:raise AssertionError((path,p))
                self.wfile.write((json.dumps(reply)+'\r\n').encode());self.wfile.flush()
        except (ConnectionError,OSError):pass
        except Exception as exc:errors.append((repr(exc),wire))
class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address=True
    daemon_threads=True
def png(width,height):
    def chunk(kind,data):
        return struct.pack('>I',len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data)&0xffffffff)
    rows=b''.join(b'\0'+b'\xff\x80\0\xff'*width for _ in range(height))
    return b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',width,height,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(rows))+chunk(b'IEND',b'')
class Artwork(http.server.BaseHTTPRequestHandler):
    def log_message(self,*args):pass
    def do_GET(self):
        if self.path=='/slow-probe':
            time.sleep(0.5)
            self.send_response(503);self.send_header('Content-Length','0');self.end_headers();return
        if self.path=='/web':
            data=b'<html><head><link rel="apple-touch-icon" href="/logo-small"></head></html>'
            self.send_response(200);self.send_header('Content-Type','text/html');self.send_header('Content-Length',str(len(data)));self.end_headers();self.wfile.write(data);return
        if self.path.startswith('/live?'):
            data=b'not-decoded-by-the-header-probe'
            self.send_response(200);self.send_header('Content-Type','audio/aac');self.send_header('Content-Length',str(len(data)));self.end_headers();self.wfile.write(data);return
        if self.path=='/redirect':
            self.send_response(302);self.send_header('Location','/logo-small');self.end_headers();return
        if self.path=='/missing':self.send_response(404);self.end_headers();return
        data=png(3,2) if self.path=='/logo-large' else png(2,3)
        self.send_response(200);self.send_header('Content-Type','image/png');self.send_header('Content-Length',str(len(data)));self.end_headers()
        if self.path=='/slow-logo':time.sleep(0.5)
        try:self.wfile.write(data)
        except OSError:pass
class Website(http.server.BaseHTTPRequestHandler):
    def log_message(self,*args):pass
    def do_GET(self):
        if self.path=='/redirect-site':
            self.send_response(302);self.send_header('Location','/');self.end_headers();return
        if self.path=='/logo-small':
            data=png(2,3);content='image/png';status=200
        elif self.path=='/radio/live.aac':
            mode=getattr(self.server,'mode','good')
            if mode=='missing-aac':data=b'';content='text/plain';status=404
            elif mode=='html-aac':data=b'<html>not audio</html>';content='text/html';status=200
            elif mode=='bad-type':data=b'not audio';content='application/octet-stream';status=200
            else:data=b'\xff\xf1'+b'\0'*30;content='audio/aac; charset=binary';status=200
        else:
            self.server.mode=self.path.strip('/') or 'good'
            data=b'<html><head><link rel="icon" href="/logo-small"></head></html>';content='text/html';status=200
        self.send_response(status);self.send_header('Content-Type',content);self.send_header('Content-Length',str(len(data)));self.end_headers();self.wfile.write(data)
with Server(('127.0.0.1',1255),Receiver) as receiver,Server(('127.0.0.1',0),Receiver) as wrong,http.server.ThreadingHTTPServer(('127.0.0.1',0),Artwork) as artwork,http.server.ThreadingHTTPServer(('127.0.0.1',0),Website) as website:
    receiver.mismatch=False;wrong.mismatch=True
    for server in [receiver,wrong,artwork,website]:threading.Thread(target=server.serve_forever,daemon=True).start()
    for platform in ['win32','win64']:
        button_profile=Path(tempfile.mkdtemp(prefix='ButtonProfile-',dir=output/platform))
        button_env=os.environ.copy();button_env['LOCALAPPDATA']=str(button_profile)
        buttons=subprocess.run([str(output/platform/'HeosPlaybackButtonTests.exe')],capture_output=True,text=True,timeout=10,env=button_env)
        print(platform+': '+buttons.stdout,flush=True)
        assert buttons.returncode==0,(buttons.stdout,buttons.stderr)
        commands.clear();errors.clear()
        with socket.socket() as port_probe:
            port_probe.bind(('127.0.0.1',0))
            closed_port=port_probe.getsockname()[1]
        probe=subprocess.run([str(output/platform/'HeosStreamProbeErrorTests.exe'),str(artwork.server_address[1]),str(closed_port),str(website.server_address[1])],capture_output=True,text=True,timeout=15)
        print(platform+': '+probe.stdout,flush=True)
        assert probe.returncode==0,(probe.stdout,probe.stderr)
        recovery=subprocess.run([str(output/platform/'HeosReceiverRecoveryTests.exe'),str(closed_port),str(output/platform/'TestProfile')],capture_output=True,text=True,timeout=25)
        print(platform+': '+recovery.stdout,flush=True)
        assert recovery.returncode==0,(recovery.stdout,recovery.stderr)
        art=subprocess.run([str(output/platform/'HeosRadioArtworkTests.exe'),str(artwork.server_address[1])],capture_output=True,text=True,timeout=20)
        print(platform+': '+art.stdout,flush=True)
        assert art.returncode==0,(art.stdout,art.stderr)
        radio_profile=Path(tempfile.mkdtemp(prefix='RadioProfile-',dir=output/platform))
        radio_env=os.environ.copy();radio_env['LOCALAPPDATA']=str(radio_profile)
        with socket.socket() as port_probe:
            port_probe.bind(('127.0.0.1',0));audio_port=port_probe.getsockname()[1]
        r=subprocess.run([str(output/platform/'HeosRadioTests.exe'),str(wrong.server_address[1]),str(audio_file),str(audio_port),str(stop_failure),'http://127.0.0.1:'+str(artwork.server_address[1]),'http://127.0.0.1:'+str(website.server_address[1])+'/'],capture_output=True,text=True,timeout=35,env=radio_env)
        print(platform+': '+r.stdout,flush=True)
        assert r.returncode==0,(r.stdout,r.stderr,errors,commands)
        assert not errors,errors
        controls=[(c,p) for c,p in commands if c in ('browse/play_stream','player/set_play_state')]
        assert len([c for c,p in controls if c=='browse/play_stream'])==9,controls
        for i,(c,p) in enumerate(controls):
            if c=='browse/play_stream':
                assert i>0 and controls[i-1][0]=='player/set_play_state',controls
        print(platform+': PASS Stop precedes each source start, cancellation and failed-Stop handling.',flush=True)
    receiver.shutdown();wrong.shutdown();artwork.shutdown();website.shutdown()
