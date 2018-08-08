object Form1: TForm1
  Left = 175
  Top = 0
  Width = 1007
  Height = 724
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 999
    Height = 697
    Align = alClient
    Color = clCaptionText
    TabOrder = 0
    object ImageAll: TImage
      Left = 1
      Top = 1
      Width = 997
      Height = 695
      Align = alClient
      ParentShowHint = False
      ShowHint = False
      Transparent = True
    end
    object lblLabTitle2: TLabel
      Left = 32
      Top = 16
      Width = 139
      Height = 20
      AutoSize = False
      Caption = 'COB Carry '#36942#31449'   '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblLabTitle1: TLabel
      Left = 31
      Top = 15
      Width = 139
      Height = 20
      AutoSize = False
      Caption = 'COB Carry '#36942#31449'   '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label1: TLabel
      Left = 32
      Top = 104
      Width = 113
      Height = 28
      AutoSize = False
      Caption = 'Carrier No.:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblMsg: TLabel
      Left = 32
      Top = 152
      Width = 473
      Height = 121
      Alignment = taCenter
      AutoSize = False
      Color = clGreen
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Layout = tlCenter
    end
    object lblTerminal: TLabel
      Left = 56
      Top = 48
      Width = 5
      Height = 16
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lbl1: TLabel
      Left = 32
      Top = 56
      Width = 55
      Height = 20
      Caption = 'Pdline:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lbl2: TLabel
      Left = 312
      Top = 56
      Width = 74
      Height = 20
      Caption = 'Terminal:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object edtOldCar: TEdit
      Left = 144
      Top = 104
      Width = 305
      Height = 21
      Color = clYellow
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      TabOrder = 0
      OnKeyPress = edtOldCarKeyPress
    end
    object cmbPdline: TComboBox
      Left = 112
      Top = 56
      Width = 177
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ItemHeight = 16
      ParentFont = False
      TabOrder = 1
      OnSelect = cmbPdlineSelect
      Items.Strings = (
        'COB_Plasma'
        'COB_PCB_Bake'
        'COB_DB_A'
        'COB_DB_B'
        'COB_DB_C'
        'COB_DB_D'
        'COB_DB_E'
        'COB_DB_F'
        'COB_HM_01'
        'COB_HM_02'
        'COB_HM_03'
        'COB_HM_04'
        'COB_HM_05'
        'COB_HM_06'
        'COB_HM_07'
        'COB_HM_08')
    end
    object cmbTerminal: TComboBox
      Left = 400
      Top = 56
      Width = 217
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ItemHeight = 16
      ParentFont = False
      TabOrder = 2
      OnSelect = cmbTerminalSelect
    end
  end
  object QryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 832
    Top = 280
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp'
    Left = 712
    Top = 288
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 760
    Top = 280
  end
  object DataSource1: TDataSource
    DataSet = QryData
    Left = 487
    Top = 22
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Excel Document|*.xls'
    Left = 856
    Top = 24
  end
end
