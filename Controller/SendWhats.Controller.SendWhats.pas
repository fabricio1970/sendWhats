unit SendWhats.Controller.SendWhats;

interface

uses
  REST.Client,
  REST.Types,
  System.Classes,
  System.Generics.Collections,
  System.Json,
  System.StrUtils,
  System.SysUtils,

  Bcl.Json,

  SendWhats.Model.TextMessage,
  SendWhats.Model.FileMessage,
  SendWhats.Model.Response,

  SendWhats.Utils.LibUtils;

type
  TStatusSession = (tssNone, tssClosed, tssInitializing, tssQrCode, tssConnected);

  TSendWhatsController = class
  private
    FRESTClient: TRESTClient;
    FRESTRequest: TRESTRequest;

    FHostname: String;
    FPort: Integer;
    FBaseUrl: String;
    FSession: String;
    FSecretKey: String;

    FToken: String;
    FQrCode: String;
    FStatusSession: TStatusSession;
    FAtivado: Boolean;

    procedure CreateRest;
    procedure DestroyRest;

    procedure SetRequest(ARestResource: String; AMethod: TRESTRequestMethod; ATimeOut: Integer = 10000);
    function SendRequest(ARestParams: TRESTRequestParameterList = nil): TCustomRESTResponse;
    procedure SetStatusSession(AStatusSession: string);
  public
    constructor Create(AHostname: String; APort: Integer; ASession: String; ASecretKey: String);
    destructor Destroy; override;

    property Session: String read FSession;
    property QrCode: String read FQrCode;

    function GenerateToken: String;

    procedure StartSession;
    function StatusSession: TStatusSession;
    function CheckConnectionSession: Boolean;
    procedure CloseSession;

    function UnreadMessages: TList<TResponseModel>;

    function SendMessage(APhone: String; AMessage: String; AIsGroup: Boolean = False): Boolean;
    function SendFileBase64(APhone: String; AFileName: String; AIsGroup: Boolean = False): Boolean;

    property Status: TStatusSession read FStatusSession;
    property Ativado: Boolean read FAtivado write FAtivado;
  end;

implementation

{ TSendWhatsController }

constructor TSendWhatsController.Create(AHostname: String; APort: Integer; ASession: String; ASecretKey: String);
begin
  FHostname := AHostname;
  FPort := APort;
  FSession := ASession;
  FSecretKey := ASecretKey;

  FBaseUrl := Concat('http://', AHostname, ':', APort.ToString, '/api');
  FToken := '';
  FQrCode := '';
  FAtivado := False;

  CreateRest;
end;

destructor TSendWhatsController.Destroy;
begin
  DestroyRest;

  inherited;
end;

procedure TSendWhatsController.CreateRest;
begin
  FRESTClient := TRESTClient.Create(nil);
  FRESTRequest := TRESTRequest.Create(nil);

  FRESTRequest.Client := FRESTClient;
end;

procedure TSendWhatsController.DestroyRest;
begin
  if Assigned(FRESTRequest) then
    FreeAndNil(FRESTRequest);
  if Assigned(FRESTClient) then
    FreeAndNil(FRESTClient);
end;

procedure TSendWhatsController.SetRequest(ARestResource: String; AMethod: TRESTRequestMethod; ATimeOut: Integer = 10000);
begin
  FRESTClient.Baseurl := FBaseUrl;
  FRESTClient.Accept := 'application/json';
  FRESTClient.ContentType := 'application/json';

  FRESTRequest.Resource := ARestResource;
  FRESTRequest.Method := AMethod;
  FRESTRequest.Timeout := ATimeOut;
end;

function TSendWhatsController.SendRequest(ARestParams: TRESTRequestParameterList = nil): TCustomRESTResponse;
var
  I: Integer;
