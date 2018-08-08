object FormMain: TFormMain
  Left = 396
  Top = 410
  BorderStyle = bsDialog
  Caption = #35531#36664#20837#24037#20196
  ClientHeight = 193
  ClientWidth = 571
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label10: TLabel
    Left = 152
    Top = 56
    Width = 49
    Height = 30
    AutoSize = False
    Caption = 'WO:'
    Color = clBtnFace
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -21
    Font.Name = 'Arial'
    Font.Style = [fsBold, fsItalic]
    ParentColor = False
    ParentFont = False
    Transparent = True
    Layout = tlCenter
  end
  object Label1: TLabel
    Left = 56
    Top = 8
    Width = 160
    Height = 27
    Caption = #35531#36664#20837#24037#20196':'
    Font.Charset = CHINESEBIG5_CHARSET
    Font.Color = clBlue
    Font.Height = -27
    Font.Name = #27161#26999#39636
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
    Transparent = True
  end
  object Label2: TLabel
    Left = 128
    Top = 112
    Width = 73
    Height = 30
    AutoSize = False
    Caption = 'Batch:'
    Color = clBtnFace
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -21
    Font.Name = 'Arial'
    Font.Style = [fsBold, fsItalic]
    ParentColor = False
    ParentFont = False
    Transparent = True
    Layout = tlCenter
  end
  object Label3: TLabel
    Left = 24
    Top = 160
    Width = 529
    Height = 16
    Caption = #28331#39336#25552#31034':'#36664#20837#24037#20196#21518#22238#36554#21487#20197#33258#21205#24118#20986#27492#24037#20196#30340#25209#37327'('#36664#20837#24037#20196#24050#32147#29983#29986#36942')'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object EditWorkOrder: TEdit
    Left = 200
    Top = 56
    Width = 153
    Height = 32
    CharCase = ecUpperCase
    Color = clYellow
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -21
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnKeyPress = EditWorkOrderKeyPress
  end
  object BitBtn1: TBitBtn
    Left = 392
    Top = 112
    Width = 113
    Height = 33
    Caption = 'OK'
    Enabled = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = BitBtn1Click
  end
  object EditBatch: TEdit
    Left = 200
    Top = 112
    Width = 153
    Height = 32
    CharCase = ecUpperCase
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -21
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
  end
  object chkRetailLabel: TCheckBox
    Left = 392
    Top = 32
    Width = 129
    Height = 17
    Caption = 'Retail Label'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnClick = chkRetailLabelClick
  end
  object chkMinglePack: TCheckBox
    Left = 392
    Top = 70
    Width = 113
    Height = 25
    Caption = #28151#21512#21253#35037
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = chkMinglePackClick
  end
  object RzVersionInfo: TRzVersionInfo
    Left = 48
    Top = 40
  end
end
