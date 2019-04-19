unit Variable;

interface

uses
  SysUtils, Classes, StdCtrls, QSyntSymbol;

type
  TVariable = class(TSyntSymbol)
  private
    constructor Create(AOwner : TComponent);
    destructor Destroy();
  public
    sqrBra: array[1..2] of TStaticText;
    procedure StartSettings();
    procedure Align();
  end;

implementation

uses main;

constructor TVariable.Create(AOwner : TComponent);
begin
  inherited;
end;

destructor TVariable.Destroy();
begin
  sqrBra[1].Destroy();
  sqrBra[2].Destroy();
  inherited;
  //wtf
end;

procedure TVariable.StartSettings();
begin
  Parent := Form1;
  font := Form1.edtVarDef.Font;
  Text := 'переменная';
  Width := Form1.Canvas.TextWidth('переменная');
  OnChange := Form1.OnTextChange;
  OnClick := Form1.StartLineClick;
  PopupMenu := Form1.pm1;
  Altindex := -1;
  isAlter := false;
  sqrBra[1] := TStaticText.Create(Form1);
  sqrBra[2] := TStaticText.Create(Form1);
  sqrBra[1].Parent := Form1;
  sqrBra[2].Parent := Form1;
  sqrBra[1].font := Form1.sb1VarDef.Font;
  sqrBra[1].Caption := '<';
  sqrBra[2].font := Form1.sb1VarDef.Font;
  sqrBra[2].Caption := '>';
end;

procedure TVariable.ALign;
begin
  sqrBra[1].Left := left - 5 - sqrBra[1].Width;
  sqrBra[1].Top := Top - 4;
  sqrBra[2].Left := left + Width + 5;
  sqrBra[2].Top := Top - 4;
end;


end.

