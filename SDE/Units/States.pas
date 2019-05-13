unit States;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Point, line, SyntUnit, QSyntSymbol,
  Constant, Alternative, Variable, TransferLine, AlterFunctions;

type
  TLineProperties = record
    hasArrow: boolean;
    MinWidth: integer;
    arrowReversed: boolean;
    CurrentWidth: Integer;
    //Ccûëêè
    PointsNum: Integer;
    index: integer;
    Prev: Integer;
    Next: Integer;
    alternative: array of integer;
  end;

  TAlternativeProperties = record
    PointsNum: Integer;
    SubDepth: integer;
    AltIndex: Integer;
    pos : integer;
    //Ccûëêè
    PNextS: array of integer;
    PPrevS: array of integer;
    index: integer;
    carringObject: Integer;
    isUpper: Boolean;
    isLoop: Boolean;
    PylonShift: Integer;
    altLineIndex: Integer;
    addHeight: Integer;
  end;

  TSyntSymbolProperties = record
   //Ccûëêè
    Prev: integer;
    Next: integer;
    index: integer;
    Text: string;
    isVariable: Boolean;
  end;

  TTrLinesProperties = record
    //Ccûëêè
    Prev: integer;
    Next: integer;
    index: integer;
  end;

  TStatePointer = ^TState;

  TState = record
    Lines: array of TLineProperties;
    Alternatives: array of TAlternativeProperties;
    SyntSymbols: array of TSyntSymbolProperties;
    TrLines: array of TTrLinesProperties;
    Next: TStatePointer;
    varDefName : string;
  end;

var
  Pstates_head: TStatePointer;
  Pbuf_State: TStatePointer;
  Lines: array of TLine;
  Alternatives: array of TAlternative;
  SyntSymbols: array of TSyntSymbol;
  TrLines: array of TTransferLine;
  Syntunits: array of TSyntUnit;

procedure RestoreProgramState();
procedure SaveProgramState();
procedure DeleteAllObjects();
procedure DeleteState();
procedure NewState();
procedure restoreLines(State: TStatePointer);
procedure restoreAlternatives(State: TStatePointer);
procedure restoreSyntUnits(State: TStatePointer);
procedure restoreTrLines(State: TStatePointer);
procedure ReconnectAll(State: TStatePointer);
function TransformLine(Line: TLine): TLineProperties;
function TransformAlter(Alter: TAlternative): TAlternativeProperties;
function TransformSyntSymbol(SyntSymbol: TSyntSymbol): TSyntSymbolProperties;
function TransformTrLine(TrLine: TTransferLine): TTrLinesProperties;
function FindObjectWithAddress(State: TStatePointer; Address: integer): TComponent;

implementation

uses
  Main;

procedure DeleteAllObjects();
var
  i: Integer;
begin
  for i := 0 to Form1.ComponentCount - 1 do
  begin
    if Form1.Components[i] is TSyntUnit then
    begin
      Setlength(SyntUnits, Length(SyntUnits) + 1);
      SyntUnits[Length(SyntUnits) - 1] := (Form1.Components[i] as TSyntUnit);
    end
    else if Form1.Components[i] is TSyntSymbol then
    begin
      Setlength(SyntSymbols, Length(SyntSymbols) + 1);
      SyntSymbols[Length(SyntSymbols) - 1] := (Form1.Components[i] as TSyntSymbol);
    end
    else if Form1.Components[i] is TTransferLine then
    begin
      Setlength(TrLines, Length(TrLines) + 1);
      TrLines[Length(TrLines) - 1] := (Form1.Components[i] as TTransferLine);
    end
  end;
  for i := 0 to Length(SyntSymbols) - 1 do
  begin
    if SyntSymbols[i] is TVariable then
      (SyntSymbols[i] as TVariable).Destroy()
    else
    SyntSymbols[i].Destroy();
  end;
  for i := 0 to Length(SyntUnits) - 1 do
    SyntUnits[i].Destroy();
  for i := 0 to Length(TrLines) - 1 do
    TrLines[i].Destroy();

  SetLength(SyntSymbols, 0);
  SetLength(TrLines, 0);
  SetLength(Syntunits, 0);
  SetLength(Alter , 0);
