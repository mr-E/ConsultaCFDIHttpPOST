program TestPostRequestConsole;
// Thanks to: Kryvich
//- https://en.delphipraxis.net/topic/238-how-to-http-post-in-delphi/?do=findComment&comment=1899

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  // Synopse/mORMot: 
  //- https://github.com/synopse/mORMot
  SynCrtSock;

const
  // Servicio público de consulta estatus CFDI SAT
  //-Consumo a través de un POST
  //-Debido a que el SAT oculto la declaración del WebService en productivo lo consumiremos a través de 
  // un HTTP Request POST indicándole los datos correspondientes.  
  // https://developers.sw.com.mx/knowledge-base/servicio-publico-de-consulta-estatus-cfdi-sat/
  RequestHeaderTemplate =
    'SOAPAction: http://tempuri.org/IConsultaCFDIService/Consulta';
  RequestDataTemplate =
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">'
    + '   <soapenv:Header/>'
    + '   <soapenv:Body>'
    + '      <tem:Consulta>'
    + '         <!--Optional:-->'
    + '         <tem:expresionImpresa><![CDATA[%expresionImpresa%]]></tem:expresionImpresa>'
    + '      </tem:Consulta>'
    + '   </soapenv:Body>'
    + '</soapenv:Envelope>';
    
function SendCommand(Request: THttpRequest; const ExpresionImpresa: string): SockString;
var
  outHeaders: SockString;
begin
  Result := '';
  try
    Request.Request('ConsultaCFDIService.svc?wsdl', 'POST', 20000,
      RequestHeaderTemplate,
      SockString(StringReplace(RequestDataTemplate, '%expresionImpresa%',
        ExpresionImpresa, [])),
      'text/xml;charset="utf-8"', outHeaders, Result);
  except
    on E: Exception do begin
      Writeln('Error: ', E.Message);
      Exit;
    end;
  end;
end;

var
  Request: THttpRequest;
  Answer: SockString;
begin
  try
    Request := TWinHTTP.Create('consultaqr.facturaelectronica.sat.gob.mx', '', True);
    try
      Answer := SendCommand(Request,
        '?re=LSO1306189R5&rr=GACJ940911ASA&tt=4999.99&id=e7df3047-f8de-425d-b469-37abe5b4dabb');
      Writeln('Answer:');
      Writeln('----------------');
      Writeln(Answer);
      Writeln('----------------');
      // Next requests go here ...
    finally
      Request.Free;
    end;
    Writeln('Press Enter to continue.');
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
