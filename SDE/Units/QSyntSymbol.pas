unit QSyntSymbol;

interface

uses
  SysUtils, Classes,QDialogs, QFileCtrls, StdCtrls, SyntUnit;

type
  TSyntSymbol = class(TEdit)
  public
    //List connections
    Prev : TSyntUnit;
    Next : TSyntUnit;
    addres : Integer;
  end;

implementation

end.
