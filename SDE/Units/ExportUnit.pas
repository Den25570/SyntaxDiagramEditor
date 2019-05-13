unit ExportUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, Menus, ExtCtrls, Buttons, Point, Variable, Line,
  Alternative, SyntUnit, TransferLine, AlterFunctions, QSyntSymbol, XPMan,
  Constant, States, FileControl, Registry, ComCtrls, jpeg;

type
  TSize = record
    width: Integer;
    height: Integer;
  end;

var
  Border: Integer;
  SvgFile: TextFile;

function GetSize(AOwner: TComponent): TSize;

procedure ConevertToBitMap(var BitMap: TBitMap);
procedure ExportBMP(FileName: string);
procedure ExportSVG(FileName: string);
procedure ExportJPEG(FileNAME: string);

//BMP
procedure DrawLine(BitMap: TBitMap; ln: TLine); overload;
procedure DrawAlternative(BitMap: TBitMap; altr1, altr2: TAlternative); overload;
procedure DrawTransferLine(BitMap: TBitMap; trln: TTransferLine); overload;
procedure DrawSyntSymbol(BitMap: TBitMap; ss: TSyntSymbol); overload;
procedure DrawDefinition(BitMap: TBitMap); overload;

//SVG
procedure DrawLine(ln: TLine); overload;
procedure DrawAlternative(altr1, altr2: TAlternative); overload;
procedure DrawTransferLine(trln: TTransferLine); overload;
procedure DrawSyntSymbol(ss: TSyntSymbol); overload;
procedure DrawDefinition(); overload;

implementation

uses
  Main;

function GetSize(AOwner: TComponent): TSize;
var
  i: integer;
begin
  Result.width := Form1.eq.Left + Form1.eq.Width;
  Result.height := 0;
  for i := 0 to Form1.ComponentCount - 1 do
  begin
    if Form1.Components[i] is TLine then
    begin
      if Result.width < ((Form1.Components[i] as TLine).Left + (Form1.Components[i] as TLine).Width) then
        Result.width := ((Form1.Components[i] as TLine).Left + (Form1.Components[i] as TLine).Width);
      if Result.height < ((Form1.Components[i] as TLine).Top + (Form1.Components[i] as TLine).Height) then
        Result.height := ((Form1.Components[i] as TLine).Top + (Form1.Components[i] as TLine).Height);
    end
    else if Form1.Components[i] is TTransferLine then
    begin
      if Result.width < ((Form1.Components[i] as TTransferLine).TrLnElems[1].Left + (Form1.Components[i] as TTransferLine).TrLnElems[1].Width) then
        Result.width := ((Form1.Components[i] as TTransferLine).TrLnElems[1].Left + (Form1.Components[i] as TTransferLine).TrLnElems[1].Width);
      if Result.height < ((Form1.Components[i] as TTransferLine).TrLnElems[1].Top + (Form1.Components[i] as TTransferLine).TrLnElems[1].Height) then
        Result.height := ((Form1.Components[i] as TTransferLine).TrLnElems[1].Top + (Form1.Components[i] as TTransferLine).TrLnElems[1].Height);
    end
    else if Form1.Components[i] is TAlternative then
    begin
      if Result.height < ((Form1.Components[i] as TAlternative).TOp + (Form1.Components[i] as TAlternative).Height) then
        Result.height := ((Form1.Components[i] as TAlternative).TOp + (Form1.Components[i] as TAlternative).Height);
    end;
  end;
  Result.width := Result.width - Form1.sb1VarDef.Left;
  Result.height := Result.height - Form1.sb1VarDef.Top;
end;

procedure ConevertToBitMap(var BitMap: TBitMap);
var
  ImageSize: TSize;
  ln: TLine;
  sq: TSyntSymbol;
  trln: TTransferLine;
  altrntv: TAlternative;
  i: Integer;
