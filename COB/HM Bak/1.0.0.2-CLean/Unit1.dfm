object Form1: TForm1
  Left = 400
  Top = 120
  Width = 649
  Height = 488
  Color = clCaptionText
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 210
    Top = 30
    Width = 217
    Height = 32
    Caption = 'Hold Mount '#35036#25475
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -27
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 65
    Top = 107
    Width = 166
    Height = 24
    Caption = 'Hold Mount '#27231#21488
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -21
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 123
    Top = 165
    Width = 92
    Height = 24
    Caption = #36899#25203#34399#30908
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -21
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 59
    Top = 225
    Width = 512
    Height = 185
    Alignment = taCenter
    AutoSize = False
    Caption = 'Ready'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -64
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
  end
  object cmbTerminal: TComboBox
    Left = 248
    Top = 104
    Width = 248
    Height = 32
    Style = csDropDownList
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ItemHeight = 24
    ParentFont = False
    TabOrder = 0
    OnSelect = cmbTerminalSelect
  end
  object edtCarrier: TEdit
    Left = 248
    Top = 166
    Width = 246
    Height = 32
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentFont = False
    TabOrder = 1
    OnKeyPress = edtCarrierKeyPress
  end
end
