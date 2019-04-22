unit AlterFunctions;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Forms, Line, Alternative, Point,
  Variable, SyntUnit, QSyntSymbol, Constant;

var
  Alter: array of array[1..2] of TAlternative;
  Line: TLine;

//Settings
procedure AlterStartSettings(var ind: Integer);

procedure LeftPylonSet(const ind: Integer);

procedure RightPylonSet(const ind: Integer);

procedure StartPoint(const Sender: TAlternative);

procedure AltindexesShift(obj: TSyntUnit; alt_index: Integer);

procedure AlterLineDraw(ind: integer);

procedure AlterAlign(ind: integer; first, AlignAlter: boolean);

procedure AlterVerticalAlign(ind: integer);

procedure CalcLength(var Line_num, LineLength: Integer; index, subDepth: Integer);

procedure AlterLeftShift(index, subDepth: integer);

procedure AlterAddLineCreate(Sender: TPoint);

procedure AlignAllAlternatives();

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
  LeftPylonSet(ind);
  RightPylonSet(ind);

  Line := TLine.Create(Form1);
  Line.subDepth := 1;
  Line.AltIndex := ind;
  Line.Next := Alter[ind, 1];
  Line.Prev := Alter[ind, 2];

  //Настройка списка
  Alter[ind, 2].PNextS[0] := Line;
  Alter[ind, 1].PPrevS[0] := Line;
end;

procedure LeftPylonSet(const ind: integer);
begin
  Alter[ind, 2] := TAlternative.Create(Form1);
  Alter[ind, 2].Parent := Form1;
  Alter[ind, 2].PylonShift := 0;
  Alter[ind, 2].subDepth := 1;
  Alter[ind, 2].Altindex := ind;
  SetLength(Alter[ind, 2].PNextS, 1);

  StartPoint(Alter[ind, 2]);
  StartPoint(Alter[ind, 2]);
  Alter[ind, 2].Points[1].SubDepth := 2;
end;

procedure RightPylonSet(const ind: Integer);
begin
  Alter[ind, 1] := TAlternative.Create(Form1);
  Alter[ind, 1].Parent := Form1;
  Alter[ind, 1].PylonShift := 0;
  Alter[ind, 1].subDepth := 1;
  Alter[ind, 1].Altindex := ind;
  SetLength(Alter[ind, 1].PPrevS, 1);
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
  Alter[ind, 2].DrawLeftPylon;
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
  Alter[ind, 1].Width := LnH div 2;
  Alter[ind, 2].Width := LnH div 2;

  Alter[ind, 2].addHeight := ShiftHeight * FindWithinAlternatives(ind);
  Alter[ind, 2].Height := ShiftHeight + ShiftHeight div 2 - 5 + (ShiftHeight * (Alter[ind, 2].subdepth - 1)) + Alter[ind, 2].addHeight;
  Alter[ind, 1].Height := Alter[ind, 2].Height;

  Alter[ind, 1].Left := obj.Left + obj.Width - Alter[ind, 2].Width - Alter[ind, 2].Width*2  * (length((Alter[ind, 1].carringObject as TLine).Alternative) - Alter[ind, 1].AltLineIndex);
  Alter[ind, 1].Top := obj.Top + (obj.Height div 2)+1;
  if Alter[ind, 1].isUpper then
    Alter[ind, 1].Top := Alter[ind, 1].Top - Alter[ind, 1].Height - ALTER[ind, 1].Canvas.pen.width * 1;

  obj := Alter[ind, 2].carringObject;
  Alter[ind, 2].Left := obj.Left +   Alter[ind, 2].Width*2 * (Alter[ind, 2].AltLineIndex + 1);
  Alter[ind, 2].Top := Alter[ind, 1].Top;

  AlterVerticalAlign(ind);
 // if CheckIntersection(ind) then
 //   i := 0;
     { TODO : Предупреждать о пересечении }

  //Выравнивание нижней части
  if AlignAlter then
    for i := 1 to Alter[ind, 1].subDepth do
      AlterLeftShift(ind, i);
end;

procedure AlterVerticalAlign(ind: integer);
var
  i: integer;
  ln: TLine;