begin
  BitMap := TBitMap.Create();
  ImageSize := GetSize(Form1);
  BitMap.Width := ImageSize.width + 5;
  BitMap.Height := ImageSize.height;
  DrawDefinition(BitMap);
  for i := 0 to Form1.ComponentCount - 1 do
  begin
    if Form1.Components[i] is TLine then
      DrawLine(BitMap, Form1.Components[i] as TLine)
    else if Form1.Components[i] is TTransferLine then
      DrawTransferLine(BitMap, Form1.Components[i] as TTransferLine)
    else if Form1.Components[i] is TSyntSymbol then
      DrawSyntSymbol(BitMap, Form1.Components[i] as TSyntSymbol);
  end;
  for i := 0 to length(Alter) - 1 do
    DrawAlternative(BitMap, Alter[i, 2], Alter[i, 1]);
end;

procedure ExportBMP(FileName: string);
var
  BitMap: TBitmap;
begin
  ConevertToBitMap(BitMap);
  BitMap.SaveToFile(FileName);
  BitMap.Free();
end;

procedure ExportJPEG(FileNAME: string);
var
  BitMap: TBitMap;
  JPeg: TJPEGImage;
begin
  ConevertToBitMap(BitMap);
  JPeg := TJPEGImage.Create();
  JPeg.Assign(BitMap);
  JPeg.SaveToFile(FileNAME);
  JPeg.Free();
  BitMap.Free();
end;

procedure ExportSVG(FileName: string);
var
  ImageSize: TSize;
  I: Integer;
