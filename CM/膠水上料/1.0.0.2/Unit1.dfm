object Form1: TForm1
  Left = 310
  Top = 0
  Width = 1065
  Height = 690
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ImageAll: TImage
    Left = 0
    Top = 0
    Width = 1057
    Height = 656
    Align = alClient
  end
  object Label1: TLabel
    Left = 57
    Top = 179
    Width = 89
    Height = 16
    AutoSize = False
    Caption = #33184#27700#26781#30908':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label3: TLabel
    Left = 40
    Top = 24
    Width = 280
    Height = 24
    AutoSize = False
    Caption = #33184#27700#19978#19979#26009
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
    Caption = #33184#27700#19978#19979#26009
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblMsg: TLabel
    Left = 49
    Top = 222
    Width = 404
    Height = 149
    Alignment = taCenter
    AutoSize = False
    Color = clMedGray
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -24
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Transparent = False
    Layout = tlCenter
  end
  object lblTerminal: TLabel
    Left = 58
    Top = 70
    Width = 337
    Height = 16
    AutoSize = False
    Caption = #31449#21029':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object edtSN: TEdit
    Left = 154
    Top = 177
    Width = 265
    Height = 21
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 0
    OnKeyPress = edtSNKeyPress
  end
  object RadioGroup1: TRadioGroup
    Left = 56
    Top = 105
    Width = 369
    Height = 49
    Caption = #39006#22411
    Color = clBtnHighlight
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      #19978#26009
      #19979#26009)
    ParentColor = False
    TabOrder = 1
    OnClick = RadioGroup1Click
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 16
  end
  object Sproc: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 48
  end
end
