object fDetail: TfDetail
  Left = 345
  Top = 175
  BorderStyle = bsNone
  ClientHeight = 554
  ClientWidth = 998
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
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 998
    Height = 554
    Align = alClient
    Color = clCaptionText
    TabOrder = 0
    object ImageAll: TImage
      Left = 1
      Top = 1
      Width = 996
      Height = 552
      Align = alClient
      ParentShowHint = False
      ShowHint = False
      Transparent = True
    end
    object lblLabTitle2: TLabel
      Left = 32
      Top = 16
      Width = 106
      Height = 20
      Caption = 'Status Query'
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
      Width = 106
      Height = 20
      Caption = 'Status Query'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label1: TLabel
      Left = 64
      Top = 72
      Width = 78
      Height = 20
      Caption = 'Pallet No:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 64
      Top = 144
      Width = 100
      Height = 20
      AutoSize = False
      Caption = #27491#24120#21697#25976#37327':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label3: TLabel
      Left = 64
      Top = 216
      Width = 100
      Height = 20
      AutoSize = False
      Caption = #32173#20462#21697#25976#37327':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblNCount: TLabel
      Left = 184
      Top = 136
      Width = 150
      Height = 40
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -32
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblDCount: TLabel
      Left = 184
      Top = 208
      Width = 150
      Height = 40
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -32
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object edtPallet: TEdit
      Left = 160
      Top = 72
      Width = 233
      Height = 21
      Color = clYellow
      TabOrder = 0
      OnKeyPress = edtPalletKeyPress
    end
  end
  object QryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 360
    Top = 392
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp'
    Left = 416
    Top = 392
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 480
    Top = 392
  end
  object DataSource1: TDataSource
    DataSet = QryData
    Left = 807
    Top = 22
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Excel Document|*.xls'
    Left = 856
    Top = 24
  end
  object QryDefect: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 557
    Top = 396
  end
  object DataSource2: TDataSource
    DataSet = QryDefect
    Left = 913
    Top = 42
  end
end