begin
  Result := nil;;

  FRESTRequest.Params.Clear;
  if (Assigned(ARestParams)) and (ARestParams.Count > 0) then
  begin
    for I := 0 to ARestParams.Count - 1 do
      FRESTRequest.Params.AddItem(ARestParams[I].Name, ARestParams[I].Value, ARestParams[I].Kind, ARestParams[I].Options, ARestParams.Items[I].ContentType);
  end;

  try
    FRESTRequest.Execute;
    Result := FRESTRequest.Response;
  except
    on E: Exception do
      raise Exception.Create('A requisi??o falhou. Detalhe:' + E.Message);
  end;
end;

procedure TSendWhatsController.SetStatusSession(AStatusSession: string);
begin
  case AnsiIndexStr(AStatusSession, ['CLOSED', 'INITIALIZING', 'QRCODE', 'CONNECTED']) of
    0:
      FStatusSession := tssClosed;
    1:
      FStatusSession := tssInitializing;
    2:
      FStatusSession := tssQrCode;
    3:
      FStatusSession := tssConnected;
  else
    raise Exception.Create(AStatusSession);
  end;
end;

function TSendWhatsController.GenerateToken;
var
  Response: TCustomRESTResponse;
  Params: TRESTRequestParameterList;
begin
  SetRequest('/{session}/{secretkey}/generate-token', rmPOST);
  Params := TRESTRequestParameterList.Create(nil);
  try
    Params.AddItem('session', FSession, pkURLSEGMENT);
    Params.AddItem('secretkey', FSecretKey, pkURLSEGMENT);

    FRESTRequest.Accept := 'text/html, application/xhtml+xml, */*';
    try
      Response := SendRequest(Params);
      case Response.StatusCode of
        200, 201:
          begin
            FToken := Response.JSONValue.GetValue<String>('token').Replace('"', '', [rfReplaceAll]);
          end;
      else
        raise Exception.Create('N?o foi poss?vel obter o token. Detalhe: ' + Response.Content);
      end;
    except
      raise;
    end;
  finally
    FreeAndNil(Params);
  end;
end;

procedure TSendWhatsController.StartSession;
var
  Response: TCustomRESTResponse;
  Params: TRESTRequestParameterList;
  StatusSession: string;
begin
  Response := nil;
  if FToken = '' then
    GenerateToken;

  SetRequest('/{session}/start-session', rmPOST);
  Params := TRESTRequestParameterList.Create(nil);
  try
    Params.AddItem('session', FSession, pkURLSEGMENT);
    Params.AddItem('Authorization', Concat('Bearer ', FToken), pkHTTPHEADER, [poDoNotEncode]);
    Params.AddItem('webhook', 'null', pkREQUESTBODY);
    try
      Response := SendRequest(Params);
      case Response.StatusCode of
        200:
          begin
            if Response.JSONValue.FindValue('qrcode') <> nil then
              FQrCode := Response.JSONValue.GetValue<String>('qrcode').Replace('"', '', [rfReplaceAll]).Trim;
            if Response.JSONValue.GetValue<String>('status').Replace('"', '', [rfReplaceAll]) <> '' then
              SetStatusSession(Response.JSONValue.GetValue<String>('status').Replace('"', '', [rfReplaceAll]));
          end;
      else
        raise Exception.Create('N?o foi poss?vel iniciar a sess?o. Detalhe: ' + Response.Content);
      end;
    except
      on E: Exception do
        raise;
    end;
  finally
    FreeAndNil(Params);
  end;
end;

function TSendWhatsController.StatusSession: TStatusSession;
var
  Response: TCustomRESTResponse;
  Params: TRESTRequestParameterList;
