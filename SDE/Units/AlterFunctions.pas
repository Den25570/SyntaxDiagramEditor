unit AlterFunctions;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Forms, Line, Alternative, Point,
  Variable, SyntUnit, QSyntSymbol, Constant;

var
  Alter: array of array of TAlternative;

//Settings
procedure AlterStartSettings(var ind: Integer);
procedure LeftPylonSet(const ind: Integer);
procedure RightPylonSet(const ind: Integer);
procedure mainLineSet(const ind: Integer);
procedure StartPoint(const Sender: TAlternative);
procedure ShowPoints(Sender: TAlternative);
procedure NewLineSet(const ind: Integer);
procedure AltindexesShift(obj: TSyntUnit; alt_index: Integer);
procedure AlterLineDraw(ind: integer);
procedure AlterAlign(ind: integer; first, AlignAlter: boolean);
procedure AlterVerticalAlign(ind: integer);
procedure CalcLength(var Line_num, LineLength: Integer; index, subDepth: Integer);
procedure AlterLeftShift(index, subDepth: integer);
procedure AlterAddLineCreate(Sender: TPoint);
procedure AlignAllAlternatives();
procedure AlterLineCreate(Alt : TAlternative);
function FindNextAlternative(ind: integer): integer;
function FindTailAndCompare(ind1, ind2: integer): Boolean;
function FindHeadAndCompare(ind1, ind2: integer): Boolean;
function CheckIntersection(ind: Integer): boolean;
function FindWithinAlternatives(ind: Integer): Integer;

implementation

uses
  Main;

procedure AlterStartSettings(var ind: integer);
begin
  //Создание и подготовка элементов
  ind := Length(Alter);
  SetLength(Alter, ind + 1);
  SetLength(Alter[ind], 4);
  LeftPylonSet(ind);
  RightPylonSet(ind);
  mainLineSet(ind);

  //Настройка списка
  SetLength(Alter[ind, 1].PPrevS, 1);
  SetLength(Alter[ind, 3].PNextS, 1);
  Alter[ind, 3].PNextS[0] := Alter[ind, 2];
  Alter[ind, 2].Prev := Alter[ind, 3];
  Alter[ind, 2].Next := Alter[ind, 1];
  Alter[ind, 1].PPrevS[0] := Alter[ind, 2];
end;
//3

procedure LeftPylonSet(const ind: integer);
begin
  Alter[ind, 3] := TAlternative.Create(Form1);
  Alter[ind, 3].Parent := Form1;
  Alter[ind, 3].PylonShift := 0;
  Alter[ind, 3].subDepth := 1;
  Alter[ind, 3].Altindex := ind;
  Alter[ind, 3].Pylon := True;

  StartPoint(Alter[ind, 3]);

  StartPoint(Alter[ind, 3]);
  Alter[ind, 3].Points[1].SubDepth := 2;

end;

//1
procedure RightPylonSet(const ind: Integer);
begin
  Alter[ind, 1] := TAlternative.Create(Form1);
  Alter[ind, 1].Parent := Form1;
  Alter[ind, 1].PylonShift := 0;
  Alter[ind, 1].subDepth := 1;
  Alter[ind, 1].Altindex := ind;
  Alter[ind, 1].Pylon := True;
end;

procedure mainLineSet(const ind: Integer);
begin
  Alter[ind, 2] := TAlternative.Create(Form1);
  Alter[ind, 2].Parent := Form1;
  Alter[ind, 2].PylonShift := 0;
  Alter[ind, 2].subDepth := 1;
  Alter[ind, 2].Altindex := ind;
  Alter[ind, 2].isConnected := true;
  Alter[ind, 2].Pylon := False;
  Alter[ind, 2].Top := Alter[ind, 1].Top + Alter[ind, 1].Height - Alter[ind, 2].Height;
  StartPoint(Alter[ind, 2]);
end;

