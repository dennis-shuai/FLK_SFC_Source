object FormEDIIN856Query: TFormEDIIN856Query
  Left = 221
  Top = 129
  Width = 696
  Height = 587
  BorderIcons = [biSystemMenu]
  Caption = 'FormEDIIN856Query'
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
    Left = 264
    Top = 16
    Width = 176
    Height = 24
    Caption = 'EDI IN 856 QUERY'
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
    Text = 'DOC'
    OnChange = CMBIDTYPEChange
    Items.Strings = (
      'DOC'
      'Pallet'
      'Carton'
      'Shipping_Number')
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
  object GroupBox1: TGroupBox
    Left = 24
    Top = 72
    Width = 649
    Height = 73
    TabOrder = 3
    object Label2: TLabel
      Left = 8
      Top = 16
      Width = 73
      Height = 13
      Caption = 'Modal_number:'
    end
    object Label3: TLabel
      Left = 136
      Top = 16
      Width = 90
      Height = 13
      Caption = 'Cust_item_number:'
    end
    object Label4: TLabel
      Left = 264
      Top = 16
      Width = 66
      Height = 13
      Caption = 'Item_quantity:'
    end
    object Label5: TLabel
      Left = 520
      Top = 16
      Width = 74
      Height = 13
      Caption = 'Shipment_date:'
    end
    object Label9: TLabel
      Left = 392
      Top = 16
      Width = 77
      Height = 13
      Caption = 'Shipper_number'
    end
    object Editmodalnumber: TEdit
      Left = 8
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 0
      Text = 'Editmodalnumber'
    end
    object Editcustitemnumber: TEdit
      Left = 136
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 1
      Text = 'Editcustitemnumber'
    end
    object Edititemquantity: TEdit
      Left = 264
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 2
      Text = 'Edititemquantity'
    end
    object Editshipmentdate: TEdit
      Left = 520
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 3
      Text = 'Editshipmentdate'
    end
    object Editshippernumber: TEdit
      Left = 392
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 4
      Text = 'Editshippernumber'
    end
  end
  object GroupBox2: TGroupBox
    Left = 24
    Top = 152
    Width = 329
    Height = 153
    Caption = 'Pallet:'
    TabOrder = 4
    object Label6: TLabel
      Left = 8
      Top = 136
      Width = 33
      Height = 13
      Caption = 'Total:  '
    end
    object Totalpallet: TLabel
      Left = 40
      Top = 136
      Width = 49
      Height = 13
      Caption = 'Totalpallet'
    end
    object DBGridpallet: TDBGrid
      Left = 8
      Top = 16
      Width = 313
      Height = 113
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      OnDblClick = DBGridpalletDblClick
    end
  end
  object GroupBox3: TGroupBox
    Left = 24
    Top = 312
    Width = 329
    Height = 225
    Caption = 'Carton:'
    TabOrder = 5
    object Label7: TLabel
      Left = 8
      Top = 208
      Width = 36
      Height = 13
      Caption = 'Total:   '
    end
    object Totalcarton: TLabel
      Left = 40
      Top = 208
      Width = 54
      Height = 13
      Caption = 'Totalcarton'
    end
    object DBGridcarton: TDBGrid
      Left = 8
      Top = 16
      Width = 313
      Height = 185
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      OnDblClick = DBGridcartonDblClick
    end
  end
  object GroupBox4: TGroupBox
    Left = 360
    Top = 152
    Width = 313
    Height = 385
    Caption = 'Serial:'
    TabOrder = 6
    object Label8: TLabel
      Left = 8
      Top = 368
      Width = 36
      Height = 13
      Caption = 'Total:   '
    end
    object Totalserial: TLabel
      Left = 40
      Top = 368
      Width = 48
      Height = 13
      Caption = 'Totalserial'
    end
    object StringGridserial: TStringGrid
      Left = 16
      Top = 16
      Width = 289
      Height = 345
      TabOrder = 0
    end
    object btnSave: TButton
      Left = 256
      Top = 368
      Width = 57
      Height = 17
      Caption = 'Save'
      TabOrder = 1
      OnClick = btnSaveClick
    end
    object ProgressBarserial: TProgressBar
      Left = 104
      Top = 368
      Width = 145
      Height = 17
      TabOrder = 2
    end
  end
  object BTNclose: TButton
    Left = 376
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 7
    OnClick = BTNcloseClick
  end
  object ClientDataSetpallet: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 16
  end
  object DSpallet: TDataSource
    DataSet = ClientDataSetpallet
    Left = 56
  end
  object DSCarton: TDataSource
    DataSet = ClientDataSetcarton
    Left = 128
  end
  object DSserial: TDataSource
    DataSet = ClientDataSetserial
    Left = 208
  end
  object DSNULL: TDataSource
    Left = 248
  end
  object ClientDataSetcarton: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 88
  end
  object ClientDataSetserial: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 168
  end
  object ClientDataSetdoc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 464
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '*.xls'
    Filter = '*.xls|*.xls'
    Left = 496
  end
end
