object fMainForm: TfMainForm
  Left = 195
  Top = 119
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
    Caption = 'COB'#33184#27700#19978#32218' :'
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
    Caption = 'COB'#33184#27700#19978#32218' :'
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
    Top = 122
    Width = 66
    Height = 13
    AutoSize = False
    Caption = 'Reel NO:'
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
    Top = 120
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
  object lbl1: TLabel
    Left = 40
    Top = 58
    Width = 66
    Height = 13
    AutoSize = False
    Caption = #27231#21488#32406#39636':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object msgPanel: TPanel
    Left = 22
    Top = 189
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
  object EditReelno: TEdit
    Left = 146
    Top = 115
    Width = 161
    Height = 21
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 1
    OnKeyPress = EditReelnoKeyPress
  end
  object cmb1: TComboBox
    Left = 144
    Top = 56
    Width = 145
    Height = 21
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ItemHeight = 13
    TabOrder = 2
    OnSelect = cmb1Select
    Items.Strings = (
      'HODLE MOUNT01'
      'HODLE MOUNT02'
      'HODLE MOUNT03'
      'HODLE MOUNT04'
      'HODLE MOUNT05'
      'HODLE MOUNT06'
      'HODLE MOUNT07'
      'HODLE MOUNT08'
      'HODLE MOUNT09'
      'HODLE MOUNT10'
      'DIE BOND-A'
      'DIE BOND-B'
      'DIE BOND-C'
      'DIE BOND-D'
      'DIE BOND-E'
      'DIE BOND-F'
      'DATACON01'
      'DATACON02')
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