end;

procedure restoreLines(State: TStatePointer);
var
  i, j: Integer;
begin
  Setlength(Lines, Length(State^.Lines));
  for i := 0 to Length(State^.Lines) - 1 do
  begin
    Lines[i] := TLine.Create(Form1);
    Lines[i].MinWidth := State^.Lines[i].MinWidth;
    Lines[i].hasArrow := State^.Lines[i].hasArrow;
    Lines[i].arrowReversed := State^.Lines[i].arrowReversed;
    Lines[i].CurrentWidth := State^.Lines[i].CurrentWidth;

    SetLength(Lines[i].alternative, Length(State^.Lines[i].alternative));
  //  SetLength(Lines[i].Points, State^.Lines[i].PointsNum);
    for j := 1 to State^.Lines[i].PointsNum - 1 do
      Lines[i].PointCreate(Form1.MainPoint, Form1);
  end;
end;

procedure restoreAlternatives(State: TStatePointer);
var
  i, j: Integer;
begin
  SetLength(Alter, 0);
  Setlength(Alternatives, Length(State^.Alternatives));
  SetLength(Alter, Length(Alternatives) div 2);
  for i := 0 to Length(State^.Alternatives) - 1 do
  begin
    Alternatives[i] := TAlternative.Create(Form1);
    Alternatives[i].Parent := Form1;
    Alternatives[i].isUpper := State^.Alternatives[i].isUpper;
    Alternatives[i].isLoop := State^.Alternatives[i].isLoop;
    Alternatives[i].PylonShift := State^.Alternatives[i].PylonShift;
    Alternatives[i].altLineIndex := State^.Alternatives[i].altLineIndex;
    Alternatives[i].AltIndex := State^.Alternatives[i].AltIndex;
    Alternatives[i].addHeight := State^.Alternatives[i].addHeight;
    Alternatives[i].SubDepth := State^.Alternatives[i].SubDepth;
    Alter[Alternatives[i].AltIndex, State^.Alternatives[i].Pos] := Alternatives[i];

    SetLength(Alternatives[i].PNextS, Length(State^.Alternatives[i].PNextS));
    SetLength(Alternatives[i].PPrevS, Length(State^.Alternatives[i].PPrevS));
 //   SetLength(Alternatives[i].Points, State^.Alternatives[i].PointsNum);
    for j := 0 to State^.Alternatives[i].PointsNum - 1 do
      Alternatives[i].PointCreate(Form1.MainPoint, Form1);
  end;
end;

procedure restoreSyntUnits(State: TStatePointer);
var
  i: Integer;
begin
  Setlength(SyntSymbols, Length(State^.SyntSymbols));
  for i := 0 to Length(State^.SyntSymbols) - 1 do
  begin
    if State^.SyntSymbols[i].isVariable then
      SyntSymbols[i] := TVariable.Create(Form1)
    else
      SyntSymbols[i] := TConstant.Create(Form1);
    SyntSymbols[i].Text := State^.SyntSymbols[i].Text;
  end;
end;

procedure restoreTrLines(State: TStatePointer);
var
  i: Integer;
begin
  Setlength(TrLines, Length(State^.TrLines));
  for i := 0 to Length(State^.TrLines) - 1 do
    TrLines[i] := TTransferLine.Create(Form1);
end;

function FindObjectWithAddress(State: TStatePointer; Address: integer): TComponent;
var
  i: Integer;
