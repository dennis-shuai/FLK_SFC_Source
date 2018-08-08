object fMainForm: TfMainForm
  Left = 214
  Top = 125
  BorderStyle = bsNone
  ClientHeight = 697
  ClientWidth = 1220
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
    Width = 1220
    Height = 697
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
    Caption = 'QC '#21934'PCS/Panel '#36864#25209#65306
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
    Caption = 'QC '#21934'PCS/Panel '#36864#25209#65306
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label5: TLabel
    Left = 32
    Top = 73
    Width = 185
    Height = 13
    AutoSize = False
    Caption = 'Customer_SN/Panel:'
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
  object lblVersion: TLabel
    Left = 32
    Top = 624
    Width = 39
    Height = 13
    Caption = '1.0.1.1  '
    Transparent = True
  end
  object lblTerminal: TLabel
    Left = 32
    Top = 40
    Width = 585
    Height = 13
    AutoSize = False
    Caption = 'Terminal:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object msgPanel: TPanel
    Left = 30
    Top = 496
    Width = 651
    Height = 105
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
    Left = 170
    Top = 67
    Width = 161
    Height = 21
    CharCase = ecUpperCase
    Color = clYellow
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 1
    OnKeyPress = EdtSNKeyPress
  end
  object pnl1: TPanel
    Left = 32
    Top = 104
    Width = 649
    Height = 377
    Color = clWindow
    TabOrder = 2
    Visible = False
    object lbl1: TLabel
      Left = 8
      Top = 16
      Width = 73
      Height = 13
      Caption = #19981#33391#20195#30908':    '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 336
      Top = 13
      Width = 92
      Height = 13
      Caption = #36899#26495#19981#33391#24207#34399#65306
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 16
      Top = 328
      Width = 601
      Height = 41
      AutoSize = False
      Caption = #21934#38982#19981#29992#21047#19981#33391#13#10#36899#26495#19981#33391#65306#36899#26495#26781#30908'->'#19981#33391#20195#30908'->'#36984#25799#31532#24190#29255#19981#33391#65288#21487#22810#36984')->'#40670#19978#20659#25353#37397#13#10
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -15
      Font.Name = #26032#32048#26126#39636
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDefect: TEdit
      Left = 138
      Top = 11
      Width = 161
      Height = 21
      CharCase = ecUpperCase
      Color = clYellow
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      TabOrder = 0
      OnKeyPress = edtDefectKeyPress
    end
    object cmbSerial: TComboBox
      Left = 440
      Top = 8
      Width = 65
      Height = 21
      ItemHeight = 13
      TabOrder = 1
      OnSelect = cmbSerialSelect
      Items.Strings = (
        '01'
        '02'
        '03'
        '04'
        '05'
        '06'
        '07'
        '08'
        '09'
        '10'
        '11'
        '12'
        '13'
        '14'
        '15'
        '16'
        '17'
        '18'
        '19'
        '20'
        '21'
        '22'
        '23'
        '24'
        '25'
        '26'
        '27'
        '28'
        '29'
        '30'
        '31'
        '32'
        '33'
        '34'
        '35'
        '36'
        '37'
        '38'
        '39'
        '40'
        '41'
        '42'
        '43'
        '44'
        '45'
        '46'
        '47'
        '48'
        '49'
        '50'
        '51'
        '52'
        '53'
        '54'
        '55'
        '56'
        '57'
        '58'
        '59'
        '60'
        '61'
        '62'
        '63'
        '64'
        '65'
        '66'
        '67'
        '68'
        '69'
        '70'
        '71'
        '72'
        '73'
        '74'
        '75'
        '76'
        '77'
        '78'
        '79'
        '80'
        '81'
        '82'
        '83'
        '84'
        '85'
        '86'
        '87'
        '88'
        '89'
        '90'
        '91'
        '92'
        '93'
        '94'
        '95'
        '96'
        '97'
        '98'
        '99')
    end
    object btn1: TButton
      Left = 526
      Top = 8
      Width = 83
      Height = 25
      Caption = #19978#20659
      TabOrder = 2
      OnClick = btn1Click
    end
    object lvData: TListView
      Left = 16
      Top = 64
      Width = 609
      Height = 249
      Align = alCustom
      Columns = <
        item
          Caption = #36899#26495#34399
          Width = 80
        end
        item
          Caption = #24207#21015#34399
          Width = 100
        end
        item
          Caption = #23458#25142#26781#30908
          Width = 100
        end
        item
          Caption = #19981#33391#20195#30908
          Width = 100
        end
        item
          Caption = #19981#33391#29694#35937
          Width = 150
        end
        item
          Caption = #36899#26495#24207#34399
          Width = 60
        end>
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      GridLines = True
      RowSelect = True
      ParentFont = False
      TabOrder = 3
      ViewStyle = vsReport
    end
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 752
    Top = 146
  end
  object QryData: TClientDataSet
    Aggregates = <>
    FieldDefs = <>
    IndexDefs = <>
    Params = <>
    ProviderName = 'DspQryData'
    StoreDefs = True
    Left = 816
    Top = 144
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 848
    Top = 144
  end
  object QryTemp1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 784
    Top = 144
  end
end
