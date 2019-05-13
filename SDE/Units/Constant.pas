unit Constant;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Point, Forms, QSyntSymbol;

type
  TConstant = class(TSyntSymbol)
  public
    procedure StartSettings();
    procedure align();
  end;

implementation

uses Main;

procedure TConstant.StartSettings();
begin
  Form1.Constant := TConstant.Create(Form1);
  Form1.Constant.Parent := Form1;
  Form1.Constant.font := Form1.edtVarDef.Font;
  Form1.Constant.BorderStyle := bsNone;
  Form1.Constant.Text := 'константа';
  Form1.Constant.Width := Form1.Canvas.TextWidth(Form1.Constant.Text);
end;

procedure TConstant.align();
begin
  self.Top := self.prev.Top + self.prev.Height div 2 - self.Height div 2 + 3;
  self.Left := self.prev.Left + self.prev.Width + 5;
end;

end.