procedure NewLineSet(const ind: Integer);
begin
  Alter[ind, 2] := TAlternative.Create(Form1);
  Alter[ind, 2].Parent := Form1;
  Alter[ind, 2].PylonShift := 0;
  Alter[ind, 2].subDepth := 1;
  Alter[ind, 2].Altindex := ind;
  Alter[ind, 2].Pylon := False;
  StartPoint(Alter[ind, 2]);
end;

procedure StartPoint(const Sender: TAlternative);
var
  ind: Integer;
begin
  Sender.PointCreate(Form1.MainPoint, Form1);
  ind := Length(Sender.Points) - 1;
  Sender.Points[ind].Altindex := Sender.AltIndex;
  Sender.Points[ind].subDepth := 1;
end;

procedure ShowPoints(Sender: TAlternative);
var
  i, j: Integer;
  Len: Integer;
begin
  Len := Length(Alter[Sender.AltIndex]) - 1;
  for i := 0 to Length(Sender.Points) - 1 do
  begin
    for j := 1 to Len do
    begin
      if (Alter[Sender.AltIndex, j].SubDepth = Sender.Points[i].subDepth) and not (Alter[Sender.AltIndex, j].pylon) then
      begin
        Sender.Points[i].Top := Alter[Sender.AltIndex, j].Top - Alter[Sender.AltIndex, j].Height div 2;
        Break;
      end;
    end;
    if Sender.Points[i].SubDepth > Sender.SubDepth then
      Sender.Points[i].Top := Sender.Top + Sender.Height;

    Sender.Points[i].Left := Sender.Left + (Sender.Width div 2) - Sender.Points[i].Width div 2;
    Sender.Points[i].Visible := True;
  end;
end;

procedure AltIndexesShift(obj: TSyntUnit; alt_index: Integer);
var
  i: integer;
begin
  SetLength(obj.alternative, Length(obj.alternative) + 1);
  for i := Length(obj.alternative) - 2 downto alt_index do
  begin
    obj.alternative[i + 1] := obj.alternative[i];
    inc((obj.alternative[i + 1] as TAlternative).altLineindex);
  end;
end;

procedure AlterLineDraw(ind: integer);
var
  i: integer;
begin
  //Прорисовка всех компонентов альтернативы
  Alter[ind, 1].DrawRightPylon;
  Alter[ind, 2].LineDraw;
  Alter[ind, 3].DrawLeftPylon;
  for i := 4 to length(Alter[ind]) - 1 do
    Alter[ind, i].LineDraw;
end;

procedure AlignAllAlternatives();
var
  i: Integer;
begin
  for i := 0 to Length(Alter) - 1 do
    AlterAlign(i, True, true);
end;

procedure AlterAlign(ind: integer; first, AlignAlter: boolean);
var
  obj: TSyntUnit;
  i: Integer;
begin
  obj := Alter[ind, 1].carringObject;
  Alter[ind, 1].Width := LnH;
  Alter[ind, 3].Width := LnH;

  Alter[ind, 3].addHeight := ShiftHeight * FindWithinAlternatives(ind);
  Alter[ind, 3].Height := ShiftHeight + ShiftHeight div 2 - 5 + (ShiftHeight * (Alter[ind, 3].subdepth - 1)) + Alter[ind, 3].addHeight;
  Alter[ind, 1].Height := Alter[ind, 3].Height;

  Alter[ind, 1].Left := obj.Left + obj.Width - Alter[ind, 3].Width - Alter[ind, 3].Width * (length((Alter[ind, 1].carringObject as TLine).Alternative) - Alter[ind, 1].AltLineIndex);
  Alter[ind, 1].Top := obj.Top + (obj.Height div 2) + 1;
  if Alter[ind, 1].isUpper then
    Alter[ind, 1].Top := Alter[ind, 1].Top - Alter[ind, 1].Height - ALTER[ind, 1].Canvas.pen.width * 1;

  obj := Alter[ind, 3].carringObject;
  Alter[ind, 3].Left := obj.Left + Alter[ind, 3].Width * (Alter[ind, 3].AltLineIndex + 1);
  Alter[ind, 3].Top := Alter[ind, 1].Top;

  AlterVerticalAlign(ind);
  if CheckIntersection(ind) then
    i := 0;
     { TODO : Предупреждать о пересечении }

  //Выравнивание нижней части
  if AlignAlter then
    for i := 1 to Alter[ind, 1].subDepth do
      AlterLeftShift(ind, i);
