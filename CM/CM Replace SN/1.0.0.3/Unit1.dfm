object Form1: TForm1
  Left = 191
  Top = 112
  Width = 746
  Height = 569
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ImageAll: TImage
    Left = 0
    Top = 0
    Width = 738
    Height = 535
    Align = alClient
  end
  object Label1: TLabel
    Left = 48
    Top = 128
    Width = 43
    Height = 13
    Caption = 'New SN:'
    Transparent = True
  end
  object Label7: TLabel
    Left = 48
    Top = 80
    Width = 34
    Height = 13
    Caption = 'Old SN'
    Transparent = True
  end
  object lblMsg: TLabel
    Left = 42
    Top = 193
    Width = 430
    Height = 201
    Alignment = taCenter
    AutoSize = False
    Color = clMedGray
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -96
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Transparent = False
    Layout = tlCenter
  end
  object Label3: TLabel
    Left = 40
    Top = 24
    Width = 280
    Height = 24
    AutoSize = False
    Caption = 'CM SN Replace'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label2: TLabel
    Left = 42
    Top = 24
    Width = 280
    Height = 24
    AutoSize = False
    Caption = 'CM SN Replace'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object edtNewSN: TEdit
    Left = 120
    Top = 120
    Width = 233
    Height = 21
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 1
    OnKeyPress = edtNewSNKeyPress
  end
  object edtOldSN: TEdit
    Left = 120
    Top = 72
    Width = 233
    Height = 21
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 0
    OnKeyPress = edtOldSNKeyPress
  end
  object CheckBox1: TCheckBox
    Left = 58
    Top = 160
    Width = 129
    Height = 17
    Caption = #35299#38500'Sensor ID '#32129#23450
    Color = clBtnHighlight
    ParentColor = False
    TabOrder = 2
  end
  object CheckBox2: TCheckBox
    Left = 232
    Top = 162
    Width = 108
    Height = 17
    Caption = #37325#24037#21040'AOO'
    Checked = True
    Color = clBtnHighlight
    ParentColor = False
    State = cbChecked
    TabOrder = 3
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 16
  end
  object QryTemp2: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 48
  end
  object Sproc: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 107
    Top = 3
  end
end
