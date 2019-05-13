object Form2: TForm2
  Left = 769
  Top = 344
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  ClientHeight = 183
  ClientWidth = 355
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object NewDoc: TButton
    Left = 81
    Top = 24
    Width = 193
    Height = 49
    Caption = 'New Diagram'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = NewDocClick
  end
  object OpenDoc: TButton
    Left = 81
    Top = 88
    Width = 193
    Height = 49
    Caption = 'Open Diagram'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = OpenDocClick
  end
end
