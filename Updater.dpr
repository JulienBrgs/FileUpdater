program Updater;

uses
  Vcl.Forms,
  FormUpdater in 'FormUpdater.pas' {Form1},
  uUpdater in 'uUpdater.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
