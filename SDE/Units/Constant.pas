unit Constant;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Point, Forms, QSyntSymbol;

type
  TConstant = class(TSyntSymbol)
  public
    procedure StartSettings();
  end;

implementation

uses Main;

procedure TConstant.StartSettings();
begin
  Form1.Constant := TConstant.Create(Form1);
  Form1.Constant.Parent := Form1;
  Form1.Constant.font := Form1.edtVarDef.Font;
  Form1.Constant.BorderStyle := bsNone;
  Form1.Constant.Text := '���������';
  Form1.Constant.Width := Form1.Canvas.TextWidth(Form1.Constant.Text);
  Form1.Constant.OnChange := Form1.OnTextChange;
end;



end.