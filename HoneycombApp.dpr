program HoneycombApp;

uses
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  MainUnit in 'MainUnit.pas' {Form1},
  CellUnit in 'CellUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
