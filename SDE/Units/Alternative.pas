unit Alternative;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Point, line, Forms, SyntUnit;

type
  TAlternative = class(TSyntUnit)
  public
    PNextS: array of TSyntUnit;
    PPrevS: array of TSyntUnit;

    isConnected,isUpper, pylon: Boolean;
    SubDepth: integer;
    carringObject: TSyntUnit;
    PylonShift: Integer;
    altLineIndex: Integer;
    addHeight: Integer;

    procedure LineDraw();
    procedure DrawleftPylon();
    procedure DrawRightPylon();
    procedure LineSettings(obj: TAlternative);
    procedure PointCreate(MPoint: TShape; Form: TForm);
    procedure ShowPoints;
  end;

implementation

procedure TAlternative.PointCreate(MPoint: TShape; Form: TForm);
var
  ind: Integer;
begin
  ind := Length(Points);
  SetLength(Points, ind + 1);
  Points[ind] := TPoint.Create(Form);
  Points[ind].Parent := Form;
  Points[ind].Height := 9;
  Points[ind].Width := 9;
  Points[ind].Shape := stRoundSquare;
  Points[ind].Brush := MPoint.Brush;
  Points[ind].Pen := MPoint.Pen;
  Points[ind].visible := False;
  Points[ind].Owner := Self;
  Points[ind].OnMouseDown := MPoint.OnMouseDown;
  Points[ind].isAlter := True;
  Points[ind].AltLineIndex := ind;
end;

procedure TAlternative.ShowPoints;
var
  i: Integer;
begin
  for i := 0 to Length(Points) - 1 do
  begin
    Points[i].Left := Left + (Width div 2) - Points[i].Width div 2;
    Points[i].Top := Top + (Height div 2) - Points[i].Height div 2;
    Points[i].Visible := True;
  end;
end;

procedure TAlternative.LineDraw;
begin
  Repaint;
  Canvas.Pen.Width := 2;
  Canvas.Rectangle(0,Height div 2,Width+1,Height div 2 + Canvas.Pen.Width -1);

  if isConnected then
  begin
    Canvas.MoveTo(width div 2, height div 2);
    Canvas.LineTo((width div 2) - (Height div 4) - 8, Height div 4);
    Canvas.MoveTo(width div 2, height div 2);
    Canvas.LineTo((width div 2) - Height div 4 - 8, Height - Height div 4);
  end
  else
  begin
    Canvas.MoveTo(width, height div 2);
    Canvas.LineTo((width) - (Height div 4) - 8, Height div 4);
    Canvas.MoveTo(width, height div 2);
    Canvas.LineTo((width) - Height div 4 - 8, Height - Height div 4);
  end;
end;

procedure TAlternative.DrawleftPylon;
var
  i: integer;
  T: integer;
begin
  Repaint;
  Canvas.Pen.Width := 2;

  if not isUpper then
  begin
    Canvas.MoveTo(Width div 2, 0);
    Canvas.LineTo(Width div 2, height - Width);
    Canvas.LineTo(Width, height - (Width div 2));
    for i := 1 to subDepth-1 do
    begin
      T := ((PNextS[i - 1] as TAlternative).Top + (PNextS[i - 1] as TAlternative).Height div 2) - Top;
      Canvas.MoveTo(Width, T);
      Canvas.LineTo(Width div 2, T - Width div 2);
    end;
  end
  else if isUpper then
  begin
    Canvas.MoveTo(Width div 2, height);
    Canvas.LineTo(Width div 2, Width);
    Canvas.LineTo(Width, Width div 2);
    for i := 1 to subDepth-1 do
    begin
      T := ((PNextS[i - 1] as TAlternative).Top + (PNextS[i - 1] as TAlternative).Height div 2) - Top;
      Canvas.MoveTo(Width, T);
      Canvas.LineTo(Width div 2, T + Width div 2);
    end;
  end;
end;

procedure TAlternative.DrawRightPylon;
var
  i: integer;
  T: integer;
begin
  Repaint;
  Canvas.Pen.Width := 2;

  if not isUpper then
  begin
    Canvas.Rectangle(Width div 2,0,Width div 2 + Canvas.Pen.Width - 1,Height - Width + 1);
    Canvas.MoveTo(Width div 2, height - (Width));
    Canvas.LineTo(0, height - (Width div 2));
    for i := 1 to subDepth-1 do
    begin
      T := ((PPrevS[i - 1] as TAlternative).Top + (PPrevS[i - 1] as TAlternative).Height div 2) - Top;
      Canvas.MoveTo(0, T);
      Canvas.LineTo(Width div 2, T - Width div 2);
    end;
  end
  else if isUpper then
  begin
    Canvas.Rectangle(Width div 2,height+1,Width div 2 + Canvas.Pen.Width - 1,Width);
    Canvas.MoveTo(Width div 2, Width);
    Canvas.LineTo(0, Width div 2);
    for i := 1 to subDepth-1 do
    begin
      T := ((PPrevS[i - 1] as TAlternative).Top + (PPrevS[i - 1] as TAlternative).Height div 2) - Top;
      Canvas.MoveTo(0, T);
      Canvas.LineTo(Width div 2, T + Width div 2);
    end;
  end
end;

procedure TAlternative.LineSettings;
begin
  SubDepth := obj.SubDepth;
  pylon := False;
  isConnected := True;
  AltIndex := obj.AltIndex;
  isUpper := obj.isUpper;
end;

end.

