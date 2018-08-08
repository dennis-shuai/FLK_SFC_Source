object FormEDIIN861Query: TFormEDIIN861Query
  Left = 244
  Top = 139
  Width = 696
  Height = 467
  BorderIcons = [biSystemMenu]
  Caption = 'FormEDIIN861Query'
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 256
    Top = 16
    Width = 199
    Height = 24
    Caption = 'EDI 861 OUT QUERY'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object CMBIDTYPE: TComboBox
    Left = 24
    Top = 48
    Width = 97
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 0
    Text = '861-OUT-DOC'
    OnChange = CMBIDTYPEChange
    Items.Strings = (
      '861-OUT-DOC'
      'IN-856-DOC'
      'Pallet'
      'Carton')
  end
  object Editidtype: TEdit
    Left = 120
    Top = 48
    Width = 169
    Height = 21
    CharCase = ecUpperCase
    TabOrder = 1
    Text = 'EDITIDTYPE'
  end
  object BtnQuery: TButton
    Left = 296
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Query'
    TabOrder = 2
    OnClick = BtnQueryClick
  end
  object BTNclose: TButton
    Left = 376
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 3
    OnClick = BTNcloseClick
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 80
    Width = 665
    Height = 337
    TabOrder = 4
    object GroupBox2: TGroupBox
      Left = 8
      Top = 8
      Width = 649
      Height = 65
      Caption = 'Envelope:'
      TabOrder = 0
      object DBGridenvelope: TDBGrid
        Left = 8
        Top = 16
        Width = 633
        Height = 41
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'MS Sans Serif'
        TitleFont.Style = []
      end
    end
    object GroupBox3: TGroupBox
      Left = 8
      Top = 72
      Width = 649
      Height = 65
      Caption = 'Header:'
      TabOrder = 1
      object DBGridheader: TDBGrid
        Left = 8
        Top = 16
        Width = 633
        Height = 41
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'MS Sans Serif'
        TitleFont.Style = []
      end
    end
    object GroupBox4: TGroupBox
      Left = 8
      Top = 144
      Width = 289
      Height = 185
      Caption = 'Pallet:'
      TabOrder = 2
      object Label2: TLabel
        Left = 8
        Top = 168
        Width = 54
        Height = 13
        Caption = 'pallet_total:'
      end
      object pallet_total: TLabel
        Left = 72
        Top = 168
        Width = 51
        Height = 13
        Caption = 'pallet_total'
      end
      object DBGridpallet: TDBGrid
        Left = 8
        Top = 16
        Width = 273
        Height = 145
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'MS Sans Serif'
        TitleFont.Style = []
      end
    end
    object GroupBox5: TGroupBox
      Left = 304
      Top = 144
      Width = 353
      Height = 185
      Caption = 'Carton:'
      TabOrder = 3
      object Label3: TLabel
        Left = 16
        Top = 168
        Width = 60
        Height = 13
        Caption = 'Carton_total:'
      end
      object carton_total: TLabel
        Left = 80
        Top = 168
        Width = 56
        Height = 13
        Caption = 'carton_total'
      end
      object DBGridcarton: TDBGrid
        Left = 8
        Top = 16
        Width = 337
        Height = 145
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'MS Sans Serif'
        TitleFont.Style = []
      end
    end
  end
  object ClientDataSetpallet: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 192
  end
  object DSpallet: TDataSource
    DataSet = ClientDataSetpallet
    Left = 232
  end
  object ClientDataSetenvelope: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 8
  end
  object DSENVELOPE: TDataSource
    DataSet = ClientDataSetenvelope
    Left = 48
  end
  object ClientDataSetheader: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 96
  end
  object Dsheader: TDataSource
    DataSet = ClientDataSetheader
    Left = 136
  end
  object ClientDataSetcarton: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 272
  end
  object DSCARTON: TDataSource
    DataSet = ClientDataSetcarton
    Left = 312
  end
  object DSNULL: TDataSource
    Left = 352
  end
end