begin
  Result := tssNone;
  if FToken = '' then
    GenerateToken;

  SetRequest('/{session}/status-session', rmGET);
  Params := TRESTRequestParameterList.Create(nil);
  try
    Params.AddItem('session', FSession, pkURLSEGMENT);
    Params.AddItem('Authorization', Concat('Bearer ', FToken), pkHTTPHEADER, [poDoNotEncode]);
    try
      Response := SendRequest(Params);
      case Response.StatusCode of
        200:
          begin
            if Response.JSONValue.GetValue<String>('status').Replace('"', '', [rfReplaceAll]) <> '' then
              SetStatusSession(Response.JSONValue.GetValue<String>('status').Replace('"', '', [rfReplaceAll]));
            Result := FStatusSession;
          end;
      else
        raise Exception.Create('N?o foi poss?vel encerrar a sess?o. Detalhe: ' + Response.Content);
      end;
    except
      on E: Exception do
        raise;
    end;
  finally
    FreeAndNil(Params);
  end;
end;

function TSendWhatsController.CheckConnectionSession: Boolean;
var
  Response: TCustomRESTResponse;
  Params: TRESTRequestParameterList;
  StatusSession: String;
begin
  Result := False;
  if FToken = '' then
    GenerateToken;

  SetRequest('/{session}/check-connection-session', rmGET);
  Params := TRESTRequestParameterList.Create(nil);
  try
    Params.AddItem('session', FSession, pkURLSEGMENT);
    Params.AddItem('Authorization', Concat('Bearer ', FToken), pkHTTPHEADER, [poDoNotEncode]);
    try
      Response := SendRequest(Params);
      case Response.StatusCode of
        200:
          begin
            if Response.JSONValue.GetValue<Boolean>('status') then
              Result := Response.JSONValue.GetValue<Boolean>('status');
          end
      else
        raise Exception.Create('N?o foi poss?vel checar a sess?o. Detalhe: ' + Response.Content);
      end;
    except
      on E: Exception do
        raise;
    end;
  finally
    FreeAndNil(Params);
  end;
end;

procedure TSendWhatsController.CloseSession;
var
  Response: TCustomRESTResponse;
  Params: TRESTRequestParameterList;
begin
  if FToken = '' then
    GenerateToken;

  SetRequest('/{session}/close-session', rmPOST);
  Params := TRESTRequestParameterList.Create(nil);
  try
    Params.AddItem('session', FSession, pkURLSEGMENT);
    Params.AddItem('Authorization', Concat('Bearer ', FToken), pkHTTPHEADER, [poDoNotEncode]);
    try
      Response := SendRequest(Params);
      case Response.StatusCode of
        200, 201:
          //
        else
          raise Exception.Create('N?o foi poss?vel encerrar a sess?o. Detalhe: ' + Response.Content);
      end;
    except
      on E: Exception do
        raise;
    end;
  finally
    FreeAndNil(Params);
  end;
end;

function TSendWhatsController.UnreadMessages: TList<TResponseModel>;
var
  Response: TCustomRESTResponse;
  Params: TRESTRequestParameterList;
  StatusSession: String;
begin
  Result := nil;

  SetRequest('/{session}/unread-messages', rmGET);
  Params := TRESTRequestParameterList.Create(nil);
  try

    Params.AddItem('session', FSession, pkURLSEGMENT);
    Params.AddItem('Authorization', Concat('Bearer ', FToken), pkHTTPHEADER, [poDoNotEncode]);
    try
      Response := SendRequest(Params);
      case Response.StatusCode of
        200:
          begin
            Result :=  TJson.Deserialize<TList<TResponseModel>>(Response.JSONValue.GetValue<TJSONValue>('response').ToJSON);
          end;
      else
        raise Exception.Create('N?o foi poss?vel encerrar a sess?o. Detalhe: ' + Response.Content);
      end;
    except
      on E: Exception do
        raise;
    end;
  finally
    FreeAndNil(Params);
  end;
end;

function TSendWhatsController.SendMessage(APhone: String; AMessage: String; AIsGroup: Boolean = False): Boolean;
var
  Response: TCustomRESTResponse;
  Params: TRESTRequestParameterList;
  Message_: TTextMessageModel;
