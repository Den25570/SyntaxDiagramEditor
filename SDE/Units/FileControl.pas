unit FileControl;

interface

uses
  States, Registry;

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
    alternative: array[0..9] of integer;
    AlternativesNum: integer;
  end;

  TAlternativeProperties = record
    PointsNum: Integer;
    SubDepth: integer;
    AltIndex: Integer;
    pos: integer;
    //Ccûëêè
    PNextS: array[0..9] of integer;
    PPrevS: array[0..9] of integer;
    PNextSNum: Integer;
    PPrevSNum: Integer;
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
    Text: string[100];
    isVariable: Boolean;
  end;

  TTrLinesProperties = record
    //Ccûëêè
    Prev: integer;
    Next: integer;
    index: integer;
  end;

  TFileState = record
    LinesNum: integer;
    AlternativesNum: integer;
    SyntSymbolsNum: integer;
    TrLinesNum: integer;
    Lines: array[0..49] of TLineProperties;
    Alternatives: array[0..49] of TAlternativeProperties;
    SyntSymbols: array[0..49] of TSyntSymbolProperties;
    TrLines: array[0..49] of TTrLinesProperties;
  end;

  TSDEFile = file of TFileState;

var
  SDEF: TSDeFile;
  FilePath : string;

procedure AssignF(filePath: string);
procedure Save(filePath: string);
procedure SaveAs(filePath: string);
procedure TransformStateRecordToFileRecord(var FState: TFileState; const State: TState);
procedure TransformFileRecordToStateRecord(const FState: TFileState; var State: TState);
procedure Open(filePath: string);
procedure WriteinFile();
procedure ReadFromFile();

implementation

uses
  main;


procedure AssignF(filePath: string);
begin
  AssignFile(SDEF, filePath);
end;

procedure Save(filePath: string);
begin
  WriteinFile();
end;

procedure SaveAs(filePath: string);
begin
  WriteinFile();
end;

procedure Open(filePath: string);
begin
  ReadFromFile();
end;

procedure TransformStateRecordToFileRecord(var FState: TFileState; const State: TState);
var
  i, j: integer;
begin
  FState.LinesNum := Length(State.Lines);
  FState.AlternativesNum := Length(State.alternatives);
  FState.SyntSymbolsNum := Length(State.SyntSymbols);
  FState.TrLinesNum := Length(State.TrLines);
  for i := 0 to Length(State.Lines) - 1 do
  begin
    FState.Lines[i].hasArrow := State.Lines[i].hasArrow;
    FState.Lines[i].MinWidth := State.Lines[i].MinWidth;
    FState.Lines[i].arrowReversed := State.Lines[i].arrowReversed;
    FState.Lines[i].CurrentWidth := State.Lines[i].CurrentWidth;
    FState.Lines[i].PointsNum := State.Lines[i].PointsNum;
    FState.Lines[i].index := State.Lines[i].index;
    FState.Lines[i].Prev := State.Lines[i].Prev;
    FState.Lines[i].Next := State.Lines[i].Next;
    FState.Lines[i].AlternativesNum := Length(State.Lines[i].alternative);
    for j := 0 to Length(State.Lines[i].alternative) - 1 do
      FState.Lines[i].alternative[j] := State.Lines[i].alternative[j];
  end;
  for i := 0 to Length(State.alternatives) - 1 do
  begin
    FState.Alternatives[i].PointsNum := State.Alternatives[i].PointsNum;
    FState.Alternatives[i].SubDepth := State.Alternatives[i].SubDepth;
    FState.Alternatives[i].AltIndex := State.Alternatives[i].AltIndex;
    FState.Alternatives[i].pos := State.Alternatives[i].pos;
    FState.Alternatives[i].index := State.Alternatives[i].index;
    FState.Alternatives[i].carringObject := State.Alternatives[i].carringObject;
    FState.Alternatives[i].isUpper := State.Alternatives[i].isUpper;
    FState.Alternatives[i].isLoop := State.Alternatives[i].isLoop;
    FState.Alternatives[i].PylonShift := State.Alternatives[i].PylonShift;
    FState.Alternatives[i].altLineIndex := State.Alternatives[i].altLineIndex;
    FState.Alternatives[i].addHeight := State.Alternatives[i].addHeight;

    FState.Alternatives[i].PNextSNum := Length(State.Alternatives[i].PNextS);
    FState.Alternatives[i].PprevSNum := Length(State.Alternatives[i].PPrevS);
    for j := 0 to Length(State.Alternatives[i].PNextS) - 1 do
      FState.Alternatives[i].PNextS[j] := State.Alternatives[i].PNextS[j];
    for j := 0 to Length(State.Alternatives[i].PPrevS) - 1 do
      FState.Alternatives[i].PPrevS[j] := State.Alternatives[i].PPrevS[j];
  end;
  for i := 0 to Length(State.SyntSymbols) - 1 do
  begin
    FState.SyntSymbols[i].Prev := State.SyntSymbols[i].Prev;
    FState.SyntSymbols[i].Next := State.SyntSymbols[i].Next;
    FState.SyntSymbols[i].index := State.SyntSymbols[i].index;
    FState.SyntSymbols[i].Text := State.SyntSymbols[i].Text;
    FState.SyntSymbols[i].isVariable := State.SyntSymbols[i].isVariable;
  end;
  for i := 0 to Length(State.TrLines) - 1 do
  begin
    FState.TrLines[i].index := State.TrLines[i].index;
    FState.TrLines[i].Prev := State.TrLines[i].Prev;
    FState.TrLines[i].Next := State.TrLines[i].Next;
  end;
