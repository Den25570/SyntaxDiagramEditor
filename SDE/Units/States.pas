unit States;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Point, line, SyntUnit, QSyntSymbol,
  Constant, Alternative, Variable, TransferLine;

type
  TStatePointer = ^TState;
  TState = record
    Lines: array of TLine;
    Alternatives : array of TAlternative;
    Variables: array of TVariable;
    Constants : array of TConstant;
    TrLines : array of TTransferLine;
    Next : TStatePointer;
  end;

type
     TStates = class
  public
     Pstates_head : TStatePointer;
     Pbuf_State : TStatePointer;
     procedure RestoreProgramState();
     procedure SaveProgramState();
  end;


implementation

uses Main;

procedure TStates.RestoreProgramState();
begin

end;

procedure TStates.SaveProgramState();
var
 i : Integer;
begin
   if Pstates_head = nil then
      New(Pstates_head)
   else
   begin
      Pbuf_State := Pstates_head;
      New(Pstates_head);
      Pbuf_State^.Next := Pstates_head;
   end;
   for i := 0 to Form1.ComponentCount-1 do
   begin
      if Form1.Components[i] is TLine then
      begin
        SetLength(Pstates_head^.Lines, Length(Pstates_head^.Lines)+1);
        Pstates_head^.Lines[Length(Pstates_head^.Lines)-1] := (Form1.Components[i] as TLine);
      end
      else if Form1.Components[i] is TAlternative then
      begin
        SetLength(Pstates_head^.Alternatives, Length(Pstates_head^.Alternatives)+1);
        Pstates_head^.Alternatives[Length(Pstates_head^.Alternatives)-1] := Form1.Components[i] as TAlternative;
      end
      else if Form1.Components[i] is TVariable then
      begin
        SetLength(Pstates_head^.Variables, Length(Pstates_head^.Variables)+1);
        Pstates_head^.Variables[Length(Pstates_head^.Variables)-1] := Form1.Components[i] as TVariable;
      end
      else if Form1.Components[i] is TConstant then
      begin
        SetLength(Pstates_head^.Constants, Length(Pstates_head^.Constants)+1);
        Pstates_head^.Constants[Length(Pstates_head^.Constants)-1] := Form1.Components[i] as TConstant;
      end
      else if Form1.Components[i] is TTransferLine then
      begin
        SetLength(Pstates_head^.TrLines, Length(Pstates_head^.TrLines)+1);
        Pstates_head^.TrLines[Length(Pstates_head^.TrLines)-1] := Form1.Components[i] as TTransferLine;
      end
   end;
end;

end.