end;

procedure AlterVerticalAlign(ind: integer);
var
  i: integer;
  Alt: TAlternative;
begin
  for i := Alter[ind, 3].SubDepth - 1 downto 0 do
  begin
    Alt := (Alter[ind, 3].PNextS[i] as TAlternative);
    Alt.Top := Alter[ind, 3].Top + Alter[ind, 3].Height - Alt.Height - ShiftHeight * ((Alter[ind, 3].SubDepth - 1) - i);
    if Alt.isUpper then
      Alt.Top := Alter[ind, 3].Top + (Alter[ind, 3].Top + Alter[ind, 3].Height - Alt.Top) - LnH;
  end;
end;

procedure CalcLength(var Line_num, LineLength: Integer; index, subDepth: Integer);
var
  Edt: TVariable;
  cnst: TConstant;
  obj: TComponent;
  SymbolsLength: Integer;
  TotalLength: Integer;
begin
  SymbolsLength := 0;
  Line_num := 0;
  obj := Alter[index, 3].PNextS[subDepth - 1];
  while obj <> nil do
    if (obj is TSyntSymbol) then
    begin
      if obj is TVariable then
      begin
        Edt := (obj as TVariable);
        SymbolsLength := SymbolsLength + (Edt.SqrBra[2].Left + Edt.SqrBra[2].Width) - Edt.SqrBra[1].Left + 10;
      end
      else if obj is TConstant then
      begin
        cnst := (obj as TConstant);
        SymbolsLength := SymbolsLength + cnst.Width + 10;
      end;
      obj := (obj as TSyntSymbol).Next;
    end
    else if (obj is Talternative) then
      if not ((obj as Talternative).pylon) then
      begin
        Line_num := Line_num + 1;
        obj := (obj as Talternative).Next;
      end
      else if ((obj as Talternative).pylon) then
        break;
  TotalLength := Alter[index, 1].left - (Alter[index, 3].left + Alter[index, 3].width);
  LineLength := TotalLength - SymbolsLength;
  LineLength := (LineLength div Line_num);
end;

procedure AlterLeftShift(index, subDepth: integer);
var
  Line_num: Integer;
  Alt: TAlternative;
  Edt: TVariable;
  obj: TComponent;
  LineLength: Integer;
  cnst: TConstant;