begin
  Assign(SVGFile, FileName);
  Rewrite(SVGFile);
  ImageSize := GetSize(Form1);
  Write(SVGFile, '<?xml version="1.0" encoding="windows-1251" standalone="no"?> ' + #13#10 + '<svg  version="1.1" width="' + IntToStr(ImageSize.width + 5) + '" height="' + IntToStr(ImageSize.height) + '"' + #13#10 + '       viewBox="0 0 ' + IntToStr(ImageSize.width + 5) + ' ' + IntToStr(ImageSize.height) + '"' + #13#10 + '     baseProfile="full"' + #13#10 + '     xmlns="http://www.w3.org/2000/svg" ' + #13#10 + '     xmlns:xlink="http://www.w3.org/1999/xlink"' + #13#10 + '     xmlns:ev="http://www.w3.org/2001/xml-events">' + #13#10);
  write(SVGFile, '<title> ' + FileName + ' </title>' + #13#10);
  write(SVGFile, '    <desc>' + #13#10 + '       Syntax diagram in SVG graphic format.' + #13#10 + '    </desc>' + #13#10);

  DrawDefinition();
  for I := 0 to Form1.ComponentCount - 1 do
  begin
    if Form1.Components[I] is TLine then
      DrawLine(Form1.Components[I] as TLine)
    else if Form1.Components[I] is TTransferLine then
      DrawTransferLine(Form1.Components[I] as TTransferLine)
    else if Form1.Components[I] is TSyntSymbol then
      DrawSyntSymbol(Form1.Components[I] as TSyntSymbol);
  end;
  for I := 0 to length(Alter) - 1 do
    DrawAlternative(Alter[I, 2], Alter[I, 1]);

  write(SVGFile, '</svg>');
  CloseFile(SVGFile);
end;

procedure DrawLine(BitMap: TBitMap; ln: TLine);
var
  wdth: Integer;
  lftShift, topShift: integer;
begin
  BitMap.Canvas.Pen := ln.Canvas.Pen;
  BitMap.Canvas.Brush := ln.Canvas.Brush;
  lftShift := ln.left - Form1.sb1VarDef.left + 5;
  topShift := ln.Top - Form1.sb1VarDef.Top;
  BitMap.Canvas.Rectangle(0 + lftShift, ln.Height div 2 + topShift, ln.Width + 1 + lftShift, (ln.Height div 2) + (ln.Canvas.Pen.Width - 1) + topShift);
  if ln.hasArrow and not (ln.Next is TLine) then
  begin
    wdth := ln.Width;
    if (ln.Next is TTransferLine) or (ln.Next is TAlternative) or (ln.arrowReversed) then
      wdth := wdth div 2;
    if not ln.arrowReversed then
    begin
      BitMap.Canvas.MoveTo(wdth + lftShift, ln.Height div 2 + topShift);
      BitMap.Canvas.LineTo(wdth - ln.Height div 4 - 8 + lftShift, ln.Height div 4 + topShift);
      BitMap.Canvas.MoveTo(wdth + lftShift, ln.Height div 2 + topShift);
      BitMap.Canvas.LineTo(wdth - ln.Height div 4 - 8 + lftShift, ln.Height - ln.Height div 4 + topShift);
    end
    else
    begin
      BitMap.Canvas.MoveTo(wdth + lftShift, ln.Height div 2 + topShift);
      BitMap.Canvas.LineTo(wdth + ln.Height div 4 + 8 + lftShift, ln.Height div 4 + topShift);
      BitMap.Canvas.MoveTo(wdth + lftShift, ln.Height div 2 + topShift);
      BitMap.Canvas.LineTo(wdth + ln.Height div 4 + 8 + lftShift, ln.Height - ln.Height div 4 + topShift);
    end;
  end;
end;

procedure DrawAlternative(BitMap: TBitMap; altr1, altr2: TAlternative);
var
  lft: Integer;
  top: Integer;
begin
  lft := altr1.Left - Form1.sb1vardef.left + 5;
  top := altr1.Top - Form1.sb1VarDef.Top;
  BitMap.Canvas.Pen.Width := 2;
  if not altr1.isUpper then
  begin
    BitMap.Canvas.Rectangle(altr1.Canvas.Pen.Width - 1 + lft, 0 + top, altr1.Canvas.Pen.Width + 1 + lft, altr1.Canvas.Pen.Width - 1 + top);
    BitMap.Canvas.MoveTo(altr1.Canvas.Pen.Width + lft, 0 + top);
    BitMap.Canvas.LineTo(altr1.Width + lft, altr1.Width - altr1.Canvas.Pen.Width + top);
    BitMap.Canvas.Rectangle(altr1.Width - altr1.Canvas.Pen.Width + 2 + lft, altr1.Width - altr1.Canvas.Pen.Width + top, altr1.Width + lft + 1, altr1.height - altr1.Width + altr1.Canvas.Pen.Width + top);

    lft := altr2.Left - Form1.sb1vardef.left + 5;
    top := altr2.Top - Form1.sb1VarDef.Top;
    BitMap.Canvas.Rectangle(altr2.Width - (altr2.Canvas.Pen.Width - 1) + lft, 0 + top, altr2.Width + lft, altr2.Canvas.Pen.Width - 1 + top);
    BitMap.Canvas.MoveTo(altr2.Width - altr2.Canvas.Pen.Width + lft, 0 + top);
    BitMap.Canvas.LineTo(0 + lft, altr2.Width - altr2.Canvas.Pen.Width + top);
    BitMap.Canvas.Rectangle(1 + lft, altr2.Width - altr2.Canvas.Pen.Width + top, altr2.Canvas.Pen.Width + lft, altr2.height - altr2.Width + altr2.Canvas.Pen.Width + top);
  end;
end;

procedure DrawTransferLine(BitMap: TBitMap; trln: TTransferLine);
var
  lft: Integer;
  top: Integer;
begin
  lft := -(trln.TrLnElems[1].Left - Form1.sb1vardef.left + 5);
  top := -(trln.TrLnElems[1].top - Form1.sb1VarDef.Top);
  BitMap.Canvas.Rectangle(1 - lft, LnH div 2 - (trln.TrLnElems[1].Canvas.Pen.Width - 1) - top, 1 + trln.TrLnElems[1].Canvas.Pen.Width - 1 - lft, trln.TrLnElems[1].Height - (LnH div 2) + trln.TrLnElems[1].Canvas.Pen.Width - top);
  lft := -(trln.TrLnElems[2].Left - Form1.sb1vardef.left + 5);
  top := -(trln.TrLnElems[2].top - Form1.sb1VarDef.Top);
  BitMap.Canvas.Rectangle(0 - lft, LnH div 2 - top, trln.TrLnElems[2].Width + 1 - lft, (LnH div 2) + (trln.TrLnElems[2].Canvas.Pen.Width - 1) - top);
  lft := -(trln.TrLnElems[3].Left - Form1.sb1vardef.left + 5);
  top := -(trln.TrLnElems[3].top - Form1.sb1VarDef.Top);
  BitMap.Canvas.Rectangle(trln.TrLnElems[3].Width - 1 - lft, LnH div 2 - trln.TrLnElems[1].Canvas.Pen.Width + 1 - top, trln.TrLnElems[3].Width - lft, trln.TrLnElems[3].Height - (LnH div 2) + trln.TrLnElems[1].Canvas.Pen.Width - top);

  lft := -(trln.TrLnElems[2].Left - Form1.sb1vardef.left + 5);
  top := -(trln.TrLnElems[2].top - Form1.sb1VarDef.Top);
  BitMap.Canvas.MoveTo(trln.TrLnElems[2].Width div 2 - lft, trln.TrLnElems[2].Height div 2 - top);
  BitMap.Canvas.LineTo(trln.TrLnElems[2].Width div 2 + trln.TrLnElems[2].Height div 4 + 8 - lft, trln.TrLnElems[2].Height div 4 - top);
  BitMap.Canvas.MoveTo(trln.TrLnElems[2].Width div 2 - lft, trln.TrLnElems[2].Height div 2 - top);
  BitMap.Canvas.LineTo(trln.TrLnElems[2].Width div 2 + trln.TrLnElems[2].Height div 4 + 8 - lft, trln.TrLnElems[2].Height - trln.TrLnElems[2].Height div 4 - top);
end;

procedure DrawSyntSymbol(BitMap: TBitMap; ss: TSyntSymbol);
var
  lft: Integer;
  top: Integer;
begin
  lft := ss.left - Form1.sb1VarDef.left + 5;
  top := ss.Top - Form1.sb1VarDef.Top;
  BitMap.Canvas.Font := ss.Font;
  BitMap.Canvas.TextOut(lft, top, ss.Text);
  if ss is TVariable then
  begin
    lft := (ss as TVariable).sqrBra[1].Left - Form1.sb1VarDef.left + 5;
    top := (ss as TVariable).sqrBra[1].top - Form1.sb1VarDef.top;
    BitMap.Canvas.Font := (ss as TVariable).sqrBra[1].Font;
    BitMap.Canvas.TextOut(lft, top, '<');
    lft := (ss as TVariable).sqrBra[2].Left - Form1.sb1VarDef.left + 5;
    BitMap.Canvas.TextOut(lft, top, '>');
  end;
end;

procedure DrawDefinition(BitMap: TBitMap);
var
  lft: Integer;
  top: Integer;
begin
  BitMap.Canvas.Font := Form1.edtvarDef.Font;
  lft := Form1.edtvarDef.Left - Form1.sb1VarDef.left + 5;
  top := Form1.edtvarDef.top - Form1.sb1VarDef.top;
  BitMap.Canvas.TextOut(lft, top, Form1.edtvarDef.Text);

  BitMap.Canvas.Font := Form1.sb1VarDef.Font;
  BitMap.Canvas.TextOut(5, 0, '<');
  lft := Form1.sb2VarDef.Left - Form1.sb1VarDef.left + 5;
  BitMap.Canvas.TextOut(lft, 0, '>');

  lft := Form1.eq.Left - Form1.sb1vardef.left + 5;
  top := Form1.eq.top - Form1.sb1vardef.top;
  BitMap.Canvas.Font := Form1.eq.Font;
  BitMap.Canvas.TextOut(lft, 0, '::=');
end;

procedure DrawLine(ln: TLine); overload;
var
  lft: Integer;
  top: Integer;
  wdth: Integer;
begin
  lft := ln.Left - Form1.sb1VarDef.Left + 5;
  top := ln.top - Form1.sb1VarDef.Top;
  write(SVGFile, '<line x1="' + IntToStr(lft) + '" y1="' + IntToStr(top + ln.Height div 2) + '" x2="' + IntToStr(lft + ln.width) + '" y2="' + IntToStr(top + ln.Height div 2) + '" stroke-width="' + IntToStr(ln.Canvas.pen.width) + '" stroke="black" />' + #13#10);
  if ln.hasArrow and not (ln.Next is TLine) then
  begin
    wdth := ln.Width;
    if (ln.Next is TTransferLine) or (ln.Next is TAlternative) or (ln.arrowReversed) then
      wdth := wdth div 2;
    if not ln.arrowReversed then
      write(SVGFile, '<polygon points=" ' + IntToStr(wdth - ln.Height div 4 - 8 + lft) + ',' + IntToStr(ln.Height div 4 + top) + ' ' + IntToStr(wdth + lft) + ',' + IntToStr(ln.Height div 2 + top) + ' ' + IntToStr(wdth - ln.Height div 4 - 8 + lft) + ',' + IntToStr(ln.Height - ln.Height div 4 + top) + ' ' + IntToStr(wdth + lft) + ',' + IntToStr(ln.Height div 2 + top) + '" stroke-width="' + IntToStr(ln.Canvas.pen.width) + '" stroke="black" fill="none"/>' + #13#10)
    else
      write(SVGFile, '<polygon points=" ' + IntToStr(wdth + ln.Height div 4 + 8 + lft) + ',' + IntToStr(ln.Height div 4 + top) + ' ' + IntToStr(wdth + lft) + ',' + IntToStr(ln.Height div 2 + top) + ' ' + IntToStr(wdth + ln.Height div 4 + 8 + lft) + ',' + IntToStr(ln.Height - ln.Height div 4 + top) + ' ' + IntToStr(wdth + lft) + ',' + IntToStr(ln.Height div 2 + top) + '" stroke-width="' + IntToStr(ln.Canvas.pen.width) + '" stroke="black" fill="none"/>' + #13#10);
  end;
end;

procedure DrawAlternative(altr1, altr2: TAlternative); overload;
var
  lft: Integer;
  top: Integer;
begin
  lft := altr1.Left - Form1.sb1vardef.left + 5;
  top := altr1.Top - Form1.sb1VarDef.Top;

  if not altr1.isLoop then
  begin
    if not altr1.isUpper then
    begin
      write(SVGFile, '<polygon points=" ' + IntToStr(altr1.Canvas.Pen.Width + lft) + ',' + IntToStr(top - 1) + ' ' + IntToStr(altr1.Width + lft) + ',' + IntToStr(altr1.Width - altr1.Canvas.Pen.Width + top) + ' ' + IntToStr(altr1.Width + lft) + ',' + IntToStr(altr1.height - altr1.Width + altr1.Canvas.Pen.Width - 1 + top) + ' ' + IntToStr(altr1.Width + lft) + ',' + IntToStr(altr1.Width - altr1.Canvas.Pen.Width + top) + '" stroke-width="' + IntToStr(altr1.Canvas.pen.width) + '" stroke="black" fill="none"/>' + #13#10);
      lft := altr2.Left - Form1.sb1vardef.left + 5;
      top := altr2.Top - Form1.sb1VarDef.Top;
      write(SVGFile, '<polygon points=" ' + IntToStr(altr2.Width - altr2.Canvas.Pen.Width + 1 + lft) + ',' + IntToStr(top - 1) + ' ' + IntToStr(lft) + ',' + IntToStr(altr2.Width - altr2.Canvas.Pen.Width + top) + ' ' + IntToStr(lft) + ',' + IntToStr(altr1.height - altr1.Width + altr1.Canvas.Pen.Width - 1 + top) + ' ' + IntToStr(lft) + ',' + IntToStr(altr2.Width - altr2.Canvas.Pen.Width + top) + '" stroke-width="' + IntToStr(altr1.Canvas.pen.width) + '" stroke="black" fill="none"/>' + #13#10);
    end
    else
    begin

    end;
  end
  else
  begin

  end;
end;

procedure DrawTransferLine(trln: TTransferLine); overload;
var
  lft: Integer;
  top: Integer;
  wdth: integer;
  hgt: integer;
begin
  lft := trln.TrLnElems[1].Left - Form1.sb1vardef.left + 5;
  top := trln.TrLnElems[1].top - Form1.sb1VarDef.Top;
  write(SVGFile, '<line x1="' + IntToStr(1 + lft) + '" y1="' + IntToStr(LnH div 2 + top - 1) + '" x2="' + IntToStr(trln.TrLnElems[1].Canvas.Pen.Width - 1 + lft) + '" y2="' + IntToStr(trln.TrLnElems[1].Height - (LnH div 2) + trln.TrLnElems[1].Canvas.Pen.Width + top) + '" stroke-width="' + IntToStr(trln.TrLnElems[1].Canvas.pen.width) + '" stroke="black"/>' + #13#10);

  lft := trln.TrLnElems[2].Left - Form1.sb1vardef.left + 5;
  top := trln.TrLnElems[2].top - Form1.sb1VarDef.Top;
  write(SVGFile, '<line x1="' + IntToStr(lft) + '" y1="' + IntToStr(LnH div 2 + top) + '" x2="' + IntToStr(trln.TrLnElems[2].Width + 1 + lft) + '" y2="' + IntToStr((LnH div 2) + (trln.TrLnElems[2].Canvas.Pen.Width - 1) + top) + '" stroke-width="' + IntToStr(trln.TrLnElems[1].Canvas.pen.width) + '" stroke="black"/>' + #13#10);

  lft := trln.TrLnElems[3].Left - Form1.sb1vardef.left + 5;
  top := trln.TrLnElems[3].top - Form1.sb1VarDef.Top;

  write(SVGFile, '<line x1="' + IntToStr(trln.TrLnElems[3].Width + lft) + '" y1="' + IntToStr(LnH div 2 + top - 1) + '" x2="' + IntToStr(trln.TrLnElems[3].Width + lft) + '" y2="' + IntToStr(trln.TrLnElems[3].Height - (LnH div 2) + trln.TrLnElems[1].Canvas.Pen.Width - 1 + top) + '" stroke-width="' + IntToStr(trln.TrLnElems[1].Canvas.pen.width) + '" stroke="black"/>' + #13#10);

  lft := trln.TrLnElems[2].Left - Form1.sb1vardef.left + 5;
  top := trln.TrLnElems[2].top - Form1.sb1VarDef.Top;
 // BitMap.Canvas.MoveTo(trln.TrLnElems[2].Width div 2 - lft, trln.TrLnElems[2].Height div 2 - top);
 // BitMap.Canvas.LineTo(trln.TrLnElems[2].Width div 2 + trln.TrLnElems[2].Height div 4 + 8 - lft, trln.TrLnElems[2].Height div 4 - top);
 // BitMap.Canvas.MoveTo(trln.TrLnElems[2].Width div 2 - lft, trln.TrLnElems[2].Height div 2 - top);
 // BitMap.Canvas.LineTo(trln.TrLnElems[2].Width div 2 + trln.TrLnElems[2].Height div 4 + 8 - lft, trln.TrLnElems[2].Height - trln.TrLnElems[2].Height div 4 - top);
  wdth := trln.TrLnElems[2].Width div 2;
  hgt := trln.TrLnElems[2].Height;
  write(SVGFile, '<polygon points=" ' + IntToStr(wdth + hgt div 4 + 8 + lft) + ',' + IntToStr(hgt div 4 + top) + ' ' + IntToStr(wdth + lft) + ',' + IntToStr(hgt div 2 + top) + ' ' + IntToStr(wdth + hgt div 4 + 8 + lft) + ',' + IntToStr(hgt - hgt div 4 + top) + ' ' + IntToStr(wdth + lft) + ',' + IntToStr(hgt div 2 + top) + '" stroke-width="' + IntToStr(trln.TrLnElems[2].Canvas.pen.width) + '" stroke="black" fill="none"/>' + #13#10)
end;

procedure DrawSyntSymbol(ss: TSyntSymbol); overload;
var
  lft: Integer;
  top: Integer;
begin
  lft := ss.left - Form1.sb1VarDef.left + ss.width div 2 + 5;
  top := ss.Top - Form1.sb1VarDef.Top + ss.height div 2;
  write(SVGFile, '<text text-anchor="middle" font-family="Verdana" font-size="12" font-weight="900" x="' + IntToStr(lft) + '" y="' + IntToStr(top) + '">' + ss.text + '</text>' + #13#10);
  if ss is TVariable then
  begin
    lft := (ss as TVariable).sqrBra[1].Left - Form1.sb1VarDef.left + (ss as TVariable).sqrBra[1].Width div 2 + 5 + 1;
    top := (ss as TVariable).sqrBra[1].top - Form1.sb1VarDef.top + (ss as TVariable).sqrBra[1].height div 2 + 5;
    write(SVGFile, '<text text-anchor="middle" font-weight="500" font-family="sans-serif" font-size="20" x="' + IntToStr(lft) + '" y="' + IntToStr(top) + '" > &lt; </text>' + #13#10);
    lft := (ss as TVariable).sqrBra[2].Left - Form1.sb1VarDef.left + (ss as TVariable).sqrBra[2].Width div 2 + 5;
    write(SVGFile, '<text text-anchor="middle" font-weight="500" font-family="sans-serif" font-size="20" x="' + IntToStr(lft) + '" y="' + IntToStr(top) + '" > &gt; </text>' + #13#10);
  end
end;

procedure DrawDefinition(); overload;
var
  lft: Integer;
  top: Integer;
begin
  lft := form1.edtvardef.left - Form1.sb1VarDef.left + form1.edtvardef.Width div 2 + 5;
  top := form1.edtvardef.Top - Form1.sb1VarDef.Top + form1.edtvardef.height div 2 + 4;
  write(SVGFile, '<text text-anchor="middle" font-family="Verdana" font-size="12" font-weight="900" x="' + IntToStr(lft) + '" y="' + IntToStr(top) + '">' + form1.edtvardef.text + '</text>' + #13#10);
  lft := form1.sb1VarDef.Width div 2 + 5 + 1;
  top := form1.sb1VarDef.height div 2 + 5;
  write(SVGFile, '<text text-anchor="middle" font-weight="500" font-family="sans-serif" font-size="20" x="' + IntToStr(lft) + '" y="' + IntToStr(top) + '" > &lt; </text>' + #13#10);
  ;
  lft := form1.sb2VarDef.Left - Form1.sb1VarDef.left + form1.sb2VarDef.Width div 2 + 5;
  write(SVGFile, '<text text-anchor="middle" font-weight="500" font-family="sans-serif" font-size="20" x="' + IntToStr(lft) + '" y="' + IntToStr(top) + '" > &gt; </text>' + #13#10);
  lft := form1.eq.Left - Form1.sb1VarDef.left + form1.eq.Width div 2 + 5;
  top := form1.eq.top - Form1.sb1VarDef.Top + form1.eq.height div 2 + 5;
  write(SVGFile, '<text text-anchor="middle" font-weight="500" font-family="sans-serif" font-size="20" x="' + IntToStr(lft) + '" y="' + IntToStr(top) + '" >::=</text>' + #13#10);
end;

end.

