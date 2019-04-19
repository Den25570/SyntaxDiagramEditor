unit TransferLine;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Forms, Line, Alternative, Point,
  QEditMod, SyntUnit, QSyntSymbol, Variable;

type
  TTransferLine = class(TComponent)
  public
    Prev: TLine;
    Next: TLine;
    TrLnElems: array[1..3] of TPaintBox;
    procedure StartSettings(Sender: TLine);
    procedure Align();
    procedure Draw();
    procedure ListSet(Line_1, Line_2: TLine);
    function CalcHeightTop(): integer;
    function CalcHeightBottom(): integer;
  end;

 // 1 - Right
 // 2 - Main
 // 3 - Left

implementation

uses
  Main;

//Создание линии перехода
procedure TTransferLine.StartSettings(Sender: TLine);
begin
  TrLnElems[1] := TPaintBox.Create(Form1);
  TrLnElems[1].Parent := Form1;
  TrLnElems[2] := TPaintBox.Create(Form1);
  TrLnElems[2].Parent := Form1;
  TrLnElems[3] := TPaintBox.Create(Form1);
  TrLnElems[3].Parent := Form1;
  ListSet(Sender, Form1.Line);
  Align();
end;

procedure TTransferLine.ListSet(Line_1, Line_2: TLine);
begin
  Self.Prev := Line_1;
  Self.Next := Line_2;
  Line_1.Next := Self;
  if (Line_2 <> nil) then
    Line_2.prev := Self;
end;

//Alignment
procedure TTransferLine.Align();
var
  i: Integer;
  AddHeight : integer;
begin
  TrLnElems[1].Height := ShiftHeight div 2 + CalcHeightTop()+ 2*LnH;
  TrLnElems[1].Width := LnH;
  TrLnElems[1].Left := Prev.Width + Prev.Left;
  TrLnElems[1].Top := Prev.Top;
  TrLnElems[3].Height := ShiftHeight div 2 + CalcHeightBottom() + 2*LnH;
  TrLnElems[3].Width := LnH;
  TrLnElems[3].Left := LeftBorder - LnH;
  TrLnElems[3].Top := TrLnElems[1].Top + TrLnElems[1].Height - LnH;
  TrLnElems[2].Width := TrLnElems[1].Left - (TrLnElems[3].Left + LnH) ;
  TrLnElems[2].Height := LnH;
  TrLnElems[2].Left := TrLnElems[3].Left + TrLnElems[3].Width;
  TrLnElems[2].Top := TrLnElems[3].Top;
  Draw();
end;

//Рисование линии
procedure TTransferLine.Draw();
begin
  TrLnElems[1].Repaint;
  TrLnElems[1].Canvas.Pen.Width := 2;
  TrLnElems[2].Repaint;
  TrLnElems[2].Canvas.Pen.Width := 2;
  TrLnElems[3].Repaint;
  TrLnElems[3].Canvas.Pen.Width := 2;
  TrLnElems[1].Canvas.Rectangle(1, LnH div 2 - (TrLnElems[1].Canvas.Pen.Width - 1) ,1 + TrLnElems[1].Canvas.Pen.Width - 1, TrLnElems[1].Height - (LnH div 2) + TrLnElems[1].Canvas.Pen.Width);
  TrLnElems[2].Canvas.Rectangle(0, LnH div 2, TrLnElems[2].Width+1, (LnH div 2) + (TrLnElems[2].Canvas.Pen.Width - 1));
  TrLnElems[3].Canvas.Rectangle(TrLnElems[3].Width- 1, LnH div 2 - TrLnElems[1].Canvas.Pen.Width + 1, TrLnElems[3].Width, TrLnElems[3].Height - (LnH div 2)+ TrLnElems[1].Canvas.Pen.Width);
  TrLnElems[2].Canvas.MoveTo(TrLnElems[2].Width div 2, TrLnElems[2].Height div 2);
  TrLnElems[2].Canvas.LineTo(TrLnElems[2].Width div 2 + TrLnElems[2].Height div 4 + 8, TrLnElems[2].Height div 4);
  TrLnElems[2].Canvas.MoveTo(TrLnElems[2].Width div 2, TrLnElems[2].Height div 2);
  TrLnElems[2].Canvas.LineTo(TrLnElems[2].Width div 2 + TrLnElems[2].Height div 4 + 8, TrLnElems[2].Height - TrLnElems[2].Height div 4);
end;

function TTransferLine.CalcHeightTop(): integer;
var
  i: Integer;
  Highest: TAlternative;
  Ln: TLine;
  Alt: TAlternative;
begin
  Result := 0;
  Ln := Prev;
  Highest := nil;
  while (Ln <> nil) do
  begin
    for i := 0 to Length(Ln.alternative) - 1 do
    begin
      Alt := (Ln.alternative[i] as TAlternative);
      if ((Alt.Height + Alt.Top) > Result) and (not Alt.isUpper) then
      begin
        Result := Alt.Height + Alt.Top;
        Highest := Alt;
      end;
    end;
    if (Ln.Prev is TSyntSymbol) then
      Ln := (Ln.Prev as TSyntSymbol).Prev as TLine
    else
      Ln := nil;
  end;
  if Highest <> nil then
  Result := Result - highest.Top - lnH;
end;

function TTransferLine.CalcHeightBottom(): integer;
var
  i: Integer;
  Highest: TAlternative;
  Ln: TLine;
  Alt: TAlternative;
begin
  Result := 0;
  Ln := Next;
  Highest := nil;
  while (Ln <> nil) do
  begin
    for i := 0 to Length(Ln.alternative) - 1 do
    begin
      Alt := (Ln.alternative[i] as TAlternative);
      if ((Alt.Height + Alt.Top) > Result) and (Alt.isUpper) then
      begin
        Result := Alt.Height + Alt.Top;
        Highest := Alt;
      end;
    end;
    if (Ln.Next is TSyntSymbol) then
      Ln := (Ln.Next as TSyntSymbol).Next as TLine
    else
      Ln := nil;
  end;
  if Highest <> nil then
  Result := Result - highest.Top - lnH;
end;

end.

