object fMainForm: TfMainForm
  Left = 68
  Top = 207
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
    Caption = 'SMT '#38459#20540#28204#35430#35352#37636' '#65306
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
    Caption = 'SMT '#38459#20540#28204#35430#35352#37636' '#65306
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
    Top = 98
    Width = 66
    Height = 13
    AutoSize = False
    Caption = 'Reel ID:'
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
    Top = 210
    Width = 92
    Height = 13
    AutoSize = False
    Caption = #28204#35430#20540':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label5: TLabel
    Left = 40
    Top = 65
    Width = 78
    Height = 13
    AutoSize = False
    Caption = #24037#21934':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object labInputQty: TLabel
    Left = 694
    Top = 63
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
  object Label1: TLabel
    Left = 40
    Top = 137
    Width = 78
    Height = 13
    AutoSize = False
    Caption = #19978#38480#20540#65306
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label4: TLabel
    Left = 40
    Top = 177
    Width = 78
    Height = 13
    AutoSize = False
    Caption = #19979#38480#20540#65306
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object sbtnSave: TSpeedButton
    Left = 472
    Top = 208
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
    OnClick = sbtnSaveClick
  end
  object msgPanel: TPanel
    Left = 38
    Top = 253
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
  object EditWo: TEdit
    Left = 146
    Top = 59
    Width = 161
    Height = 21
    CharCase = ecUpperCase
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 1
    OnKeyPress = EditWoKeyPress
  end
  object EditReelno: TEdit
    Left = 146
    Top = 91
    Width = 161
    Height = 21
    CharCase = ecUpperCase
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ReadOnly = True
    TabOrder = 2
    OnKeyPress = EditReelnoKeyPress
  end
  object EditValue: TEdit
    Left = 146
    Top = 208
    Width = 161
    Height = 21
    CharCase = ecUpperCase
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ReadOnly = True
    TabOrder = 3
    OnKeyPress = EditValueKeyPress
  end
  object EditUP: TEdit
    Left = 146
    Top = 128
    Width = 161
    Height = 21
    CharCase = ecUpperCase
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    OnKeyPress = EditUPKeyPress
  end
  object EditDOWN: TEdit
    Left = 146
    Top = 168
    Width = 161
    Height = 21
    CharCase = ecUpperCase
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentShowHint = False
    ReadOnly = True
    ShowHint = True
    TabOrder = 5
    OnKeyPress = EditDOWNKeyPress
  end
  object ComboBox1: TComboBox
    Left = 328
    Top = 128
    Width = 81
    Height = 21
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 6
    OnChange = ComboBox1Change
    Items.Strings = (
      #937
      'K'#937
      'M'#937
      'mF'
      'uF'
      'nF'
      'pF'
      #28961)
  end
  object ComboBox2: TComboBox
    Left = 328
    Top = 168
    Width = 81
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 7
    Items.Strings = (
      #937
      'K'#937
      'M'#937
      'mF'
      'uF'
      'nF'
      'pF'
      #28961)
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