begin
  for i := Alter[ind, 2].SubDepth - 1 downto 0 do
  begin
    ln := (Alter[ind, 2].PNextS[i] as TLine);
    ln.Top := Alter[ind, 2].Top + Alter[ind, 2].Height - ln.Height - ShiftHeight * ((Alter[ind, 2].SubDepth - 1) - i);
    if Alter[ind, 2].isUpper then
      ln.Top := Alter[ind, 2].Top + (Alter[ind, 2].Top + Alter[ind, 2].Height - ln.Top) - LnH;
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
  obj := Alter[index, 2].PNextS[subDepth - 1];
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
    else if obj is TLine then
    begin
      Line_num := Line_num + 1;
      obj := (obj as TLine).Next;
    end
    else if (obj is Talternative) then
      break;
  TotalLength := Alter[index, 1].left - (Alter[index, 2].left + Alter[index, 2].width);
  LineLength := TotalLength - SymbolsLength;
  LineLength := (LineLength div Line_num);
end;

procedure AlterLeftShift(index, subDepth: integer);
var
  Line_num: Integer;
  ln: TLine;
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
    Alter[index, 2].carringObject.Width := Alter[index, 1].carringObject.Width;
    Form1.ObjectsAlign(true);
    Exit;
  end;

  //Если на уровне всего одна линия
  if Line_num <= 1 then
  begin
    ln := (Alter[index, 2].PNextS[subDepth - 1] as TLine);
    ln.Height := LnH;
    ln.Left := Alter[index, 2].left + Alter[index, 2].Width;
    ln.Width := Alter[index, 1].Left - ln.Left;
    ln.Top := Alter[index, 2].Top + Alter[index, 2].Height - ln.Height - ShiftHeight * (Alter[index, 2].subDepth - subDepth);
    if Alter[index, 2].isUpper then
      ln.Top := Alter[index, 2].Top + (Alter[index, 2].Top + Alter[index, 2].Height - ln.Top) - LnH + 1;
  end;

  //Выравнивание уровней с более чем одной линией
  obj := Alter[index, 2].PNextS[subDepth - 1];
  ln := (obj as TLine);
  ln.Width := LineLength;
  ln.Left := Alter[index, 2].left + Alter[index, 2].width;
  obj := (obj as TLine).Next;
  while obj <> nil do
    if (obj is TSyntSymbol) then
    begin
      if (obj is TVariable) then
      begin
        Edt := (obj as TVariable);
        Edt.SqrBra[1].left := (Edt.prev as TLine).left + (Edt.prev as TLine).Width + 5;
        Edt.Left := Edt.SqrBra[1].left + Edt.SqrBra[1].Width + 5;
        Edt.ALign();
      end
      else if (obj is TConstant) then
      begin
        cnst := (obj as TConstant);
        cnst.Left := (cnst.prev as TLine).Left + (cnst.prev as TLine).Width + 5;
      end;
      (obj as TSyntSymbol).Top := ((obj as TSyntSymbol).Prev as TLine).Top + ((obj as TSyntSymbol).Prev as TLine).Height div 2 - (obj as TSyntSymbol).Height div 2 + 3;
      obj := (obj as TSyntSymbol).Next;
    end
    else if (obj is TSyntUnit) then
      if obj is TLine then
      begin
        ln := (obj as TLine);
        ln.Width := LineLength;
        if (ln.prev is TVariable) then
          ln.Left := (ln.prev as TVariable).sqrBra[2].left + (ln.prev as TVariable).sqrBra[2].Width + 5
        else if (ln.prev is TConstant) then
          ln.Left := (ln.prev as TConstant).left + (ln.prev as TConstant).Width + 5
        else if (ln.prev is TSyntUnit) then
          ln.Left := (ln.prev as TSyntUnit).left + (ln.prev as TSyntUnit).Width;
        if (ln.Prev is TSyntSymbol) then
          ln.Top := (ln.Prev as TSyntSymbol).Top + (ln.Prev as TSyntSymbol).Height div 2 - ln.Height div 2 - 3
        else if (ln.Prev is TSyntUnit) then
          ln.Top := (ln.Prev as TSyntUnit).Top;
        obj := ln.Next;
      end
      else
        break;
  obj := Alter[index, 1].PPrevS[subDepth - 1];
  (obj as TLine).width := Alter[index, 1].Left - (obj as TLine).Left;
  Form1.RedrawAll();
end;

procedure AlterAddLineCreate(Sender: TPoint);
var
  i, ind: integer;
  Symbol: TSyntSymbol;
  ln: TLine;
  obj: TComponent;
