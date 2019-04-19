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

    isAlter : boolean;
    AltIndex : Integer;
  end;

implementation

end.
