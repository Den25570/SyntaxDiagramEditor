unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, Menus, ExtCtrls, Buttons, Point, Variable, Line,
  Alternative, SyntUnit, TransferLine, AlterFunctions, QSyntSymbol, ShapeMod,
  XPMan, Constant;

type
  TArrayOfComponents = array of TComponent;

  TArrayOfinteger = array of Integer;

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
    Closepage1: TMenuItem;
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
    ShowP: TBitBtn;
    AltCreatUpper: TBitBtn;
    xpmnfst1: TXPManifest;
    Wtf: TBitBtn;
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
  private
    procedure ResetStatement();
    procedure ShowPoints();
    procedure ShowPointsOnLines();
    procedure ShowMainPoint();
    procedure HidePoints();
    procedure LineCreate(Sender: TPoint);
    procedure DrawRightBorder();
    procedure ReConnection(Sender: TPoint);
    procedure ShowLowerPoints(Sender: TPoint);
    procedure CheckRigthBorderIntr(Obj: TLine);
    procedure VariableCreate(Sender: TPoint);
   // procedure VariableAlternativeCreate(Sender: TObject);
    procedure AlterCreate(Sender: TPoint);
    procedure AlterCreate2(Sender: TPoint);
    procedure TransferLineCreate(Sender: TPoint);
    procedure AlterEmptyCreate(Sender: TPoint);
    procedure ConstantAlternativeCreate(Sender: TPoint);
    procedure ConstantCreate(Sender: TPoint);
  public
    //Statement variables
    currentObject: integer;
    ObjectDeletedFlag: boolean;
    alt_Owner: TPoint;
    isUpperChoice: Boolean;

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
    procedure ObjectsAlign(AlignAlter: boolean);
    procedure RedrawAll();
  end;

const
  { TODO : Добавить все константы в список редактируемых элементов }
  MinW = 30;            //Минимальная длина
  LnW = 80;             //Стандартная длина
  LnH = 30;             //Стандартная высота
  ShiftHeight = 40;     //Расстояние между элементами альтернативы
  RightBorder = 1307;   //Правая граница
  LeftBorder = 208;     //Левая граница
  AlternativeHeight = ShiftHeight + ShiftHeight + ShiftHeight div 2 - 5;
  rightBorderMessage = 'You''ve reached right border' + #10 + 'if you want to continue drawing add transfer line or accept line compression';

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

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  MainPoint := TPoint.Create(Form1);
  MainPoint.Parent := Form1;
  MainPoint.Width := 9;
  MainPoint.Height := 17;
  MainPoint.Brush.Color := clLime;
  MainPoint.Pen.Color := clGreen;
  MainPoint.Visible := False;
  MainPoint.Shape := stRoundSquare;
  MainPoint.name := 'MainPoint';
  MainPoint.OnMouseDown := MainPointMouseDown;

  //Создание начальной линии
  StartLine := TLine.Create(Form1);
  StartLine.Left := sb1VarDef.Left;
  StartLine.Top := sb1VarDef.Top + LnW;

  // Задание списка
  Component_List_head := StartLine;
  Component_List_tail := StartLine;

 //Выравнивание элементов
  edtVarDef.Width := Canvas.TextWidth(edtVarDef.text);
  sb1VarDef.Left := edtVarDef.left - 5 - sb1VarDef.Width;
  sb2VarDef.Left := edtVarDef.left + edtVarDef.Width + 5;
  eq.Left := sb2VarDef.Left + sb2VarDef.Width + 5;
end;

procedure TForm1.ResetStatement();
begin
  currentObject := 0;
  HidePoints();
  RedrawAll();
end;

procedure TForm1.DrawRightBorder();
const
  Shft = 10;
  dstnc = 2;
var
  Y: integer;
begin
  Y := 0;
  while Y <= Height do
  begin
    Canvas.MoveTo(RightBorder, Y);
    Canvas.LineTo(RightBorder, Y + Shft);
    Y := Y + Shft + dstnc;
  end;
end;


//Перерисовка всех канвасов
procedure TForm1.RedrawAll();
var
  i: integer;
  obj: TLine;
begin
   //Перерисовка линий
  DrawRightBorder();
  for i := 0 to ComponentCount - 1 do
  begin
    if (Components[i] is TLine) then
    begin
      obj := (Form1.Components[i] as TLine);
      if (obj.hasArrow) then
        obj.LineDraw;
    end
    else if (Components[i] is TVariable) then
    begin
      (Components[i] as TVariable).sqrBra[1].Repaint;
      (Components[i] as TVariable).sqrBra[2].Repaint;
    end;
  end;
  for i := 0 to length(Alter) - 1 do
    AlterLineDraw(i);
  for i := 0 to Length(TrLines) - 1 do
    TrLines[i].Draw();
end;

