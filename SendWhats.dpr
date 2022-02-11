program SendWhats;

uses
  Vcl.Forms,
  View.Main in 'View\View.Main.pas' {MainView},
  SendWhats.Controller.SendWhats in 'Controller\SendWhats.Controller.SendWhats.pas',
  SendWhats.Utils.LibUtils in 'Utils\SendWhats.Utils.LibUtils.pas',
  SendWhats.Utils.Emoction in 'Utils\SendWhats.Utils.Emoction.pas',
  SendWhats.Model.TextMessage in 'Model\SendWhats.Model.TextMessage.pas',
  SendWhats.Model.FileMessage in 'Model\SendWhats.Model.FileMessage.pas',
  SendWhats.Model.Response in 'Model\SendWhats.Model.Response.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainView, MainView);
  Application.Run;
end.