begin
  CalcLength(Line_num, LineLength, index, subDepth);

  //Если линия меньше минимального размера
  if LineLength < MinW then
  begin
    Alter[index, 1].carringObject.Width := Alter[index, 1].carringObject.Width + (MinW - LineLength);
    Alter[index, 3].carringObject.Width := Alter[index, 1].carringObject.Width;
    Form1.ObjectsAlign(true);
    AlterAlign(index, false, true);
  end;

  //Если на уровне всего одна линия
  if Line_num <= 1 then
  begin
    Alt := (Alter[index, 3].PNextS[subDepth - 1] as TAlternative);
    Alt.Height := LnH;
    Alt.Left := Alter[index, 3].left + Alter[index, 3].Width;
    Alt.Width := Alter[index, 1].Left - Alt.Left;
    Alt.Top := Alter[index, 3].Top + Alter[index, 3].Height - Alt.Height - ShiftHeight * (Alter[index, 3].subDepth - subDepth);
    if Alt.isUpper then
      Alt.Top := Alter[index, 3].Top + (Alter[index, 3].Top + Alter[index, 3].Height - Alt.Top) - LnH + 1;
  end;

  //Выравнивание уровней с более чем одной линией
  obj := Alter[index, 3].PNextS[subDepth - 1];
  Alt := (obj as TAlternative);
  Alt.Width := LineLength;
  Alt.Left := Alter[index, 3].left + Alter[index, 3].width;
  obj := (obj as TAlternative).Next;
  while obj <> nil do
    if (obj is TSyntSymbol) then
    begin
      if (obj is TVariable) then
      begin
        Edt := (obj as TVariable);
        Edt.SqrBra[1].left := (Edt.prev as TAlternative).left + (Edt.prev as TAlternative).Width + 5;
        Edt.Left := Edt.SqrBra[1].left + Edt.SqrBra[1].Width + 5;
        Edt.ALign();
      end
      else if (obj is TConstant) then
      begin
        cnst := (obj as TConstant);
        cnst.Left := (cnst.prev as TAlternative).Left + (cnst.prev as TAlternative).Width + 5;
      end;
      (obj as TSyntSymbol).Top := ((obj as TSyntSymbol).Prev as TAlternative).Top + ((obj as TSyntSymbol).Prev as TAlternative).Height div 2 - (obj as TSyntSymbol).Height div 2 + 3;
      obj := (obj as TSyntSymbol).Next;
    end
    else if (obj is TAlternative) then
      if not (obj as TAlternative).pylon then
      begin
        Alt := (obj as TAlternative);
        Alt.Width := LineLength;
        if (Alt.prev is TVariable) then
          Alt.Left := (Alt.prev as TVariable).sqrBra[2].left + (Alt.prev as TVariable).sqrBra[2].Width + 5
        else if (Alt.prev is TConstant) then
          Alt.Left := (Alt.prev as TConstant).left + (Alt.prev as TConstant).Width + 5;
        Alt.Top := (Alt.Prev as TSyntSymbol).Top + (Alt.Prev as TSyntSymbol  ).Height div 2 - Alt.Height div 2 - 3;
        Alt.isConnected := False;
        obj := Alt.Next;
      end
      else
        break;
  obj := Alter[index, 1].PPrevS[subDepth - 1];
  (obj as TAlternative).width := Alter[index, 1].Left - (obj as TAlternative).Left;
  (obj as TAlternative).isConnected := True;
  Form1.RedrawAll();
end;

procedure AlterAddLineCreate(Sender: TPoint);
var
  i, ind: integer;
  Symbol: TSyntSymbol;
  alt: TAlternative;
  obj: TComponent;