{**************************************************************}
{                                                              }
{                   Расширение компонента                      }
{                                                              }
{**************************************************************}

procedure TForm1.ObjectsAlign(AlignAlter: Boolean);
var
  i: Integer;
  obj: TComponent;
  vrbl: TVariable;
  ln: TLine;                     
  cnst: TConstant;
begin
  ObjectDeletedFlag := false;

  obj := StartLine.Next;
  while obj <> nil do
  begin
    if (obj is TVariable) then
    begin
      vrbl := (obj as TVariable);
      vrbl.sqrBra[1].Left := ((obj as TVariable).Prev as TSyntUnit).Left + ((obj as TVariable).Prev as TSyntUnit).Width + 5;
      vrbl.Left := (obj as TVariable).sqrBra[1].Left + (obj as TVariable).sqrBra[1].Width + 4;
      vrbl.Top := (vrbl.prev as TLine).Top + (vrbl.prev as TLine).Height div 2 - vrbl.Height div 2 + 3;
      vrbl.sqrBra[2].Left := (obj as TVariable).Left + (obj as TVariable).Width + 4;
      vrbl.Align();
      obj := vrbl.Next;
    end
    else if (obj is TConstant) then
    begin
      cnst := (obj as TConstant);
      cnst.Top := (cnst.prev as TLine).Top + (cnst.prev as TLine).Height div 2 - cnst.Height div 2 + 3;
      cnst.Left := (cnst.prev as TLine).Left + (cnst.prev as TLine).Width + 5;
      obj := cnst.Next;
    end
    else if (obj is TLine) then
    begin
      ln := obj as TLine;
      if ln.Prev is TSyntSymbol then
      begin
        ln.Top := (ln.prev as TSyntSymbol).Top + (ln.prev as TSyntSymbol).Height div 2 - ln.Height div 2 - 3;
        if ln.Prev is TVariable then
          ln.Left := (ln.Prev as TVariable).sqrBra[2].Left + (ln.Prev as TVariable).sqrBra[2].Width + 5
        else if ln.Prev is TConstant then
          ln.Left := (ln.Prev as TConstant).Left + (ln.Prev as TConstant).Width + 5;
      end
      else if ln.Prev is TSyntUnit then
      begin
        ln.Top := (ln.prev as TSyntUnit).Top;
        ln.Left := (ln.Prev as TSyntUnit).Left + (ln.Prev as TSyntUnit).Width;
      end
      else if ln.Prev is TTransferLine then
      begin
        ln.Top := (ln.prev as TTransferLine).TrLnElems[3].Top + (ln.prev as TTransferLine).TrLnElems[3].Height - ln.Height;
        ln.Left := (ln.Prev as TTransferLine).TrLnElems[3].Left + (ln.Prev as TTransferLine).TrLnElems[3].Width;
      end;
      obj := ln.Next;
    end
    else if (obj is TTransferLine) then
    begin
      (obj as TTransferLine).Align();
      obj := (obj as TTransferLine).Next;
    end;
       //Смещение вниз, если преодолена правая граница
    if obj is TLine then
      CheckRigthBorderIntr(obj as TLine);
  end;
  if AlignAlter then
    for i := 0 to Length(Alter) - 1 do
      AlterAlign(i, false, true);
  RedrawAll();
end;

procedure TForm1.CheckRigthBorderIntr(Obj: TLine);
begin
  if ((Obj.Left + Obj.Width) >= RightBorder) and (not (Obj.Next is TTransferLine)) then
    MessageDlg(rightBorderMessage, mtInformation, [mbOK], 0)
end;

procedure TForm1.TransferLineCreate(Sender: TPoint);
var
  ind: Integer;
begin
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

procedure TForm1.ConstantCreate(Sender: TPoint);
var
  ln: TLine;
  buf_Component: TComponent;
begin
  Constant.StartSettings();
  Line := TLine.Create(Form1);

  //Редактирование списка
  ln := Sender.Owner as TLine;
  buf_Component := ln.Next;
  ln.Next := Constant;
  Constant.Prev := ln;
  Constant.Next := Line;
  Line.Next := buf_Component;
  Line.Prev := Constant;
  if (buf_Component is TSyntSymbol) then
    (buf_Component as TSyntSymbol).Prev := Line
  else if (buf_Component is TTransferLine) then
    (buf_Component as TTransferLine).Prev := Line
  else if buf_Component = nil then
    Component_List_tail := Line;
  ObjectsAlign(true);
end;

procedure TForm1.ConstantAlternativeCreate(Sender: TPoint);
var
  Alt: TAlternative;
  PBuf: TComponent;
