unit Alternative;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Point, line, Forms, SyntUnit;

type
  TAlternative = class(TSyntUnit)
  public
    PNextS: array of TLine;
    PPrevS: array of TLine;
    isUpper: Boolean;
    carringObject: TLine;
    PylonShift: Integer;
    altLineIndex: Integer;
    addHeight: Integer;
    procedure DrawleftPylon();
    procedure DrawRightPylon();
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
  Points[ind].Owner := Self;
  Points[ind].isALter := true;
  Points[ind].AltLineIndex := ind;
end;

procedure TAlternative.ShowPoints();
var
  i, j: Integer;
  ln: TLine;
begin
  if Length(Points) <> 0 then
  begin
    for i := 0 to length(PNextS) - 1 do
    begin
      Points[i].Top := PNextS[i].Top - PNextS[i].Height div 2;
      Points[i].Left := Left + (Width div 2) - Points[i].Width div 2;
      Points[i].Visible := True;
    end;
    Points[SubDepth].Top := Top + Height;
    Points[SubDepth].Left := Left + (Width div 2) - Points[SubDepth].Width div 2;
    Points[SubDepth].Visible := True;
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
    Canvas.Rectangle(Canvas.Pen.Width-1 ,0,Canvas.Pen.Width+1,Canvas.Pen.Width-1);
    Canvas.MoveTo(Canvas.Pen.Width, 0);
    Canvas.LineTo(Width,Width-Canvas.Pen.Width);
    Canvas.Rectangle(Width-(Canvas.Pen.Width-1),Width - Canvas.Pen.Width,Width,height-Width+Canvas.Pen.Width);
    for i := 1 to subDepth - 1 do
    begin
      T := ((PNextS[i - 1] as TLine).Top + (PNextS[i - 1] as TLine).Height div 2) - Top;
      Canvas.MoveTo(Width, T);
      Canvas.LineTo(Width div 2, T - Width div 2);
    end;
  end
  else if isUpper then
  begin

    for i := 1 to subDepth - 1 do
    begin
      T := ((PNextS[i - 1] as TLine).Top + (PNextS[i - 1] as TLine).Height div 2) - Top;
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
    Canvas.Rectangle(Width - (Canvas.Pen.Width-1) ,0, Width,Canvas.Pen.Width-1);
    Canvas.MoveTo(Width - Canvas.Pen.Width, 0);
    Canvas.LineTo(0,Width - Canvas.Pen.Width);
    Canvas.Rectangle(0,Width- Canvas.Pen.Width,Canvas.Pen.Width,height-Width+Canvas.Pen.Width-1);
    for i := 1 to subDepth - 1 do
    begin
      T := ((PPrevS[i - 1] as TLine).Top + (PPrevS[i - 1] as TLine).Height div 2) - Top;
      Canvas.MoveTo(0, T);
      Canvas.LineTo(Width div 2, T - Width div 2);
    end;
  end
  else if isUpper then
  begin
    Canvas.Rectangle(Width div 2, height + 1, Width div 2 + Canvas.Pen.Width - 1, Width);
    Canvas.MoveTo(Width div 2, Width);
    Canvas.LineTo(0, Width div 2);
    for i := 1 to subDepth - 1 do
    begin
      T := ((PPrevS[i - 1] as TLine).Top + (PPrevS[i - 1] as TLine).Height div 2) - Top;
      Canvas.MoveTo(0, T);
      Canvas.LineTo(Width div 2, T + Width div 2);
    end;
  end
end;

end.