begin
  ind := Sender.AltIndex;

  Alter[ind, 1].height := Alter[ind, 1].height + ShiftHeight;
  Alter[ind, 3].height := Alter[ind, 1].height;
  if (Sender.Subdepth <= Alter[ind, 1].subDepth) then
    obj := Alter[ind, 3].PNextS[Sender.subDepth - 1]
  else

    obj := Alter[ind, 3].PNextS[Alter[ind, 3].subDepth - 1];


  //Сдвиг линий вниз
  for i := Sender.SubDepth to Alter[ind, 1].subDepth do
  begin
    obj := Alter[ind, 3].PNextS[i - 1];
    while obj <> nil do
    begin
      if obj is TAlternative then
      begin
        alt := (obj as TAlternative);
        if alt.pylon then
          obj := nil
        else if not alt.pylon then
        begin
          alt := (obj as TAlternative);
          inc(alt.subDepth);
          alt.IncPointSD;
          alt.Top := alt.Top + ShiftHeight;
          obj := alt.Next;
        end;
      end
      else if obj is TSyntSymbol then
      begin
        Symbol := (obj as TSyntSymbol);
        Symbol.Top := Symbol.Top + ShiftHeight;
        if Symbol is TVariable then
          (Symbol as TVariable).ALign;
        obj := Symbol.Next;
      end;
    end;
  end;

  //Создание новой линии
  i := Length(Alter[ind]);
  SetLength(Alter[ind], i + 1);
  Alter[ind, i] := TAlternative.Create(Form1);
  Alter[ind, i].Parent := Form1;
  Alter[ind, i].Width := Alter[ind, 1].Left - Alter[ind, 3].Left - Alter[ind, 3].width;
  Alter[ind, i].height := LnH;
  Alter[ind, i].LineSettings(Alter[ind, 1]);
  Alter[ind, i].subDepth := Sender.SubDepth;
  Alter[ind, i].PointCreate(Form1.MainPoint, Form1);
  Alter[ind, i].Points[0].isAlter := True;

  // Настройка списка
  SetLength(Alter[ind, 3].PNextS, Length(Alter[ind, 3].PNextS) + 1);
  SetLength(Alter[ind, 1].PPrevS, Length(Alter[ind, 1].PPrevS) + 1);
  for i := Alter[ind, 1].subDepth downto Sender.subDepth do
  begin
    Alter[ind, 3].PNextS[i] := Alter[ind, 3].PNextS[i - 1];
    Alter[ind, 1].PPrevS[i] := Alter[ind, 1].PPrevS[i - 1];
  end;
  i := Length(Alter[ind]) - 1;
  Alter[ind, 1].PPrevS[Sender.SubDepth - 1] := Alter[ind, i];
  Alter[ind, 3].PNextS[Sender.SubDepth - 1] := Alter[ind, i];
  Alter[ind, i].Next := Alter[ind, 1];
  Alter[ind, i].Prev := Alter[ind, 3];

  Alter[ind, 3].PointCreate(Form1.MainPoint, Form1);
  Inc(Alter[ind, 3].subDepth);
  Inc(Alter[ind, 1].subDepth);
  Alter[ind, 3].Points[Length(Alter[ind, 3].Points) - 1].subDepth := Alter[ind, 1].subDepth + 1;

  Form1.ObjectsAlign(true);
end;

function FindNextAlternative(ind: integer): integer;
var
  ln: TLine;
  Line_index: Integer;
  i: integer;
begin
  Result := -1;
  ln := Alter[ind, 3].carringObject as TLine;
  Line_index := Alter[ind, 3].AltLineIndex;
  while (ln <> (Alter[ind, 1].carringObject as TLine)) do
  begin
    for i := Line_index + 1 to Length(ln.alternative) - 1 do
    begin
      if (ln.alternative[i] as TAlternative) = Alter[(ln.alternative[i] as TAlternative).AltIndex, 3] then
      begin
        Result := (ln.alternative[i] as TAlternative).AltIndex;
        exit;
      end;
    end;
    if (ln.Next) is TSyntSymbol then
    ln := ((ln.Next) as TSyntSymbol).Next as TLine
    else if (ln.Next) is TSyntUnit then
    ln := ((ln.Next) as TSyntUnit).Next as TLine;
    Line_index := -1;
  end;
end;

function FindTailAndCompare(ind1, ind2: integer): Boolean;
var
  ln: TLine;
begin
  ln := Alter[ind2, 3].carringObject as TLine;
  Result := true;
  if (Alter[ind1, 1].carringObject as TLine) = (Alter[ind2, 1].carringObject as TLine) then
    Result := Alter[ind1, 1].AltLineIndex > Alter[ind2, 1].AltLineIndex
  else
    while (ln <> (Alter[ind1, 1].carringObject as TLine)) and (ln <> (Alter[ind2, 1].carringObject as TLine)) do
    begin
      ln := ((ln.Next) as TSyntSymbol).Next as TLine;
      if ln = Alter[ind1, 1].carringObject as TLine then
        Result := False
      else if ln = Alter[ind2, 1].carringObject as TLine then
        Result := True;
    end;
end;