end;

procedure TransformFileRecordToStateRecord(const FState: TFileState; var State: TState);
var
  i, j: integer;
begin
  SetLength(State.Lines, FState.LinesNum);
  for i := 0 to FState.LinesNum - 1 do
  begin
    State.Lines[i].hasArrow := FState.Lines[i].hasArrow;
    State.Lines[i].MinWidth := FState.Lines[i].MinWidth;
    State.Lines[i].arrowReversed := FState.Lines[i].arrowReversed;
    State.Lines[i].CurrentWidth := FState.Lines[i].CurrentWidth;
    State.Lines[i].PointsNum := FState.Lines[i].PointsNum;
    State.Lines[i].index := FState.Lines[i].index;
    State.Lines[i].Prev := FState.Lines[i].Prev;
    State.Lines[i].Next := FState.Lines[i].Next;

    SetLength(State.Lines[i].alternative, FState.Lines[i].AlternativesNum);
    for j := 0 to FState.Lines[i].AlternativesNum - 1 do
      State.Lines[i].alternative[j] := FState.Lines[i].alternative[j];
  end;
  SetLength(State.Alternatives, FState.AlternativesNum);
  for i := 0 to FState.AlternativesNum - 1 do
  begin

    State.Alternatives[i].PointsNum := FState.Alternatives[i].PointsNum;
    State.Alternatives[i].SubDepth := FState.Alternatives[i].SubDepth;
    State.Alternatives[i].AltIndex := FState.Alternatives[i].AltIndex;
    State.Alternatives[i].pos := FState.Alternatives[i].pos;
    State.Alternatives[i].index := FState.Alternatives[i].index;
    State.Alternatives[i].carringObject := FState.Alternatives[i].carringObject;
    State.Alternatives[i].isUpper := FState.Alternatives[i].isUpper;
    State.Alternatives[i].isLoop := FState.Alternatives[i].isLoop;
    State.Alternatives[i].PylonShift := FState.Alternatives[i].PylonShift;
    State.Alternatives[i].altLineIndex := FState.Alternatives[i].altLineIndex;
    State.Alternatives[i].addHeight := FState.Alternatives[i].addHeight;

    SetLength(State.Alternatives[i].PNextS, FState.Alternatives[i].PNextSNum);
    SetLength(State.Alternatives[i].PPrevS, FState.Alternatives[i].PPrevSNum);
    for j := 0 to  FState.Alternatives[i].PNextSNum - 1 do
      State.Alternatives[i].PNextS[j] := FState.Alternatives[i].PNextS[j];
    for j := 0 to FState.Alternatives[i].PPrevSNum - 1 do
      State.Alternatives[i].PPrevS[j] := FState.Alternatives[i].PPrevS[j];
  end;
  SetLength(State.SyntSymbols, FState.SyntSymbolsNum);
  for i := 0 to FState.SyntSymbolsNum - 1 do
  begin
    State.SyntSymbols[i].Prev := FState.SyntSymbols[i].Prev;
    State.SyntSymbols[i].Next := FState.SyntSymbols[i].Next;
    State.SyntSymbols[i].index := FState.SyntSymbols[i].index;
    State.SyntSymbols[i].Text := FState.SyntSymbols[i].Text;
    State.SyntSymbols[i].isVariable := FState.SyntSymbols[i].isVariable;
  end;
  SetLength(State.TrLines, FState.TrLinesNum);
  for i := 0 to FState.TrLinesNum - 1 do
  begin
    State.TrLines[i].index := FState.TrLines[i].index;
    State.TrLines[i].Prev := FState.TrLines[i].Prev;
    State.TrLines[i].Next := FState.TrLines[i].Next;
  end;
end;

procedure WriteinFile();
var
  bufState: TFileState;
begin
  SaveProgramState();
  TransformStateRecordToFileRecord(bufState, PStates_head^);
  Rewrite(SDEF);
  Write(SDEF, bufState);
  CloseFile(SDEF);
  DeleteState();
end;

procedure ReadFromFile();
var
  bufState: TFileState;
begin
  Reset(SDEF);
  read(SDEF, bufState);
  NewState();
  TransformFileRecordToStateRecord(bufState, PStates_head^);
  RestoreProgramState();
  CloseFile(SDEF);
end;

end.

