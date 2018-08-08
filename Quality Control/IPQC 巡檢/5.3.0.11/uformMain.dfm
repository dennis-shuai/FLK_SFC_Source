object formMain: TformMain
  Left = 189
  Top = 111
  BorderStyle = bsNone
  ClientHeight = 746
  ClientWidth = 1024
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ImageAll: TImage
    Left = 0
    Top = 0
    Width = 1024
    Height = 746
    Align = alClient
  end
  object LabTitle2: TLabel
    Left = 6
    Top = 5
    Width = 180
    Height = 16
    AutoSize = False
    Caption = 'IPQC HM '#24033#27298#35352#37636' '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object LabTitle1: TLabel
    Left = 5
    Top = 4
    Width = 180
    Height = 16
    AutoSize = False
    Caption = 'IPQC HM '#24033#27298#35352#37636' '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lablMsg: TLabel
    Left = 232
    Top = 464
    Width = 5
    Height = 16
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object labID: TLabel
    Left = 115
    Top = 491
    Width = 118
    Height = 19
    Alignment = taRightJustify
    AutoSize = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lbl1: TLabel
    Left = 8
    Top = 675
    Width = 114
    Height = 16
    Caption = 'Version :5.3.0.12'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label6: TLabel
    Left = 53
    Top = 99
    Width = 26
    Height = 16
    Caption = 'SN:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblTerminal: TLabel
    Left = 33
    Top = 35
    Width = 654
    Height = 29
    AutoSize = False
    Caption = 'lblTerminal'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblMsg: TLabel
    Left = 49
    Top = 144
    Width = 369
    Height = 134
    Alignment = taCenter
    AutoSize = False
    Color = clMoneyGreen
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
  end
  object edtSN: TEdit
    Left = 102
    Top = 95
    Width = 189
    Height = 24
    Color = clYellow
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentFont = False
    TabOrder = 0
    OnKeyPress = edtSNKeyPress
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 472
    Top = 176
  end
  object QryData: TClientDataSet
    Aggregates = <>
    FieldDefs = <>
    IndexDefs = <>
    Params = <>
    ProviderName = 'DspQryData'
    StoreDefs = True
    Left = 256
    Top = 400
  end
  object PMenuDefect: TPopupMenu
    Left = 312
    Top = 328
    object Delete1: TMenuItem
      Caption = 'Delete'
    end
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    FieldDefs = <>
    IndexDefs = <>
    Params = <>
    ProviderName = 'DspQryData'
    StoreDefs = True
    Left = 222
    Top = 248
  end
end
