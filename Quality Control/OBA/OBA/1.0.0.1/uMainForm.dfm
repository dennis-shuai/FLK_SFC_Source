object fMainForm: TfMainForm
  Left = 226
  Top = 132
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
    Caption = 'OBA '#27298#39511#35352#37636#65306
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
    Caption = 'OBA '#27298#39511#35352#37636#65306
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
    Top = 209
    Width = 78
    Height = 13
    AutoSize = False
    Caption = #25104#21697#26781#30908':'
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
    Left = 152
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
    Top = 161
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
  object Label2: TLabel
    Left = 40
    Top = 49
    Width = 78
    Height = 13
    AutoSize = False
    Caption = #22806#31665#34399#30908':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label3: TLabel
    Left = 40
    Top = 102
    Width = 78
    Height = 13
    AutoSize = False
    Caption = #20839#31665#34399#30908':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label4: TLabel
    Left = 88
    Top = 74
    Width = 51
    Height = 13
    Caption = 'Part_No:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label6: TLabel
    Left = 264
    Top = 74
    Width = 84
    Height = 13
    Caption = 'Outer Box Qty:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object LabPartNo: TLabel
    Left = 144
    Top = 72
    Width = 75
    Height = 16
    Caption = 'LabPartNo'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object LabOuterQty: TLabel
    Left = 352
    Top = 72
    Width = 87
    Height = 16
    Caption = 'LabOuterQty'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label7: TLabel
    Left = 56
    Top = 130
    Width = 82
    Height = 13
    Caption = 'Inner Box Qty:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object LabInnerQty: TLabel
    Left = 144
    Top = 128
    Width = 84
    Height = 16
    Caption = 'LabInnerQty'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object msgPanel: TPanel
    Left = 38
    Top = 256
    Width = 697
    Height = 126
    Color = clCaptionText
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object edtSN: TEdit
    Left = 146
    Top = 203
    Width = 161
    Height = 24
    CharCase = ecUpperCase
    Color = 8454143
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentFont = False
    TabOrder = 1
    OnKeyPress = edtSNKeyPress
  end
  object edtErrCode: TEdit
    Left = 146
    Top = 152
    Width = 161
    Height = 24
    CharCase = ecUpperCase
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentFont = False
    TabOrder = 2
    OnKeyPress = edtErrCodeKeyPress
  end
  object edtOuterBox: TEdit
    Left = 146
    Top = 40
    Width = 161
    Height = 24
    CharCase = ecUpperCase
    Color = 8454143
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentFont = False
    TabOrder = 3
    OnKeyPress = edtOuterBoxKeyPress
  end
  object edtInnerBox: TEdit
    Left = 146
    Top = 95
    Width = 161
    Height = 24
    CharCase = ecUpperCase
    Color = 8454143
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentFont = False
    TabOrder = 4
    OnKeyPress = edtInnerBoxKeyPress
  end
  object chkClear: TCheckBox
    Left = 320
    Top = 160
    Width = 137
    Height = 17
    Caption = #19981#33391#21518#21462#20986#32173#20462
    Checked = True
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    State = cbChecked
    TabOrder = 5
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