begin
  //Создание переменной
  Constant.StartSettings();
  Alt := Sender.Owner as TAlternative;
  Constant.isAlter := True;
  Constant.Altindex := Alt.Altindex;

  //Создание линии
  Line := TLine.Create(Form1);

  //Редактирование списка
  PBuf := Alt.Next;
  Alt.Next := Constant;
  Constant.Prev := Alt;
  Constant.Next := Line;
  Line.Prev := Constant;
  Line.Next := PBuf;
  if PBuf is TSyntSymbol then
    (PBuf as TSyntSymbol).Prev := Line
  else if PBuf is TSyntUnit then
  begin
    if PBuf is TLine then
      (PBuf as TLine).Prev := Line
    else
      (PBuf as TAlternative).PPrevS[Alt.SubDepth - 1] := Line;
  end;

  ObjectsAlign(true);

end;

procedure TForm1.OnTextChange(Sender: TObject);
begin
  if Length((Sender as TEdit).text) = 0 then
    (Sender as TEdit).text := (Sender as TEdit).text + ' ';

  (Sender as TEdit).Width := Canvas.TextWidth((Sender as TEdit).text);
  ObjectsAlign(true)
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

procedure TForm1.VariableCreate(Sender: TPoint);
var
  buf_Component: TComponent;
  ln: TLine;
begin
  Variable := TVariable.Create(Form1);

  if ((Sender.Owner as TLine).Prev is TLine) and ((Sender.Owner as TLine).Next is TLine) then
  begin
    Variable.Next := (Sender.Owner as TLine).Next as TSyntUnit;
    (Variable.Next as TLine).Prev := Variable;
    Variable.Prev := (Sender.Owner as TLine).Prev as TSyntUnit;
    (Variable.Prev as TLine).Next := Variable;
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
    ln.Next := Variable;
    Variable.Prev := ln;
    Variable.Next := Line;
    Line.Next := buf_Component;
    Line.Prev := Variable;
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
  end;
  ObjectsAlign(true);
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
    end;
  end
  else if not (Sender as TPoint).isAlter then
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
      8:
        TransferLineCreate(Point);
    end
  end
  else if (Sender as TPoint).isAlter then
  begin
    Point := (Sender as TPoint);
    case currentObject of
      1:
        VariableCreate(Point);
      2:
        ConstantAlternativeCreate(Point);
      5:
        AlterAddLineCreate(Point);
    end;
  end;
  if hideP then
    ResetStatement();
end;

procedure TForm1.LineCreate(Sender: TPoint);
begin
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

procedure TForm1.ShowPointsOnLines;
var
  i: integer;
begin
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
  ShowMainPoint();
  for i := 0 to ComponentCount - 1 do
  begin
    if (Form1.Components[i] is TLine) then
    begin
      Ln := (Form1.Components[i] as TLine);
      if (Length(Ln.Points) > 0) and (Ln.Next <> nil) then
        Ln.ShowPoints()
      else if (Length(Ln.Points) > 0) and (Ln.Next = nil) then
        Ln.ShowPointsL();
    end
    else if (Form1.Components[i] is TAlternative) then
    begin
      Alternative := (Form1.Components[i] as TAlternative);
      Alternative.ShowPoints();
    end
  end;
end;

procedure TForm1.VarTestCreateClick(Sender: TObject);
begin
  if currentObject <> 1 then
  begin
    ShowPoints();
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
    edt1.Text := '-';
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
  obj: TSyntUnit;
begin
  //Первоначальное создание и настройка
  AlterStartSettings(ind);
  Alter[ind, 2].isUpper := isUpperChoice;
  Alter[ind, 1].isUpper := isUpperChoice;

  //Привязка левого пилона и носителя
  obj := (Sender.Owner as TSyntUnit);
  obj.Altindex := ind;
  Alter[ind, 2].AltLineIndex := Sender.altLineIndex;
  Alter[ind, 2].carringObject := obj;
  AltIndexesShift(obj, Sender.altLineIndex);
  obj.alternative[Sender.altLineindex] := Alter[ind, 2];

  if Sender = alt_Owner then
    AlterEmptyCreate(Sender);

  //Привязка правого пилона и носителя
  obj := (alt_Owner.Owner as TSyntUnit);
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
    ShowPointsOnLines();
    currentObject := 3;
    isUpperChoice := False;
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
    ShowPointsOnLines();
    currentObject := 3;
    isUpperChoice := True;
  end
  else
    ResetStatement();
end;

procedure TForm1.WtfClick(Sender: TObject);
var
  i, j: integer;
begin
  j := 0;
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TLine then
      Inc(j);
  ShowMessage('lines: ' + IntToStr(j));
end;

procedure TForm1.TransferLineClick(Sender: TObject);
begin
  if currentObject = 0 then
  begin
    ShowPointsOnLines();
    currentObject := 8;
  end
  else
    ResetStatement();
end;

procedure TForm1.btn5Click(Sender: TObject);
begin
  if currentObject = 0 then
  begin
    ShowPoints();
    currentObject := 2;
  end
  else
    ResetStatement();
end;

end.

