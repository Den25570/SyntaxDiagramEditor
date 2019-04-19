unit Point;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls;

type
  TPoint = class(TShape)
  public
    //Owner of the point
    Owner : TComponent;

    SubDepth : Integer;
    isAlter : Boolean;
    AltIndex : integer;
    altLineIndex : Integer;
  end;

implementation

end.
