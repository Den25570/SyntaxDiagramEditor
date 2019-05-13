unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, Menus, ExtCtrls, Buttons, Point, Variable, Line,
  Alternative, SyntUnit, TransferLine, AlterFunctions, QSyntSymbol, XPMan,
  Constant, States, FileControl, Registry, ComCtrls, ExportUnit, MainMenu;

type
  TArrayOfComponents = array of TComponent;

  TArrayOfinteger = array of Integer;

  TShowPoint = procedure;

type
  TForm1 = class(TForm)
    MainMenu: TMainMenu;
    F1: TMenuItem;
    Options1: TMenuItem;
    Drawing1: TMenuItem;
    Save1: TMenuItem;
    Saveas1: TMenuItem;
    Open1: TMenuItem;
    Exit1: TMenuItem;
    Newpage1: TMenuItem;
    Language1: TMenuItem;
    Panel1: TPanel;
    eq: TStaticText;
    edtVarDef: TEdit;
    sb1VarDef: TStaticText;
    sb2VarDef: TStaticText;
    VarTestCreate: TBitBtn;
    btn5: TBitBtn;
    edt1: TEdit;
    pm1: TPopupMenu;
    E1: TMenuItem;
    AltCreate: TBitBtn;
    AddAlt: TBitBtn;
    AltCreatUpper: TBitBtn;
    xpmnfst1: TXPManifest;
    TransferLine: TBitBtn;
    Loop: TBitBtn;
    UpperLoop: TBitBtn;
    Line1: TMenuItem;
    Constant1: TMenuItem;
    Alternative1: TMenuItem;
    Loop1: TMenuItem;
    Upper1: TMenuItem;
    Bottom1: TMenuItem;
    Upper2: TMenuItem;
    Bottom2: TMenuItem;
    ransferLine1: TMenuItem;
    S1: TMenuItem;
    DrawSettings1: TMenuItem;
    Help1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    clear: TBitBtn;
    BMP1: TMenuItem;
    JPEG1: TMenuItem;
    SVG1: TMenuItem;
    N3: TMenuItem;
    XML1: TMenuItem;
    HTML1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure OnTextChange(Sender: TObject);
    procedure MainPointMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VarTestCreateClick(Sender: TObject);
    procedure StartLineClick(Sender: TObject);
    procedure AltCreateClick(Sender: TObject);
    procedure AddAltClick(Sender: TObject);
    procedure AltCreatUpperClick(Sender: TObject);
    procedure WtfClick(Sender: TObject);
    procedure TransferLineClick(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure LoopClick(Sender: TObject);
    procedure UpperLoopClick(Sender: TObject);
    procedure RestoreStateClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Saveas1Click(Sender: TObject);
    procedure clearClick(Sender: TObject);
    procedure BMP1Click(Sender: TObject);
    procedure JPEG1Click(Sender: TObject);
    procedure SVG1Click(Sender: TObject);
    procedure XML1Click(Sender: TObject);
    procedure HTML1Click(Sender: TObject);
  private
    isModified: Boolean;
    procedure ResetStatement();
    procedure ShowPoints();
    procedure ShowPointsOnLines();
    procedure ShowMainPoint();
    procedure HidePoints();
    procedure LineCreate(Sender: TPoint);
    procedure ReConnection(Sender: TPoint);
    procedure ListEdit(Sender: TPoint; SyntSymbol: TSyntSymbol);
    procedure ShowLowerPoints(Sender: TPoint);
    procedure VariableCreate(Sender: TPoint);
    procedure AlterCreate(Sender: TPoint);
    procedure AlterCreate2(Sender: TPoint);
    procedure TransferLineCreate(Sender: TPoint);
    procedure AlterEmptyCreate(Sender: TPoint);
    procedure ConstantCreate(Sender: TPoint);
  public
    //Statement variables
    currentObject: integer;
    ObjectDeletedFlag: boolean;
    alt_Owner: TPoint;
    isUpperChoice: Boolean;
    isLoop: Boolean;

    //ConstantElements
    StartLine: TLine;
    MainPoint: TPoint;
    st2: TStaticText;

    //List head
    Component_List_head: TLine;
    Component_List_tail: TLine;
    Line: TLine;
    Variable: TVariable;
    Constant: TConstant;
    TrLines: array of TTransferLine;
    ProgramStates: TState;
    procedure ObjectsAlign(AlignAlter: boolean);
    procedure RedrawAll();
  end;

const
  { TODO : Добавить все константы в список редактируемых элементов }
  MinW = 30;            //Минимальная длина
  LnW = 80;             //Стандартная длина
  LnH = 30;             //Стандартная высота
  ShiftHeight = 40;     //Расстояние между элементами альтернативы
  TopBorder = 100;
  LeftBorder = 30;
  RightBorder = 100;
  SBDistance = 5;
  VarDefStrtLnDistance = 50;
  ElemDistance = 5;
  AlternativeHeight = ShiftHeight + ShiftHeight + ShiftHeight div 2 - 5;

  // currentObject - Statements
  // 1 - Variable
  // 2 - Constant
  // 3 - Alternative
  // 4 _/
  // 5 - New alt Line
  // 6 - Loop
  // 7 _/
  // 8 - TransferLine

var
  Form1: TForm1;

implementation

uses
  ShellAPI;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  i: integer;
begin
  MainPoint := TPoint.Create(Form1);
  MainPoint.name := 'MainPoint';
  StartLine := TLine.Create(Form1);
  StartLine.Parent := Form1;
  Component_List_head := StartLine;
  Component_List_tail := StartLine;

  if ParamCount > 0 then
  begin
    FilePath := ParamStr(1);
    for i := 2 to ParamCount do
      FilePath := FilePath + ' ' + ParamStr(i);
    AssignF(FilePath);
    ReadFromFile();
  end;

  isModified := False;
  ObjectsAlign(false);

  enabled := False;
  SystemParametersInfo(SPI_SETBEEP, 0, nil, SPIF_SENDWININICHANGE);
end;

procedure TForm1.ResetStatement();
begin
  currentObject := 0;
  HidePoints();
  RedrawAll();
end;

//Перерисовка всех канвасов
procedure TForm1.RedrawAll();
var
  i: integer;
  obj: TLine;
begin
   //Перерисовка линий
  eq.Repaint;
  sb1VarDef.Repaint;
  sb2VarDef.Repaint;
  for i := 0 to ComponentCount - 1 do
  begin
    if (Components[i] is TLine) then
    begin
      obj := (Form1.Components[i] as TLine);
      if (obj.hasArrow) then
        obj.Draw;
    end
    else if (Components[i] is TVariable) then
    begin
      (Components[i] as TVariable).sqrBra[1].Repaint;
      (Components[i] as TVariable).sqrBra[2].Repaint;
    end
    else if (Components[i] is TButton) then
      (Components[i] as TButton).Repaint
  end;
  for i := 0 to length(Alter) - 1 do
    AlterLineDraw(i);
  for i := 0 to Length(TrLines) - 1 do
    TrLines[i].Draw();
end;

procedure AlignVariableDefinition();
begin
  with Form1 do
  begin
    sb1VarDef.Left := Panel1.Left + Panel1.Width + LeftBorder;
    edtVarDef.Left := sb1VarDef.Left + sb1VarDef.Width + SBDistance;
    sb2VarDef.Left := edtVarDef.left + edtVarDef.Width + SBDistance + 1;
    eq.Left := sb2VarDef.left + sb2VarDef.Width + ElemDistance;
  end;
end;

procedure TForm1.ObjectsAlign(AlignAlter: Boolean);
var
  i: Integer;
  obj: TComponent;
begin
  AlignVariableDefinition();
  obj := Component_List_head;
  (obj as TLine).Left := sb1VarDef.Left;
  (obj as TLine).Top := sb1VarDef.Top + VarDefStrtLnDistance;
  while obj <> nil do
  begin
    if (obj is TVariable) then
    begin
     (obj as TVariable).align();
      obj := (obj as TVariable).Next;
    end
    else if (obj is TConstant) then
    begin
     (obj as TConstant).align();
      obj := (obj as TConstant).Next;
    end
    else if (obj is TLine) then
    begin
      (obj as TLine).align();
      obj := (obj as TLine).Next;
    end
    else if (obj is TTransferLine) then
    begin
      (obj as TTransferLine).Align();
      obj := (obj as TTransferLine).Next;
    end;
  end;
  if AlignAlter then
    for i := 0 to Length(Alter) - 1 do
      AlterAlign(i, false, true);
  RedrawAll();
end;

procedure TForm1.TransferLineCreate(Sender: TPoint);
var
  ind: Integer;
begin
  isModified := true;
  SaveProgramState();
  ind := Length(TrLines);
  SetLength(TrLines, ind + 1);
  TrLines[ind] := TTransferLine.Create(Form1);
  Line := TLine.Create(Form1);
  if (Sender.Owner as TLine) = Component_List_tail then
    Component_List_tail := Line
  else
  begin
    Line.Next := (Sender.Owner as TLine).Next;
    if (Sender.Owner as TLine).Next is TVariable then
      ((Sender.Owner as TLine).Next as TVariable).Prev := Line
    else if (Sender.Owner as TLine).Next is TTransferLine then
      ((Sender.Owner as TLine).Next as TTransferLine).Prev := Line;
  end;
  TrLines[ind].StartSettings(Sender.Owner as TLine);
  ObjectsAlign(false);
end;

procedure TForm1.ListEdit(Sender: TPoint; SyntSymbol: TSyntSymbol);
var
  ln: TLine;
  buf_Component: TComponent;
begin
  if ((Sender.Owner as TLine).Prev is TLine) and ((Sender.Owner as TLine).Next is TLine) then
  begin
    SyntSymbol.Next := (Sender.Owner as TLine).Next as TLine;
    (SyntSymbol.Next as TLine).Prev := SyntSymbol;
    SyntSymbol.Prev := (Sender.Owner as TLine).Prev as TLine;
    (SyntSymbol.Prev as TLine).Next := SyntSymbol;
    (Sender.Owner as TLine).Destroy();
  end
  else
  begin
    ln := Sender.Owner as TLine;
    LineCreate(Sender);
    //Перепривзяка при сдвиге
    if Sender.Name <> 'MainPoint' then
      ReConnection(Sender);
    //Редактирование списка
    buf_Component := ln.Next;
    ln.Next := SyntSymbol;
    SyntSymbol.Prev := ln;
    SyntSymbol.Next := Line;
    Line.Next := buf_Component;
    Line.Prev := SyntSymbol;
    if (buf_Component is TSyntSymbol) then
      (buf_Component as TSyntSymbol).Prev := Line
    else if (buf_Component is TSyntUnit) then
    begin
      (buf_Component as TSyntUnit).Prev := Line;
      if (buf_Component is TAlternative) then
        (buf_Component as TAlternative).PPrevS[ln.subdepth - 1] := Line
    end
    else if (buf_Component is TTransferLine) then
      (buf_Component as TTransferLine).Prev := Line
    else if (buf_Component = nil) then
      Component_List_Tail := Line;

    if (Line.Prev is TSyntSymbol) then
      Line.arrowReversed := ((Line.Prev as TSyntSymbol).Prev as TLine).arrowReversed;
  end;
  SyntSymbol.OnChange := OnTextChange;
  ObjectsAlign(true);
  ObjectsAlign(true);
end;

procedure TForm1.ConstantCreate(Sender: TPoint);
var
  ln: TLine;
  buf_Component: TComponent;
begin
  isModified := true;
  SaveProgramState();
  Constant.StartSettings();
  ListEdit(Sender, Constant);
end;

procedure TForm1.VariableCreate(Sender: TPoint);
var
  buf_Component: TComponent;
  ln: TLine;
begin
  isModified := true;
  SaveProgramState();
  Variable := TVariable.Create(Form1);
  ListEdit(Sender, Variable);
end;

procedure TForm1.OnTextChange(Sender: TObject);
begin
  isModified := true;
  if Length((Sender as TEdit).text) = 0 then
    (Sender as TEdit).text := (Sender as TEdit).text + ' ';

  (Sender as TEdit).Width := Canvas.TextWidth((Sender as TEdit).text);
  ObjectsAlign(true);
end;


{**************************************************************************}
{                                                                          }
{                        Создание переменной                               }
{                                                                          }
{************************************************************************* }

function FontSetting(objtype: string): TFont;
begin
  if (objtype = 'var') then
    Result := Form1.edtVarDef.Font
  else
    Result := Form1.sb1VarDef.Font;
end;

procedure TForm1.ReConnection(Sender: TPoint);
var
  i, j: integer;
  Ln: TLine;
begin
  j := 0;
  Ln := (Sender as TPoint).Owner as TLine;
  SetLength(Line.alternative, Length(Ln.alternative) - (Sender as TPoint).altLineIndex);
  for i := (Sender as TPoint).altLineIndex to Length(((Sender as TPoint).Owner as TLine).alternative) - 1 do
  begin
    Line.alternative[i - (Sender as TPoint).altLineIndex] := Ln.alternative[i];
    (Line.alternative[i - (Sender as TPoint).altLineIndex] as TAlternative).altLineIndex := i - (Sender as TPoint).altLineIndex;
    (Line.alternative[i - (Sender as TPoint).altLineIndex] as TAlternative).carringObject := Line;
    Ln.Points[length(Ln.Points) - 1 - i].Owner := Line;
    SetLength(Line.Points, Length(Line.Points) + 1);
    Line.Points[Length(Line.Points) - 1] := Ln.Points[length(Ln.Points) - 1 - i];
    Inc(j);
  end;
  SetLength(Ln.alternative, Length(((Sender as TPoint).Owner as TLine).alternative) - j);
  SetLength(Ln.Points, Length(((Sender as TPoint).Owner as TLine).Points) - j);
end;

procedure TForm1.MainPointMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  hideP: Boolean;
  Point: TPoint;
begin
  hideP := True;
  if (Sender as TShape).Name = 'MainPoint' then
  begin
    Point := (Sender as TPoint);
    case currentObject of
      1:
        VariableCreate(Point);
      2:
        ConstantCreate(Point);
      8:
        TransferLineCreate(Point);
    end;
  end
  else
  begin
    Point := (Sender as TPoint);
    case currentObject of
      1:
        VariableCreate(Point);
      2:
        ConstantCreate(Point);
      3:
        begin
          AlterCreate(Point);
          hideP := false;
        end;
      4:
        AlterCreate2(Point);
      5:
        AlterAddLineCreate(Point);
      8:
        TransferLineCreate(Point);
    end;
  end;
  if hideP then
    ResetStatement();
end;

procedure TForm1.LineCreate(Sender: TPoint);
begin
  isModified := true;
  Line := TLine.Create(Form1);
  Line.SubDepth := Sender.SubDepth;
  Line.Points[0].SubDepth := Sender.SubDepth;
end;

//Скрытие точек
procedure TForm1.HidePoints;
var
  i: Integer;
begin
  MainPoint.Visible := false;
  for i := 0 to Form1.ComponentCount - 1 do
  begin
    if (Form1.Components[i] is TSyntUnit) then
      (Form1.Components[i] as TSyntUnit).HidePoints;
  end;
end;

//Отображение точек
procedure TForm1.ShowMainPoint;
begin
  MainPoint.Left := Component_List_tail.Left + Component_List_tail.Width;
  MainPoint.Top := Component_List_tail.Top + (Component_List_tail.Height div 2) - (MainPoint.Height div 2);
  MainPoint.Visible := true;
  MainPoint.Owner := Component_List_tail;
end;

procedure TForm1.ShowPointsOnLines();
var
  i: integer;
begin
  if (currentObject <> 3) and (currentObject <> 4) then
  begin
    ShowMainPoint();
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TLine then
        (Components[i] as TLine).ShowPointsL();
  end
  else
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TLine then
        (Components[i] as TLine).ShowPoints();

end;

procedure TForm1.ShowPoints();
var
  i: Integer;
  Ln: TLine;
  Alternative: TAlternative;
begin
  RedrawAll();
  for i := 0 to length(Alter) - 1 do
    Alter[i, 2].ShowPoints();
end;

procedure TForm1.VarTestCreateClick(Sender: TObject);
begin
  if currentObject <> 1 then
  begin
    ShowPointsOnLines();
    currentObject := 1;
  end
  else
    ResetStatement()
end;


{**************************************************************}
{                                                              }
{                   Создание линии                             }
{                                                              }
{**************************************************************}

{ TODO : Для отладки }
procedure TForm1.StartLineClick(Sender: TObject);
begin
  if (Sender is TLine) then
    edt1.Text := IntToStr((Sender as TLine).width);
  if (Sender is TVariable) then
    edt1.Text := (Sender as TVariable).Text;
  if (Sender is TAlternative) then
    edt1.Text := IntToStr((Sender as TAlternative).subDepth) + ',' + IntToStr((Sender as TAlternative).altLineIndex) + ',' + IntToStr((Sender as TAlternative).AltIndex);
end;


{**************************************************************}
{                                                              }
{                   Создание альтернативы                      }
{                                                              }
{**************************************************************}
procedure TForm1.ShowLowerPoints(Sender: TPoint);
var
  obj: TComponent;
begin
  HidePoints;
  RedrawAll;
  obj := (Sender.Owner as TSyntUnit);
  while obj <> nil do
  begin
    if obj is TLine then
      (obj as TLine).ShowPoints;

    if obj is TSyntUnit then
      obj := (obj as TSyntUnit).Prev
    else if obj is TSyntSymbol then
      obj := (obj as TSyntSymbol).Prev
    else if obj is TTransferLine then
      obj := nil;
  end;
end;

procedure TForm1.AlterCreate(Sender: TPoint);
begin
  ShowLowerPoints(Sender);
  alt_Owner := Sender;
  currentObject := 4;
end;

procedure TForm1.AlterCreate2(Sender: TPoint);
var
  ind: Integer;
  obj: TLine;
begin
  SaveProgramState();
  //Первоначальное создание и настройка
  AlterStartSettings(ind);

  //Привязка левого пилона и носителя
  obj := (Sender.Owner as TLine);
  obj.Altindex := ind;
  Alter[ind, 2].AltLineIndex := Sender.altLineIndex;
  Alter[ind, 2].carringObject := obj;
  AltIndexesShift(obj, Sender.altLineIndex);
  obj.alternative[Sender.altLineindex] := Alter[ind, 2];

  if Sender = alt_Owner then
    AlterEmptyCreate(Sender);

  //Привязка правого пилона и носителя
  obj := (alt_Owner.Owner as TLine);
  obj.Altindex := ind;
  Alter[ind, 1].AltLineIndex := alt_Owner.altLineIndex;
  Alter[ind, 1].carringObject := obj;
  AltIndexesShift(obj, alt_Owner.altLineIndex);
  obj.alternative[alt_Owner.altLineindex] := Alter[ind, 1];

  // Создание, прорисовка и настройка альтернатив
  (Alter[ind, 1].carringObject as TLine).PointCreate(MainPoint, Form1);
  (Alter[ind, 2].carringObject as TLine).PointCreate(MainPoint, Form1);
  Alter[ind, 2].OnClick := StartLineClick;
  Alter[ind, 1].OnClick := StartLineClick;

  ObjectsAlign(true);
end;

procedure TForm1.AlterEmptyCreate(Sender: TPoint);
var
  buf_comp: TComponent;
begin
  LineCreate(Sender);
  buf_comp := (Sender.Owner as TLine).Next;
  (Sender.Owner as TLine).Next := Line;
  Line.Prev := (Sender.Owner as TLine);
  LineCreate(Sender);
  ((Sender.Owner as TLine).Next as TLine).Next := Line;
  Line.Prev := ((Sender.Owner as TLine).Next as TLine);
  Line.Next := buf_comp;

  if buf_comp <> nil then
  begin
    if buf_comp is TSyntSymbol then
      (buf_comp as TSyntSymbol).prev := Line
    else if buf_comp is TLine then
      (buf_comp as TLine).prev := Line
    else if buf_comp is TAlternative then
      (buf_comp as TAlternative).PprevS[Sender.Subdepth - 1] := Line;
  end
  else
    Component_List_tail := Line;

  alt_Owner := Line.Points[0];
end;

procedure TForm1.AltCreateClick(Sender: TObject);
begin
  if currentObject = 0 then
  begin
    currentObject := 3;
    ShowPointsOnLines();
    isUpperChoice := False;
    isLoop := False;
  end
  else
    ResetStatement();
end;

procedure TForm1.AddAltClick(Sender: TObject);
var
  i: Integer;
begin
  if currentObject <> 5 then
  begin
    for i := 0 to ComponentCount - 1 do
    begin
      if Form1.Components[i] is TAlternative then
        (Form1.Components[i] as TAlternative).ShowPoints();
    end;
    currentObject := 5;
  end
  else
    ResetStatement();
end;

procedure TForm1.AltCreatUpperClick(Sender: TObject);
begin
  if currentObject = 0 then
  begin
    currentObject := 3;
    ShowPointsOnLines();
    isUpperChoice := True;
    isLoop := False;
  end
  else
    ResetStatement();
end;

procedure TForm1.WtfClick(Sender: TObject);
begin
  SaveProgramState();
end;

procedure TForm1.TransferLineClick(Sender: TObject);
begin
  if currentObject = 0 then
  begin
    currentObject := 8;
    ShowPointsOnLines();
  end
  else
    ResetStatement();
end;

procedure TForm1.btn5Click(Sender: TObject);
begin
  if currentObject = 0 then
  begin
    currentObject := 2;
    ShowPointsOnLines();
  end
  else
    ResetStatement();
end;

procedure TForm1.LoopClick(Sender: TObject);
begin
  if currentObject = 0 then
  begin
    currentObject := 3;
    ShowPointsOnLines();
    isUpperChoice := False;
    isLoop := True;
  end
  else
    ResetStatement();
end;

procedure TForm1.UpperLoopClick(Sender: TObject);
begin
  if currentObject = 0 then
  begin
    currentObject := 3;
    ShowPointsOnLines();
    isUpperChoice := True;
    isLoop := True;
  end
  else
    ResetStatement();
end;

procedure TForm1.RestoreStateClick(Sender: TObject);
begin
  RestoreProgramState();
end;

procedure TForm1.N2Click(Sender: TObject);
begin
  RestoreProgramState();
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Form1.Close();
end;

procedure TForm1.Open1Click(Sender: TObject);
begin
  if dlgOpen.Execute then
  begin
    FilePath := dlgOpen.FileName;
    AssignF(FilePath);
    ReadFromFile();
  end;
end;

//Run only with administrator rights!!
{procedure ExtensionRegister();
var
  reg: Tregistry;
begin
  reg := TRegistry.Create();
  with reg do
  begin
    RootKey := HKEY_CLASSES_ROOT;
    OpenKey('.sde', true);
    WriteString('', 'SDE');
    CloseKey;

    CreateKey('SDE');
    OpenKey('SDE\DefaultIcon', true);
    WriteString('', Application.ExeName + ', 0');
    CloseKey;

    OpenKey('SDE\shell\open\command', true);
    WriteString('', Application.ExeName + ' %1');
    CloseKey;
    Free;
  end;
end; }

procedure TForm1.Save1Click(Sender: TObject);
begin
  if FilePath <> '' then
  begin
    WriteinFile();
    isModified := false;
  end
  else
    Saveas1Click(Sender);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  buttonSelected: Integer;
begin
  CanClose := True;
  if isModified then
  begin
    buttonSelected := MessageDlg('Save Changes?', mtConfirmation, mbYesNoCancel, 0);
    if buttonSelected = mrYes then
      WriteinFile()
    else if buttonSelected = mrCancel then
      CanClose := False;
  end;
end;

procedure TForm1.Saveas1Click(Sender: TObject);
begin
  dlgSave.Filter := '*.SDE|*.SDE';
  if dlgSave.Execute then
  begin
    filepath := dlgSave.FileName;

    FilePath := dlgSave.FileName;
    if ansipos('.', filepath) = 0 then
      FilePath := FilePath + '.sde';
    AssignF(FilePath);
    WriteInFile();
    isModified := false;
  end;
end;

procedure TForm1.clearClick(Sender: TObject);
begin
  SaveProgramState();
  DeleteAllObjects();
  StartLine := TLine.Create(Form1);
  StartLine.Parent := Form1;
  Component_List_head := StartLine;
  Component_List_tail := StartLine;
  edtVarDef.text := 'переменная';
  ObjectsAlign(false);
end;

procedure TForm1.BMP1Click(Sender: TObject);
var
  filepath: string;
begin
  dlgSave.Filter := '*.BMP|*.BMP';
  if dlgSave.Execute then
  begin
    filepath := dlgSave.FileName;
    if ansipos('.', filepath) <> 0 then
      ExportBMP(filepath)
    else
    begin
      ExportBMP(filepath + '.bmp');
    end;
  end;
end;

procedure TForm1.JPEG1Click(Sender: TObject);
var
  filepath: string;
begin
  dlgSave.Filter := '*.JPG|*.jpg';
  if dlgSave.Execute then
  begin
    filepath := dlgSave.FileName;
    if ansipos('.', filepath) <> 0 then
      ExportJPEG(filepath)
    else
    begin
      ExportJPEG(filepath + '.jpg');
    end;
  end;
end;

procedure TForm1.SVG1Click(Sender: TObject);
var
  filepath: string;
begin
  dlgSave.Filter := '*.XML|*.SVG';
  if dlgSave.Execute then
  begin
    filepath := dlgSave.FileName;
    if ansipos('.', filepath) <> 0 then
      ExportSVG(filepath)
    else
    begin
      ExportSVG(filepath + '.svg');
    end;
  end;
end;

procedure TForm1.XML1Click(Sender: TObject);
var
  filepath: string;
begin
  dlgSave.Filter := '*.XML|*.XML';
  if dlgSave.Execute then
  begin
    filepath := dlgSave.FileName;
    if ansipos('.', filepath) <> 0 then
      ExportSVG(filepath)
    else
    begin
      ExportSVG(filepath + '.xml');
    end;
  end;
end;

procedure TForm1.HTML1Click(Sender: TObject);
var
  filepath: string;
begin
  dlgSave.Filter := '*.HTML|*.HTML';
  if dlgSave.Execute then
  begin
    filepath := dlgSave.FileName;
    if ansipos('.', filepath) <> 0 then
      ExportSVG(filepath)
    else
    begin
      ExportSVG(filepath + '.html');
    end;
  end;
end;

end.

