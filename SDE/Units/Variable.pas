unit Variable;

interface

uses
  SysUtils, Classes, StdCtrls, QSyntSymbol , Graphics, Forms ;

type
  TVariable = class(TSyntSymbol)
  public
    sqrBra: array[1..2] of TStaticText;
    constructor Create(AOwner : TComponent);
    destructor Destroy();
    procedure align();
  end;

implementation

uses main, Line;

constructor TVariable.Create(AOwner : TComponent);
begin
  inherited;
  Parent := Form1;
  font := Form1.edtVarDef.Font;
  Text := 'переменная';
  Width := Form1.Canvas.TextWidth('переменная');
  OnClick := Form1.StartLineClick;
  BorderStyle := bsNone;
  PopupMenu := Form1.pm1;
  sqrBra[1] := TStaticText.Create(Form1);
  sqrBra[2] := TStaticText.Create(Form1);
  sqrBra[1].Parent := Form1;
  sqrBra[2].Parent := Form1;
  sqrBra[1].font := Form1.sb1VarDef.Font;
  sqrBra[1].Caption := '<';
  sqrBra[2].font := Form1.sb1VarDef.Font;
  sqrBra[2].Caption := '>';
end;

destructor TVariable.Destroy();
begin
  sqrBra[1].Destroy();
  sqrBra[2].Destroy();
  inherited;
end;

procedure TVariable.ALign;
begin
  sqrBra[1].Left := prev.left + prev.width + ElemDistance;
  sqrBra[1].Top := prev.Top + prev.height div 2 - sqrBra[1].height div 2 + 1;
  Self.Left := sqrBra[1].Left + sqrBra[1].width + SBDistance;
  Self.Top := sqrBra[1].Top + sqrBra[1].height div 2 - Self.height div 2 + 1;
  sqrBra[2].Left := Self.left + Self.Width + SBDistance + 2;
  sqrBra[2].Top := Self.Top + Self.height div 2 - sqrBra[2].height div 2 - 1;
end;


end.

