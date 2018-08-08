object fMainForm: TfMainForm
  Left = 245
  Top = 159
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
  OnShow = FormShow
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
    Caption = 'COB'#27835#20855#28165#27927'   :'
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
    Caption = 'COB'#27835#20855#28165#27927'   :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label2: TLabel
    Left = 40
    Top = 50
    Width = 66
    Height = 13
    AutoSize = False
    Caption = #27835#20855#26781#30908':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object labInputQty: TLabel
    Left = 646
    Top = 87
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
  object sbtnSave: TSpeedButton
    Left = 352
    Top = 48
    Width = 73
    Height = 17
    Cursor = crHandPoint
    Caption = 'OK'
    Flat = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Visible = False
  end
  object msgPanel: TPanel
    Left = 38
    Top = 85
    Width = 697
    Height = 113
    Color = clCaptionText
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object edtToolinglNo: TEdit
    Left = 146
    Top = 43
    Width = 161
    Height = 21
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 1
    OnKeyPress = edtToolinglNoKeyPress
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
