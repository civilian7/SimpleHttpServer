unit uMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,

  IdContext,
  IdHttp,
  IdCustomHttpServer,
  IdHttpServer;

type
  TForm3 = class(TForm)
  private
    FServer: TIdHttpServer;

    function  GetDesktop: string;
    procedure TriggerCommandGet(AContext: TIdContext; ARequestInfo:
      TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Form3: TForm3;

implementation

uses
  System.NetEncoding,
  Vcl.Imaging.pngimage;

{$R *.dfm}

{ TForm3 }

constructor TForm3.Create(AOwner: TComponent);
begin
  inherited;

  FServer := TIdHttpServer.Create(nil);
  with FServer.Bindings.Add do
  begin
    IP := '0.0.0.0';
    Port := 8080;
  end;

  FServer.OnCommandGet := TriggerCommandGet;
  FServer.Active := True;
end;

destructor TForm3.Destroy;
begin
  FServer.Active := False;
  FServer.Free;

  inherited;
end;

function TForm3.GetDesktop: string;
begin
  var LDC := GetDC(0);
  var LBitmap := TBitmap.Create(Screen.WorkAreaWidth, Screen.WorkAreaHeight);
  var LPNGImage := TPNGImage.Create;
  var LStream := TMemoryStream.Create;
  var LEncoder := TBase64Encoding.Create(0);

  try
    BitBlt(LBitmap.Canvas.Handle, 0, 0, Screen.WorkAreaWidth, Screen.WorkAreaHeight,
      LDC, 0, 0, SRCCOPY);

    LPNGImage.Assign(LBitmap);
    LPNGImage.SaveToStream(LStream);
    Result := LEncoder.EncodeBytesToString(LStream.Memory, LStream.Size);
  finally
    ReleaseDC(0, LDC);
    LBitmap.Free;
    LPNGImage.Free;
    LStream.Free;
    LEncoder.Free;
  end;
end;

procedure TForm3.TriggerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
const
  HTML = '''
  <!DOCTYPE html>
  <html>
    <header>
    </header>
    <body>
      <div>
        <img src="data:image/png;base64, %s", alt="screen" />
      </div>
    </body>
  </html>
  ''';
begin
  if SameText(ARequestInfo.URI, '/image') then
  begin
    AResponseInfo.ContentType := 'text/html';
    AResponseInfo.ContentText := Format(HTML, [GetDesktop]);
  end;
end;

end.