begin
  ind := Sender.AltIndex;

  Alter[ind, 1].height := Alter[ind, 1].height + ShiftHeight;
  Alter[ind, 2].height := Alter[ind, 1].height;
  if (Sender.Subdepth <= Alter[ind, 1].subDepth) then
    obj := Alter[ind, 2].PNextS[Sender.subDepth - 1]
  else
    obj := Alter[ind, 2].PNextS[Alter[ind, 2].subDepth - 1];

  //Сдвиг линий вниз
  for i := Sender.SubDepth to Alter[ind, 1].subDepth do
  begin
    obj := Alter[ind, 2].PNextS[i - 1];
    while obj <> nil do
    begin
      if obj is TSyntUnit then
      begin
        if obj is TAlternative then
          obj := nil
        else if obj is TLine then
        begin
          ln := (obj as TLine);
          inc(ln.subDepth);
          ln.IncPointSD;
          ln.Top := ln.Top + ShiftHeight;
          obj := ln.Next;
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
  Line := TLine.Create(Form1);
  Line.SubDepth := Sender.SubDepth;
  Line.Points[0].subDepth := Sender.SubDepth;
  Line.Points[0].isAlter := True;

  // Настройка списка
  SetLength(Alter[ind, 2].PNextS, Length(Alter[ind, 2].PNextS) + 1);
  SetLength(Alter[ind, 1].PPrevS, Length(Alter[ind, 1].PPrevS) + 1);

  for i := Alter[ind, 1].subDepth downto Sender.subDepth do
  begin
    Alter[ind, 2].PNextS[i] := Alter[ind, 2].PNextS[i - 1];
    Alter[ind, 1].PPrevS[i] := Alter[ind, 1].PPrevS[i - 1];
  end;
  i := Length(Alter[ind]) - 1;
  Alter[ind, 1].PPrevS[Sender.SubDepth - 1] := Line;
  Alter[ind, 2].PNextS[Sender.SubDepth - 1] := Line;
  Line.Next := Alter[ind, 1];
  Line.Prev := Alter[ind, 2];

  Alter[ind, 2].PointCreate(Form1.MainPoint, Form1);
  Inc(Alter[ind, 2].subDepth);
  Inc(Alter[ind, 1].subDepth);
  Alter[ind, 2].Points[Length(Alter[ind, 2].Points) - 1].subDepth := Alter[ind, 1].subDepth + 1;

  Form1.ObjectsAlign(true);
end;

function FindNextAlternative(ind: integer): integer;
var
  ln: TLine;
  Line_index: Integer;
  i: integer;
begin
  Result := -1;
  ln := Alter[ind, 2].carringObject as TLine;
  Line_index := Alter[ind, 2].AltLineIndex;
  while (ln <> (Alter[ind, 1].carringObject as TLine)) do
  begin
    for i := Line_index + 1 to Length(ln.alternative) - 1 do
    begin
      if (ln.alternative[i] as TAlternative) = Alter[(ln.alternative[i] as TAlternative).AltIndex, 2] then
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
  ln := Alter[ind2, 2].carringObject as TLine;
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
    while (ln <> (Alter[ind1, 2].carringObject as TLine)) and (ln <> (Alter[ind2, 2].carringObject as TLine)) do
    begin
      ln := ((ln.Prev) as TSyntSymbol).Prev as TLine;
      if ln = Alter[ind1, 2].carringObject as TLine then
        Result := False
      else if ln = Alter[ind2, 2].carringObject as TLine then
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
  ln := Alter[ind, 2].carringObject as TLine;
  Line_index := Alter[ind, 2].AltLineIndex;

  while (ln <> (Alter[ind, 1].carringObject as TLine)) do
  begin
    for i := Line_index + 1 to Length(ln.alternative) - 1 do
    begin
      alt := ln.alternative[i] as TAlternative;
      if (alt = Alter[alt.AltIndex, 2]) and (alt.isUpper = Alter[ind, 2].isUpper) then
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
    if (alt = Alter[alt.AltIndex, 2]) and (alt.isUpper = Alter[ind, 2].isUpper) then
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
    if Alter[new_index, 2].isUpper = Alter[ind, 2].isUpper then
      inc(Result, Alter[new_index, 2].subDepth);
    new_index := FindNextAlternative(new_index);
  end;
end;

end.

