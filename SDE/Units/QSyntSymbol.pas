unit QSyntSymbol;

interface

uses
  SysUtils, Classes,QDialogs, QFileCtrls, StdCtrls, SyntUnit, Line;

type
  TSyntSymbol = class(TEdit)
  public
    //List connections
    Prev : TLine;
    Next : TLine;
    addres : Integer;
  end;

implementation

end.
