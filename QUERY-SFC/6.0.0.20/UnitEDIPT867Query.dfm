object FormEDIPT867: TFormEDIPT867
  Left = 284
  Top = 190
  Width = 709
  Height = 500
  BorderIcons = [biSystemMenu]
  Caption = 'FormEDIPT867'
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
    Top = 8
    Width = 161
    Height = 29
    Caption = 'PT 867 Query'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -24
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 48
    Width = 457
    Height = 49
    TabOrder = 0
    object btnCLOSE: TButton
      Left = 368
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 0
      OnClick = btnCLOSEClick
    end
    object CMBIDTYPE: TComboBox
      Left = 8
      Top = 16
      Width = 97
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 1
      Text = 'Work_order'
      Items.Strings = (
        'Work_order'
        'Pallet')
    end
    object Editidtype: TEdit
      Left = 104
      Top = 16
      Width = 169
      Height = 21
      CharCase = ecUpperCase
      TabOrder = 2
      Text = 'EDITIDTYPE'
    end
    object BtnQuery: TButton
      Left = 280
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Query'
      TabOrder = 3
      OnClick = BtnQueryClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 16
    Top = 96
    Width = 665
    Height = 353
    TabOrder = 1
    object Label2: TLabel
      Left = 16
      Top = 336
      Width = 71
      Height = 13
      Caption = 'Record_count:'
    end
    object lblrecordcount: TLabel
      Left = 96
      Top = 336
      Width = 76
      Height = 13
      Caption = 'RRecord_count'
    end
    object DBGridPT867: TDBGrid
      Left = 8
      Top = 8
      Width = 649
      Height = 321
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      OnDblClick = DBGridPT867DblClick
    end
  end
  object GroupBoxpallet: TGroupBox
    Left = 16
    Top = 48
    Width = 665
    Height = 401
    TabOrder = 2
    object GroupBox3: TGroupBox
      Left = 336
      Top = 0
      Width = 329
      Height = 401
      Caption = 'HDD:'
      TabOrder = 0
      object Label4: TLabel
        Left = 16
        Top = 384
        Width = 71
        Height = 13
        Caption = 'Record_count:'
      end
      object lblreference: TLabel
        Left = 96
        Top = 384
        Width = 55
        Height = 13
        Caption = 'lblreference'
      end
      object DBGridreference: TDBGrid
        Left = 8
        Top = 16
        Width = 313
        Height = 361
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'MS Sans Serif'
        TitleFont.Style = []
      end
      object btnclose1: TButton
        Left = 264
        Top = 384
        Width = 57
        Height = 17
        Caption = 'Close'
        TabOrder = 1
        OnClick = btnclose1Click
      end
    end
    object GroupBox4: TGroupBox
      Left = 0
      Top = 0
      Width = 337
      Height = 401
      Caption = 'EDA:'
      TabOrder = 1
      object Label3: TLabel
        Left = 8
        Top = 384
        Width = 71
        Height = 13
        Caption = 'Record_count:'
      end
      object lblserial: TLabel
        Left = 88
        Top = 384
        Width = 34
        Height = 13
        Caption = 'lblserial'
      end
      object DBGridserial: TDBGrid
        Left = 8
        Top = 16
        Width = 321
        Height = 361
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
  object ClientDataSetPT867: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 8
  end
  object DSpt867: TDataSource
    DataSet = ClientDataSetPT867
    Left = 48
  end
  object DSNULL: TDataSource
    Left = 88
  end
  object ClientDataSetserial: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 112
    Top = 176
  end
  object DSserial: TDataSource
    DataSet = ClientDataSetserial
    Left = 152
    Top = 176
  end
  object ClientDataSetreference: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 496
    Top = 176
  end
  object DSReference: TDataSource
    DataSet = ClientDataSetreference
    Left = 536
    Top = 176
  end
end
