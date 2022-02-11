unit View.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, JvExStdCtrls, JvButton, JvCtrls,
  Vcl.Imaging.pngimage, Vcl.Mask, System.Generics.Collections,
  //
  Bcl.Json,
  System.JSON,

  SendWhats.Controller.SendWhats,
  SendWhats.Model.Response,
  SendWhats.Utils.LibUtils;

type
  TStatusConexao = (tsConnected);

  TMainView = class(TForm)
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Image1: TImage;
    Timer1: TTimer;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    MaskEditMyNumber: TMaskEdit;
    Label3: TLabel;
    EditHostname: TEdit;
    EditPort: TEdit;
    EditSecret: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    StatusBar1: TStatusBar;
    OpenDialog1: TOpenDialog;
    Panel2: TPanel;
    RichEditMyChat: TRichEdit;
    Panel3: TPanel;
    Label1: TLabel;
    MaskEditAdresserPhone: TMaskEdit;
    Panel1: TPanel;
    Panel4: TPanel;
    RichEditMessage: TRichEdit;
    BotaoSendMessage: TButton;
    BotaoSendFileMessage: TButton;
    BotaoStartStop: TButton;
    BotaoCloseSession: TButton;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BotaoSendFileMessageClick(Sender: TObject);
    procedure BotaoSendMessageClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BotaoStartStopClick(Sender: TObject);
    procedure BotaoCloseSessionClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FAtivado: Boolean;
    FStatusSession: TStatusSession;
    FStatusConexao: TStatusConexao;
    SendWhats: TSendWhatsController;
  public
  end;

var
  MainView: TMainView;

implementation

{$R *.dfm}

procedure TMainView.BotaoSendFileMessageClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    SendWhats.SendFileBase64(MaskEditAdresserPhone.Text, OpenDialog1.FileName);
  end;
end;

procedure TMainView.BotaoSendMessageClick(Sender: TObject);
begin
  SendWhats.SendMessage(MaskEditAdresserPhone.Text, RichEditMessage.Text)
end;

procedure TMainView.BotaoStartStopClick(Sender: TObject);
begin
  if Assigned(SendWhats) then
    FreeAndNil(SendWhats);
  SendWhats := TSendWhatsController.Create(EditHostname.Text, StrToIntDef(EditPort.Text, 0), MaskEditMyNumber.Text, EditSecret.Text);

  if BotaoStartStop.Caption = 'Start' then
  begin
    BotaoStartStop.Caption := 'Stop';

    FAtivado := True;
    Timer1.Enabled := True;
  end
  else
  begin
    FAtivado := False;
    Timer1.Enabled := False;

    Image1.Picture := nil;
    StatusBar1.Panels[0].Text := 'Server Stoped';
    BotaoStartStop.Caption := 'Start';
  end;
end;

procedure TMainView.Button1Click(Sender: TObject);
var
  UnreadMessages: TList<TResponseModel>;
begin
  UnreadMessages := SendWhats.UnreadMessages;
  RichEditMyChat.Text := TJson.Serialize(UnreadMessages);
end;

procedure TMainView.BotaoCloseSessionClick(Sender: TObject);
begin
  SendWhats.CloseSession;
end;

procedure TMainView.FormCreate(Sender: TObject);
begin
  FAtivado := False;
  FStatusSession := tssNone;
end;

procedure TMainView.FormDestroy(Sender: TObject);
begin
  if Assigned(SendWhats) then
    FreeAndNil(SendWhats);
end;

procedure TMainView.FormShow(Sender: TObject);
begin
  RichEditMessage.SetFocus;
end;

procedure TMainView.Timer1Timer(Sender: TObject);
begin
  try
    case SendWhats.StatusSession of
      tssNone:
        StatusBar1.Panels[0].Text := '';
      tssClosed:
        StatusBar1.Panels[0].Text := 'Desconectado';
      tssInitializing:
        StatusBar1.Panels[0].Text := 'Inicializando';
      tssQrCode:
        StatusBar1.Panels[0].Text := 'Aguardando QRCode';
      tssConnected:
        StatusBar1.Panels[0].Text := 'Conectado';
    end;
    BotaoCloseSession.Enabled := SendWhats.Status = tssConnected;
    if FAtivado and not SendWhats.CheckConnectionSession then
    begin
      SendWhats.StartSession;
      if SendWhats.QrCode <> '' then
        Base64ToQrCode(SendWhats.QrCode, Image1);
    end
    else
      Image1.Picture := nil;
  except
    BotaoStartStop.Click;
    raise;
  end;
end;

end.