function FindHeadAndCompare(ind1, ind2: integer): Boolean;
var
  ln: TLine;
begin
  ln := Alter[ind2, 1].carringObject as TLine;
  Result := true;
  if (Alter[ind1, 1].carringObject as TLine) = (Alter[ind2, 1].carringObject as TLine) then
    Result := Alter[ind1, 1].AltLineIndex > Alter[ind2, 1].AltLineIndex
  else
    while (ln <> (Alter[ind1, 3].carringObject as TLine)) and (ln <> (Alter[ind2, 3].carringObject as TLine)) do
    begin
      ln := ((ln.Prev) as TSyntSymbol).Prev as TLine;
      if ln = Alter[ind1, 3].carringObject as TLine then
        Result := False
      else if ln = Alter[ind2, 3].carringObject as TLine then
        Result := True;
    end;
end;

function CheckIntersection(ind: Integer): boolean;
var
  ln: TLine;
  alt: TAlternative;
  Line_index: Integer;
  i: integer;
begin
  Result := false;
  ln := Alter[ind, 3].carringObject as TLine;
  Line_index := Alter[ind, 3].AltLineIndex;

  while (ln <> (Alter[ind, 1].carringObject as TLine)) do
  begin
    for i := Line_index + 1 to Length(ln.alternative) - 1 do
    begin
      alt := ln.alternative[i] as TAlternative;
      if (alt = Alter[alt.AltIndex, 3]) and (alt.isUpper = Alter[ind, 3].isUpper) then
      begin
        Result := not FindTailAndCompare(ind, alt.AltIndex);
        if Result then
          Exit;
      end
      else if (alt = Alter[alt.AltIndex, 1]) and (alt.isUpper = Alter[ind, 1].isUpper) then
      begin
        Result := not FindHeadAndCompare(ind, alt.AltIndex);
        if Result then
          Exit;
      end
    end;
    if (ln.Next) is TSyntSymbol then
    ln := ((ln.Next) as TSyntSymbol).Next as TLine
    else if (ln.Next) is TSyntUnit then
    ln := ((ln.Next) as TSyntUnit).Next as TLine;
    Line_index := -1;
  end;
  for i := Line_index + 1 to ALTER[ind, 1].AltLineIndex - 1 do
  begin
    alt := ln.alternative[i] as TAlternative;
    if (alt = Alter[alt.AltIndex, 3]) and (alt.isUpper = Alter[ind, 3].isUpper) then
    begin
      Result := true;
      Exit;
    end
    else if (alt = Alter[alt.AltIndex, 1]) and (alt.isUpper = Alter[ind, 1].isUpper) then
    begin
      Result := not FindHeadAndCompare(ind, alt.AltIndex);
      if Result then
        Exit;
    end
  end;
end;

function FindWithinAlternatives(ind: Integer): Integer;
var
  new_index: Integer;
begin
  Result := 0;
  new_index := FindNextAlternative(ind);
  while new_index <> -1 do
  begin
    if Alter[new_index, 3].isUpper = Alter[ind, 3].isUpper then
      inc(Result, Alter[new_index, 3].subDepth);
    new_index := FindNextAlternative(new_index);
  end;
end;

procedure AlterLineCreate(Alt : TAlternative);
var
 i : Integer;
begin
  i := Length(Alter[Alt.Altindex]);
  SetLength(Alter[Alt.Altindex], i + 1);
  Alter[Alt.Altindex, i] := TAlternative.Create(Form1);
  Alter[Alt.Altindex, i].Parent := Form1;
  Alter[Alt.Altindex, i].Height := LnH;
  Alter[Alt.Altindex, i].LineSettings(Alt);
  Alter[Alt.Altindex, i].PointCreate(Form1.MainPoint, Form1);
  Alter[Alt.Altindex, i].OnClick := Form1.StartLineClick;
  Alter[Alt.Altindex, i].Points[0].isAlter := True;
end;

end.