begin
  for i := 0 to Length(Lines) - 1 do
    if State^.Lines[i].index = Address then
    begin
      Result := Lines[i];
      Exit;
    end;
  for i := 0 to Length(State^.SyntSymbols) - 1 do
    if (State^.SyntSymbols[i].index = Address) then
    begin
      Result := SyntSymbols[i];
      Exit;
    end;
  for i := 0 to Length(Alternatives) - 1 do
    if State^.Alternatives[i].index = Address then
    begin
      Result := Alternatives[i];
      Exit;
    end;
  for i := 0 to Length(TrLines) - 1 do
    if State^.TrLines[i].index = Address then
    begin
      Result := TrLines[i];
      Exit;
    end;
  Result := nil;

end;

procedure ReconnectAll(State: TStatePointer);
var
  i, j: Integer;
begin
  for i := 0 to Length(Lines) - 1 do
  begin
    Lines[i].Next := FindObjectWithAddress(State, State^.Lines[i].Next);
    Lines[i].prev := FindObjectWithAddress(State, State^.Lines[i].prev);
    for j := 0 to length(Lines[i].Alternative) - 1 do
    begin
      Lines[i].Alternative[j] := FindObjectWithAddress(State, State^.Lines[i].Alternative[j]);
      (Lines[i].Alternative[j] as TAlternative).carringObject := Lines[i];
    end;
    if Lines[i].prev = nil then
      Form1.Component_list_head := Lines[i];
    if Lines[i].next = nil then
      Form1.Component_List_tail := Lines[i];
  end;
  for i := 0 to Length(Alternatives) - 1 do
  begin
    for j := 0 to length(Alternatives[i].PNextS) - 1 do
      Alternatives[i].PNextS[j] := FindObjectWithAddress(State, State^.Alternatives[i].PNextS[j]) as TLine;
    for j := 0 to length(Alternatives[i].PPrevS) - 1 do
      Alternatives[i].PPrevS[j] := FindObjectWithAddress(State, State^.Alternatives[i].PPrevS[j]) as TLine;
  end;
  for i := 0 to Length(State^.SyntSymbols) - 1 do
  begin
    SyntSymbols[i].Next := FindObjectWithAddress(State, State^.SyntSymbols[i].Next) as TLine;
    SyntSymbols[i].prev := FindObjectWithAddress(State, State^.SyntSymbols[i].prev) as TLine;
    SyntSymbols[i].OnChange := Form1.OnTextChange;
  end;
  for i := 0 to Length(TrLines) - 1 do
  begin
    TrLines[i].Next := FindObjectWithAddress(State, State^.TrLines[i].Next) as TLine;
    TrLines[i].prev := FindObjectWithAddress(State, State^.TrLines[i].prev) as TLine;
  end;
  for i := 0 to Length(State^.SyntSymbols) - 1 do
    Form1.OnTextChange(SyntSymbols[i]);
end;

procedure RestoreProgramState();
var
  State: TState;
begin
  if Pstates_head <> nil then
  begin
    State := Pstates_head^;
    DeleteAllObjects();
    restoreLines(Pstates_head);
    restoreAlternatives(Pstates_head);
    restoreSyntUnits(Pstates_head);
    restoreTrLines(Pstates_head);
    ReconnectAll(Pstates_head);

    SetLength(Lines, 0);
    SetLength(Alternatives, 0);
    SetLength(SyntSymbols, 0);
    SetLength(TrLines, 0);
    SetLength(Syntunits, 0);

    Form1.edtVarDef.text := State.varDefName;
    DeleteState();

    Form1.objectsAlign(true);
    Form1.objectsAlign(true);
  end;
end;

procedure DeleteState();
var
  buf_State: TStatePointer;
begin
  buf_State := Pstates_head;
  Pstates_head := Pstates_head^.Next;
  Dispose(buf_State);
end;

procedure NewState();
var
  PState: TStatePointer;
begin
  New(PState);
  PState^.Next := Pstates_head;
  Pstates_head := PState;
end;

procedure SaveProgramState();
var
  PState: TStatePointer;
  i: integer;
