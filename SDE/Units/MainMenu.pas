unit MainMenu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm2 = class(TForm)
    NewDoc: TButton;
    OpenDoc: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure NewDocClick(Sender: TObject);
    procedure OpenDocClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
                       
implementation

uses Main;

{$R *.dfm}



procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SystemParametersInfo(SPI_SETBEEP, 1, nil, SPIF_SENDWININICHANGE);
  Form1.enabled := True;
  form1.edtVarDef.Visible := true;
  form1.sb1VarDef.Visible := true;
  form1.sb2VarDef.Visible := true;
  form1.eq.Visible := true;
  Form1.RedrawAll();
end;

procedure TForm2.NewDocClick(Sender: TObject);
begin
  Form1.Saveas1Click(Sender);
  Form2.Close();
end;


procedure TForm2.OpenDocClick(Sender: TObject);
begin
  Form1.Open1Click(Sender);
  Form2.Close();
end;

end.
