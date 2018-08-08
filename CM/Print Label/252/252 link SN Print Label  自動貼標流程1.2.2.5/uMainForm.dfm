object fMainForm: TfMainForm
  Left = 297
  Top = 90
  BorderStyle = bsNone
  ClientHeight = 739
  ClientWidth = 1192
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnDestroy = FormDestroy
  OnShow = fromshow
  PixelsPerInch = 96
  TextHeight = 13
  object ImageAll: TImage
    Left = 0
    Top = 0
    Width = 1192
    Height = 739
    Align = alClient
    ParentShowHint = False
    ShowHint = False
    Transparent = True
  end
  object LabTitle2: TLabel
    Left = 32
    Top = 8
    Width = 200
    Height = 16
    AutoSize = False
    Caption = '252'#23458#25142#26781#30908#32129#23450#21644#25171#21360#65306
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object LabTitle1: TLabel
    Left = 31
    Top = 7
    Width = 200
    Height = 16
    AutoSize = False
    Caption = '252'#23458#25142#26781#30908#32129#23450#21644#25171#21360#65306
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label5: TLabel
    Left = 40
    Top = 105
    Width = 78
    Height = 13
    AutoSize = False
    Caption = #20027#26495#26781#30908':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object labInputQty: TLabel
    Left = 494
    Top = 103
    Width = 75
    Height = 18
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object LabTerminal: TLabel
    Left = 232
    Top = 8
    Width = 521
    Height = 25
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label1: TLabel
    Left = 40
    Top = 57
    Width = 78
    Height = 13
    AutoSize = False
    Caption = #19981#33391#20195#30908':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object PrintFile: TLabel
    Left = 32
    Top = 320
    Width = 172
    Height = 16
    Caption = 'Print File'#65306'252_CSN.lab  '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object msgPanel: TPanel
    Left = 38
    Top = 160
    Width = 697
    Height = 118
    Color = clCaptionText
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object EdtSN: TEdit
    Left = 146
    Top = 99
    Width = 161
    Height = 21
    CharCase = ecUpperCase
    Color = clYellow
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 1
    OnKeyPress = EdtSNKeyPress
  end
  object edtErrCode: TEdit
    Left = 146
    Top = 51
    Width = 161
    Height = 21
    CharCase = ecUpperCase
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 2
    OnKeyPress = edtErrCodeKeyPress
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 360
    Top = 410
  end
  object QryData: TClientDataSet
    Aggregates = <>
    FieldDefs = <>
    IndexDefs = <>
    Params = <>
    ProviderName = 'DspQryData'
    StoreDefs = True
    Left = 208
    Top = 400
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 248
    Top = 400
  end
  object QryTemp1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 416
    Top = 400
  end
end