begin
  NewState();
  PState := Pstates_head;
  PState^.varDefName := Form1.edtvardef.text;
  for i := 0 to Form1.ComponentCount - 1 do
  begin
    if Form1.Components[i] is TLine then
    begin
      SetLength(PState^.Lines, Length(PState^.Lines) + 1);
      PState^.Lines[Length(PState^.Lines) - 1] := TransformLine(Form1.Components[i] as TLine);
    end
    else if Form1.Components[i] is TSyntSymbol then
    begin
      SetLength(PState^.SyntSymbols, Length(PState^.SyntSymbols) + 1);
      PState^.SyntSymbols[Length(PState^.SyntSymbols) - 1] := TransformSyntSymbol(Form1.Components[i] as TSyntSymbol);
    end
    else if Form1.Components[i] is TTransferLine then
    begin
      SetLength(PState^.TrLines, Length(PState^.TrLines) + 1);
      PState^.TrLines[Length(PState^.TrLines) - 1] := TransformTrLine(Form1.Components[i] as TTransferLine);
    end
  end;
  SetLength(PState^.Alternatives, Length(Alter)*2);
  for i := 0 to length(alter)-1 do
  BEGIN
   PState^.Alternatives[i*2] := TransformAlter(Alter[i,1]);
   PState^.Alternatives[i*2+1] := TransformAlter(Alter[i,2]);
  end;
end;

function TransformLine(Line: TLine): TLineProperties;
var
  i: integer;
begin
  Result.hasArrow := Line.hasArrow;
  Result.MinWidth := Line.minWidth;
  Result.arrowReversed := Line.arrowReversed;
  Result.CurrentWidth := Line.CurrentWidth;
  Result.PointsNum := Length(Line.Points);
  Result.index := (integer(Line));
  Result.Prev := integer(Line.Prev);
  Result.Next := integer(Line.Next);
  SetLength(Result.alternative, Length(Line.alternative));
  for i := 0 to Length(Line.alternative) - 1 do
    Result.alternative[i] := Integer(Line.alternative[i])
end;

function TransformAlter(Alter: TAlternative): TAlternativeProperties;
var
  i: integer;
begin
  Result.PointsNum := Length(Alter.Points);
  Result.SubDepth := Alter.Subdepth;
  Result.AltIndex := Alter.AltIndex;
  Result.index := Integer(Alter);
  Result.carringObject := Integer(Alter.carringObject);
  Result.isUpper := Alter.isUpper;
  Result.isLoop := Alter.isLoop;
  Result.PylonShift := Alter.PylonShift;
  Result.altLineIndex := Alter.altLineIndex;
  Result.addHeight := Alter.addHeight;
  if Alter = AlterFunctions.Alter[Alter.altindex, 1] then
    Result.Pos := 1
  else if Alter = AlterFunctions.Alter[Alter.altindex, 2] then
    Result.Pos := 2;
  SetLength(Result.PNextS, Length(Alter.PNextS));
  SetLength(Result.PPrevS, Length(Alter.PPrevS));
  for i := 0 to Length(Alter.PNextS) - 1 do
    Result.PNextS[i] := Integer(Alter.PNextS[i]);
  for i := 0 to Length(Alter.PPrevS) - 1 do
    Result.PPrevS[i] := Integer(Alter.PPrevS[i])
end;

function TransformSyntSymbol(SyntSymbol: TSyntSymbol): TSyntSymbolProperties;
begin
  Result.Prev := integer(SyntSymbol.Prev);
  Result.Next := integer(SyntSymbol.Next);
  Result.index := integer(SyntSymbol);
  Result.Text := SyntSymbol.Text;
  Result.isVariable := SyntSymbol is TVariable;
end;

function TransformTrLine(TrLine: TTransferLine): TTrLinesProperties;
begin
  Result.Prev := integer(TrLine.Prev);
  Result.Next := integer(TrLine.Next);
  Result.index := integer(TrLine);
end;

end.

