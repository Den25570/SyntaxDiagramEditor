unit SyntUnit;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Point, Forms;

type
  TSyntUnit = class(TPaintBox)
  public
    //List connections
    Prev : TComponent;
    Next : TComponent;
    alternative :array of TComponent;

    Points: array of TPoint;
    SubDepth: integer;
    AltIndex : Integer;
    CurrentWidth : Integer;
    addres : Integer;

    destructor Destroy();
    procedure PointCreate(MPoint:TShape; Form : TForm);  virtual; abstract;
    procedure ShowPoints;  virtual; abstract;
    procedure HidePoints;
    procedure IncPointSD;
  end;


implementation

destructor TSyntUnit.Destroy();
var
  i : integer;
begin
  for i := Length(Points)-1 downto 0 do
    Points[i].Destroy();
  inherited;
end;

procedure TSyntUnit.HidePoints;
var
i : Integer;
begin
  for i := 0 to Length(Points) - 1 do
    Points[i].Visible := False;
end;


procedure TSyntUnit.IncPointSD;
var
i : Integer;
begin
  for i := 0 to Length(Points) - 1 do
    Points[i].SubDepth := Points[i].SubDepth + 1;
end;

end.
