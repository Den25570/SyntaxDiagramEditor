program MainProject;

uses
  Forms,
  Main in 'Main.pas' {Form1},
  Line in 'Units\Line.pas',
  TransferLine in 'Units\TransferLine.pas',
  AlterFunctions in 'Units\AlterFunctions.pas',
  Variable in 'Units\Variable.pas',
  QSyntSymbol in 'Units\QSyntSymbol.pas',
  SyntUnit in 'Units\SyntUnit.pas',
  Alternative in 'Units\Alternative.pas',
  Point in 'Units\Point.pas',
  Constant in 'Units\Constant.pas',
  States in 'Units\States.pas',
  FileControl in 'Units\FileControl.pas',
  ExportUnit in 'Units\ExportUnit.pas',
  MainMenu in 'Units\MainMenu.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Form2.Show();
  Application.Run;
end.
