object FormOut856: TFormOut856
  Left = 250
  Top = 115
  Width = 696
  Height = 489
  Caption = 'FormOut856'
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
    Top = 8
    Width = 146
    Height = 24
    Caption = 'OUT 856 Query'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 40
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
      Text = 'DN_NO'
      Items.Strings = (
        'DN_NO'
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
    Top = 89
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
      Width = 68
      Height = 13
      Caption = 'Record_count'
    end
    object DBGridOUT856: TDBGrid
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
    end
  end
  object ClientDataSetOUT856: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 8
  end
  object DSOUT856: TDataSource
    DataSet = ClientDataSetOUT856
    Left = 48
  end
  object DSNULL: TDataSource
    Left = 88
  end
end