begin
  Result := False;

  SetRequest('/{session}/send-message', rmPOST);
  Params := TRESTRequestParameterList.Create(nil);
  Message_ := TTextMessageModel.Create;
  try

    Message_.Phone := PhoneWithWithoutNineDigit(APhone);
    Message_.Message_ := AMessage;
    Message_.IsGroup := AIsGroup;

    Params.AddItem('session', FSession, pkURLSEGMENT);
    Params.AddItem('Authorization', Concat('Bearer ', FToken), pkHTTPHEADER, [poDoNotEncode]);
    Params.AddBody(TJson.Serialize(Message_), ctAPPLICATION_JSON);
    try
      Response := SendRequest(Params);
      case Response.StatusCode of
        201:
          Result := True;
      else
        raise Exception.Create(Format('N?o foi poss?vel enviar a mensagem. Detalhe: [%d] %s', [Response.StatusCode, Response.Content]));
      end;
    except
      on E: Exception do
        raise;
    end;
  finally
    FreeAndNil(Message_);
    FreeAndNil(Params);
  end;
end;

function TSendWhatsController.SendFileBase64(APhone: String; AFileName: String; AIsGroup: Boolean = False): Boolean;
var
  Response: TCustomRESTResponse;
  Params: TRESTRequestParameterList;
  Message_: TFileMessageModel;
  Ext: string;
begin
  Result := False;

  SetRequest('/{session}/send-file-base64', rmPOST);
  Params := TRESTRequestParameterList.Create(nil);
  Message_ := TFileMessageModel.Create;
  try
    case AnsiIndexStr(LowerCase(ExtractFileExt(AFileName)), ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.mp3', '.mp4', '.avi', '.pdf', '.doc', '.docx', '.txt', '.csv', '.xls',
      '.xlsx', '.sql']) of
      0:
        Ext := 'data:image/jpg;base64,';
      1:
        Ext := 'data:image/jpeg;base64,';
      2:
        Ext := 'data:image/png;base64,';
      3:
        Ext := 'data:image/gif;base64,';
      4:
        Ext := 'data:image/bmp;base64,';
      5:
        Ext := 'data:audio/mp3;base64,';
      6:
        Ext := 'data:audio/mp4;base64,';
      7:
        Ext := 'data:video/avi;base64,';
      8:
        Ext := 'data:application/pdf;base64,';
      9:
        Ext := 'data:application/vnd.openxmlformats-officedocument.wordprocessingml.document;base64,';
      10:
        Ext := 'data:application/vnd.openxmlformats-officedocument.wordprocessingml.document;base64,';
      11:
        Ext := 'data:text/plain;base64,';
      12:
        Ext := 'data:application/vnd.ms-excel;base64,';
      13:
        Ext := 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,';
      14:
        Ext := 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,';
      15:
        Ext := 'data:application/x-sql;base64,'
    else
      raise Exception.Create('Formato de arquivo n?o suportado.');
    end;

    Message_.Phone := PhoneWithWithoutNineDigit(APhone);
    Message_.Base64 := Ext + FileToBase64(AFileName);
    Message_.FileName := AFileName;
    Message_.IsGroup := AIsGroup;

    Params.AddItem('session', FSession, pkURLSEGMENT);
    Params.AddItem('Authorization', Concat('Bearer ', FToken), pkHTTPHEADER, [poDoNotEncode]);
    Params.AddBody(TJson.Serialize(Message_), ctAPPLICATION_JSON);
    try
      Response := SendRequest(Params);
      case Response.StatusCode of
        201:
          Result := True;
      else
        raise Exception.Create(Format('N?o foi poss?vel enviar a mensagem. Detalhe: [%d] %s', [Response.StatusCode, Response.Content]));
      end;
    except
      on E: Exception do
        raise;
    end;
  finally
    FreeAndNil(Message_);
    FreeAndNil(Params);
  end;
end;

end.
