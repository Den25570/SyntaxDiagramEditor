unit QEdit1;

interface

uses
  SysUtils, Classes, QControls, QStdCtrls;

type
  TEdit1 = class(TEdit)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TEdit1]);
end;

end.
