program Main;

uses
  Forms,
  test2 in '..\..\..\Soft\Delphi 7 Borland\My_Delph\TestForm\test2.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
