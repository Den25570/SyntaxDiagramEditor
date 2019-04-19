object Form1: TForm1
  Left = 344
  Top = 185
  HelpType = htKeyword
  HelpKeyword = 'MainWindow'
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'SDE'
  ClientHeight = 676
  ClientWidth = 1361
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    1361
    676)
  PixelsPerInch = 96
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 676
    Hint = 'adg'
    Align = alLeft
    TabOrder = 0
    object VarTestCreate: TBitBtn
      Left = 24
      Top = 160
      Width = 137
      Height = 25
      Cursor = crHandPoint
      Caption = 'VarTestCreate'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Calibri Light'
      Font.Style = [fsItalic]
      ParentFont = False
      TabOrder = 0
      OnClick = VarTestCreateClick
    end
    object btn5: TBitBtn
      Left = 24
      Top = 192
      Width = 137
      Height = 25
      Caption = 'ConstTestCreate'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btn5Click
    end
    object edt1: TEdit
      Left = 32
      Top = 120
      Width = 121
      Height = 24
      TabOrder = 2
    end
    object AltCreate: TBitBtn
      Left = 24
      Top = 304
      Width = 137
      Height = 25
      Caption = 'AltCreate'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = AltCreateClick
    end
    object AddAlt: TBitBtn
      Left = 40
      Top = 432
      Width = 105
      Height = 25
      Caption = 'AddAlt'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = AddAltClick
    end
    object ShowP: TBitBtn
      Left = 56
      Top = 640
      Width = 75
      Height = 25
      Caption = 'ShowP'
      TabOrder = 5
    end
    object AltCreatUpper: TBitBtn
      Left = 24
      Top = 336
      Width = 137
      Height = 25
      Caption = 'AltCreatUpper'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      OnClick = AltCreatUpperClick
    end
    object Wtf: TBitBtn
      Left = 56
      Top = 608
      Width = 75
      Height = 25
      Caption = 'Wtf'
      TabOrder = 7
      OnClick = WtfClick
    end
    object TransferLine: TBitBtn
      Left = 24
      Top = 464
      Width = 139
      Height = 25
      Caption = 'TransferLine'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 8
      OnClick = TransferLineClick
    end
    object Loop: TBitBtn
      Left = 24
      Top = 368
      Width = 137
      Height = 25
      Caption = 'Loop'
      Enabled = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 9
    end
    object UpperLoop: TBitBtn
      Left = 24
      Top = 400
      Width = 137
      Height = 25
      Caption = 'UpperLoop'
      Enabled = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 10
    end
  end
  object eq: TStaticText
    Left = 356
    Top = 53
    Width = 27
    Height = 23
    Caption = '::='
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'News706 BT'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
  end
  object edtVarDef: TEdit
    Left = 234
    Top = 56
    Width = 97
    Height = 17
    Anchors = [akTop]
    BorderStyle = bsNone
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    Text = #1087#1077#1088#1077#1084#1077#1085#1085#1072#1103
    OnChange = OnTextChange
  end
  object sb1VarDef: TStaticText
    Left = 208
    Top = 52
    Width = 16
    Height = 28
    Caption = '<'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
  end
  object sb2VarDef: TStaticText
    Left = 336
    Top = 52
    Width = 16
    Height = 28
    Caption = '>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
  end
  object MainMenu: TMainMenu
    Left = 16
    Top = 8
    object F1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Caption = 'Open...'
      end
      object Save1: TMenuItem
        Caption = 'Save'
      end
      object Saveas1: TMenuItem
        Caption = 'Save as...'
      end
      object Newpage1: TMenuItem
        Caption = 'New page'
      end
      object Closepage1: TMenuItem
        Caption = 'Close page'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
      end
    end
    object Options1: TMenuItem
      Caption = 'Options'
      object Language1: TMenuItem
        Caption = 'Language'
      end
      object S1: TMenuItem
        Caption = 'Draw Template'
      end
      object DrawSettings1: TMenuItem
        Caption = 'Draw Settings'
      end
    end
    object Drawing1: TMenuItem
      Caption = 'Drawing'
      object Line1: TMenuItem
        Caption = 'Variable'
      end
      object Constant1: TMenuItem
        Caption = 'Constant'
      end
      object Alternative1: TMenuItem
        Caption = 'Alternative'
        object Upper1: TMenuItem
          Caption = 'Upper'
        end
        object Bottom1: TMenuItem
          Caption = 'Bottom'
        end
      end
      object Loop1: TMenuItem
        Caption = 'Loop'
        object Upper2: TMenuItem
          Caption = 'Upper'
        end
        object Bottom2: TMenuItem
          Caption = 'Bottom'
        end
      end
      object ransferLine1: TMenuItem
        Caption = 'Transfer Line'
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
    end
  end
  object pm1: TPopupMenu
    OwnerDraw = True
    Left = 80
    Top = 8
    object E1: TMenuItem
      Caption = 'E'
    end
  end
  object xpmnfst1: TXPManifest
    Left = 48
    Top = 8
  end
end
