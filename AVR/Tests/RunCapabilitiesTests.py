# FactoryX AVR capabilities: read-only HTTP and TCP simulator regression tests.
from pathlib import Path
import argparse,subprocess,tempfile,threading,http.server,socketserver,time,os

parser=argparse.ArgumentParser()
parser.add_argument('--delphi-root',default=r'C:\Program Files (x86)\Embarcadero\Studio\15.0')
parser.add_argument('--sample-root',type=Path)
parser.add_argument('--mfpack-root',type=Path)
args=parser.parse_args()
api=Path(__file__).resolve().parents[2]
bds=Path(args.delphi_root)
output=api/'Build/CapabilitiesTests';output.mkdir(parents=True,exist_ok=True)
fixture=output/'Fixture';fixture.mkdir(exist_ok=True)
if args.sample_root:
    assert args.mfpack_root,'--mfpack-root is required with --sample-root'
    for name in ['MainForm','HEOSRadioForm']:
        text=(args.sample_root/(name+'.pas')).read_text(encoding='utf-8-sig').replace('  private','  public')
        (fixture/(name+'.pas')).write_bytes(text.replace('\n','\r\n').encode())
        (fixture/(name+'.dfm')).write_bytes((args.sample_root/(name+'.dfm')).read_bytes())

for platform in ['win32','win64']:
    out=output/platform;out.mkdir(exist_ok=True)
    paths=[api/'Source',api/'AVR/Source',bds/'lib'/platform/'release']
    programs=[api/'AVR/Tests/AvrCapabilitiesTests.dpr']
    if args.sample_root:
        paths=[fixture,args.sample_root,args.sample_root/'Controls',args.mfpack_root/'src']+paths
        programs.append(args.sample_root/'Tests/AvrCapabilitiesFormTests.dpr')
    for program in programs:
        cmd=[str(bds/'bin'/('dcc32.exe' if platform=='win32' else 'dcc64.exe')),'-B','-Q',
             '-NSSystem;Winapi;Vcl;Data;Xml;System.Win;Data.Win;Xml.Win','-U'+';'.join(map(str,paths)),
             '-N0'+str(out),'-E'+str(out),str(program)]
        r=subprocess.run(cmd,cwd=program.parent,capture_output=True,text=True)
        print(platform,program.name,r.stdout,r.stderr,flush=True)
        assert r.returncode==0

xml=(api/'AVR/Tests/Fixtures/X2700H-Capabilities.xml').read_bytes()
limited=b'<Device_Info><ModelName>Limited AVR</ModelName><DeviceZones>1</DeviceZones><DeviceCapabilities><Setup><ToneControl><Control>0</Control></ToneControl><ChannelLevel><Control>0</Control></ChannelLevel></Setup></DeviceCapabilities><DeviceZoneCapabilities><Zone><No>0</No></Zone><Power><Control>1</Control></Power><Volume><Control>1</Control></Volume><Mute><Control>0</Control></Mute></DeviceZoneCapabilities></Device_Info>'
http_requests=[];avr_commands=[]
class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self,*args):pass
    def do_GET(self):
        http_requests.append((self.server.mode,self.path))
        assert self.path=='/goform/Deviceinfo.xml'
        if self.server.mode=='missing':self.send_error(404);return
        body=limited if self.server.mode in ['limited','slow'] else xml
        if self.server.mode=='slow':time.sleep(0.6)
        self.send_response(200);self.send_header('Content-Type','text/xml; charset=utf-8')
        self.send_header('Content-Length',str(len(body)));self.end_headers()
        if self.server.mode=='timeout':time.sleep(5.0)
        try:self.wfile.write(body)
        except (BrokenPipeError,ConnectionResetError):pass
class AvrHandler(socketserver.BaseRequestHandler):
    def handle(self):
        data=b''
        while True:
            chunk=self.request.recv(1024)
            if not chunk:return
            data+=chunk
            while b'\r' in data:
                line,data=data.split(b'\r',1);command=line.decode().strip()
                if not command:continue
                avr_commands.append(command)
                reply={'ZM?':b'ZMON\r','MV?':b'MV30\rMVMAX 80\r'}
                assert command in reply,('Unsupported command reached receiver',command)
                self.request.sendall(reply[command])
class AvrServer(socketserver.ThreadingTCPServer):
    allow_reuse_address=True
    daemon_threads=True

servers=[]
try:
    ports=[]
    for mode in ['valid','missing','slow','timeout','limited']:
        server=http.server.ThreadingHTTPServer(('127.0.0.1',0),Handler);server.mode=mode
        servers.append(server);ports.append(str(server.server_address[1]))
    avr=AvrServer(('127.0.0.1',0),AvrHandler);servers.append(avr)
    for server in servers:threading.Thread(target=server.serve_forever,daemon=True).start()
    for platform in ['win32','win64']:
        for name in ['AvrCapabilitiesTests']+(['AvrCapabilitiesFormTests'] if args.sample_root else []):
            profile=Path(tempfile.mkdtemp(prefix=name+'-',dir=output/platform))
            env=os.environ.copy();env['LOCALAPPDATA']=str(profile)
            cmd=[str(output/platform/(name+'.exe')),str(api/'AVR/Tests/Fixtures/X2700H-Capabilities.xml'),
                 str(profile/'Capabilities.ini')]+ports+[str(avr.server_address[1])]
            avr_commands.clear()
            r=subprocess.run(cmd,capture_output=True,text=True,timeout=35,env=env)
            print(platform,name,r.stdout,r.stderr,flush=True)
            assert r.returncode==0
            if name=='AvrCapabilitiesFormTests':assert avr_commands==['ZM?','MV?'],avr_commands
    print('PASS Win32/Win64: HTTP is read-only, unsupported TCP commands are omitted.',flush=True)
finally:
    for server in servers:server.shutdown();server.server_close()
