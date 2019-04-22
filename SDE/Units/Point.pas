unit Point;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls , Graphics;

type
  TPoint = class(TShape)
  public
    //Owner of the point
    Owner : TComponent;

    SubDepth : Integer;
    AltIndex : integer;
    isAlter : Boolean;
    altLineIndex : Integer;

    constructor Create(Aowner : TComponent);
  end;

implementation

uses Main, SyntUnit;

constructor TPoint.Create(Aowner : TComponent);
begin
   inherited;
   Parent := Form1;
   Height := 9;
   Width := 9;
   Shape := stRoundSquare;
   Brush.Color := clLime;
   Pen.Color := clGreen;
   visible := False;
   OnMouseDown := Form1.MainPointMouseDown;
end;

end.
