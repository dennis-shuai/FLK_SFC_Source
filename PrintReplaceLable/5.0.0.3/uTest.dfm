object formTest: TformTest
  Left = 217
  Top = 158
  Width = 750
  Height = 560
  Caption = 'ASSY INPUT'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 742
    Height = 526
    Align = alClient
  end
  object lablWO: TLabel
    Left = 30
    Top = 28
    Width = 107
    Height = 24
    AutoSize = False
    Caption = 'Work Order'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    Layout = tlCenter
  end
  object Label1: TLabel
    Left = 30
    Top = 68
    Width = 107
    Height = 24
    AutoSize = False
    Caption = 'Panel No'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    Layout = tlCenter
  end
  object Label2: TLabel
    Left = 30
    Top = 108
    Width = 139
    Height = 24
    AutoSize = False
    Caption = 'Serial Number'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    Layout = tlCenter
  end
  object panlMessage: TLabel
    Left = 16
    Top = 464
    Width = 513
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
  end
  object editWO: TEdit
    Left = 169
    Top = 27
    Width = 241
    Height = 30
    CharCase = ecUpperCase
    Color = clWhite
    Font.Charset = ANSI_CHARSET
    Font.Color = clNavy
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnKeyPress = editWOKeyPress
  end
  object csData: TColorStringGrid
    Left = 20
    Top = 152
    Width = 509
    Height = 305
    ColCount = 2
    DefaultColWidth = 200
    FixedCols = 0
    RowCount = 2
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing]
    ParentFont = False
    TabOrder = 1
  end
  object editPanel: TEdit
    Left = 169
    Top = 67
    Width = 241
    Height = 30
    CharCase = ecUpperCase
    Color = clWhite
    Font.Charset = ANSI_CHARSET
    Font.Color = clNavy
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnKeyPress = editPanelKeyPress
  end
  object editSN: TEdit
    Left = 169
    Top = 107
    Width = 241
    Height = 30
    CharCase = ecUpperCase
    Color = clWhite
    Font.Charset = ANSI_CHARSET
    Font.Color = clNavy
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnKeyPress = editSNKeyPress
  end
  object bbtnConfirm: TBitBtn
    Left = 440
    Top = 104
    Width = 81
    Height = 33
    Caption = 'Confirm'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = bbtnConfirmClick
  end
end
