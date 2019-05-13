unit Line;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Point, Forms, SyntUnit;

type
  TLine = class(TSyntUnit)
  public
    hasArrow: boolean;
    MinWidth: integer;
    arrowReversed: boolean;
    constructor Create(Aowner: TComponent);
    destructor Destroy();
    procedure Draw();
    procedure PointCreate(MPoint: TShape; Form: TForm);
    procedure ShowPoints();
    procedure ShowPointsL();
    procedure align();
  end;

implementation

uses
  TransferLine, Main, Alternative, QSyntSymbol, Variable, Constant;

constructor TLine.Create(AOwner: TComponent);
begin
  inherited;
  Parent := Form1;
  Height := LnH;
  Width := LnW;
  MinWidth := MinW;
  hasArrow := True;
  OnClick := Form1.StartLineClick;
  PointCreate(Form1.MainPoint, Form1);
end;

destructor TLine.Destroy();
begin
  inherited;
end;

procedure TLine.PointCreate(MPoint: TShape; Form: TForm);
var
  ind: Integer;
begin
  ind := Length(Points);
  SetLength(Points, ind + 1);
  Points[ind] := TPoint.Create(Form);
  Points[ind].SubDepth := SubDepth;
  Points[ind].Owner := Self;
  Points[ind].AltLineIndex := ind;
end;

procedure TLine.ShowPoints;
var
  i: Integer;
  TotalWidth: integer;
  alt: TSyntUnit;
begin
  for i := 0 to Length(Points) - 2 do
  begin
    Points[i].Left := Left + ((alternative[i] as TSyntUnit).Left - Left) div 2;
    Points[i].Top := Top + (Height div 2) - Points[i].Height div 2;
    Points[i].Visible := True;
  end;
  if length(alternative) > 0 then
  begin
    alt := (alternative[length(alternative) - 1] as TSyntUnit);
    Points[Length(Points) - 1].Left := alt.Left + (Left + Width - alt.Left) div 2;
  end
  else
    Points[Length(Points) - 1].Left := Left + Width div 2 - Points[Length(Points) - 1].width div 2;
  Points[Length(Points) - 1].Top := Top + (Height div 2) - Points[Length(Points) - 1].Height div 2;
  Points[Length(Points) - 1].Visible := True;
end;

procedure TLine.ShowPointsL;
var
  i: Integer;
  TotalWidth: integer;
  alt: TSyntUnit;
begin
  TotalWidth := Width div (Length(Points) + 1);
  for i := 0 to Length(Points) - 2 do
  begin
    Points[i].Left := Left + ((alternative[i] as TSyntUnit).Left - Left) div 2;
    Points[i].Top := Top + (Height div 2) - Points[i].Height div 2;
    Points[i].Visible := True;
  end;
  if next <> nil then
  begin
    if length(alternative) > 0 then
    begin
      alt := (alternative[length(alternative) - 1] as TSyntUnit);
      Points[Length(Points) - 1].Left := alt.Left + (Left + Width - alt.Left) div 2;
    end
    else
      Points[Length(Points) - 1].Left := Left + Width div 2 - Points[Length(Points) - 1].width div 2;
    Points[Length(Points) - 1].Top := Top + (Height div 2) - Points[Length(Points) - 1].Height div 2;
    Points[Length(Points) - 1].Visible := True;
  end
end;

procedure TLine.Draw;
var
  Wdth: Integer;
begin
  Repaint;
  Canvas.Pen.Width := 2;
  Canvas.Rectangle(0, Height div 2, Width + 1, (Height div 2) + (Canvas.Pen.Width - 1));
  if hasArrow and not (Next is TLine) then
  begin
    Wdth := Width;
    if (Next is TTransferLine) or (Next is TAlternative) or (arrowReversed) then
      Wdth := Wdth div 2;
    if not arrowReversed then
    begin
      Canvas.MoveTo(Wdth, Height div 2);
      Canvas.LineTo(Wdth - Height div 4 - 8, Height div 4);
      Canvas.MoveTo(Wdth, Height div 2);
      Canvas.LineTo(Wdth - Height div 4 - 8, Height - Height div 4);
    end
    else
    begin
      Canvas.MoveTo(Wdth, Height div 2);
      Canvas.LineTo(Wdth + Height div 4 + 8, Height div 4);
      Canvas.MoveTo(Wdth, Height div 2);
      Canvas.LineTo(Wdth + Height div 4 + 8, Height - Height div 4);
    end;
  end;
end;

procedure TLine.align();
begin
  Self.Width := LnW - MinW + Self.MinWidth;
  if Self.Prev is TSyntSymbol then
  begin
    Self.Top := (Self.prev as TSyntSymbol).Top + (Self.prev as TSyntSymbol).Height div 2 - Self.Height div 2 - 3;
    if Self.Prev is TVariable then
      Self.Left := (Self.Prev as TVariable).sqrBra[2].Left + (Self.Prev as TVariable).sqrBra[2].Width + 5
    else if Self.Prev is TConstant then
      Self.Left := (Self.Prev as TConstant).Left + (Self.Prev as TConstant).Width + 5;
  end
  else if Self.Prev is TSyntUnit then
  begin
    Self.Top := (Self.prev as TSyntUnit).Top;
    Self.Left := (Self.Prev as TSyntUnit).Left + (Self.Prev as TSyntUnit).Width;
  end
  else if Self.Prev is TTransferLine then
  begin
    Self.Top := (Self.prev as TTransferLine).TrLnElems[3].Top + (Self.prev as TTransferLine).TrLnElems[3].Height - Self.Height;
    Self.Left := (Self.Prev as TTransferLine).TrLnElems[3].Left + (Self.Prev as TTransferLine).TrLnElems[3].Width;
  end;
end;

end.

