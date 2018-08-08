object FormQueryCheckMaterialByWO: TFormQueryCheckMaterialByWO
  Left = 123
  Top = 161
  Width = 843
  Height = 487
  BorderIcons = [biSystemMenu]
  Caption = 'FormQueryCheckMaterialByWO'
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 320
    Top = 16
    Width = 202
    Height = 20
    Caption = #24037#21934#20633#26009'ID_NO'#26597#35426'         '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 16
    Top = 408
    Width = 40
    Height = 16
    Caption = #24037#21934#65306
  end
  object Label3: TLabel
    Left = 216
    Top = 408
    Width = 53
    Height = 16
    Caption = #26009#34399#65306#12288
  end
  object LABEL4: TLabel
    Left = 432
    Top = 408
    Width = 109
    Height = 16
    Caption = 'Record_count:  '
  end
  object DBGrid1: TDBGrid
    Left = 8
    Top = 48
    Width = 817
    Height = 345
    DataSource = DataSource1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clBlack
    TitleFont.Height = -13
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = [fsBold]
  end
  object Butquery: TButton
    Left = 664
    Top = 400
    Width = 75
    Height = 25
    Caption = 'QUERY'
    TabOrder = 1
    OnClick = ButqueryClick
  end
  object ButCLOSE: TButton
    Left = 744
    Top = 400
    Width = 75
    Height = 25
    Caption = 'CLOSE'
    TabOrder = 2
    OnClick = ButCLOSEClick
  end
  object EditWO: TEdit
    Left = 72
    Top = 408
    Width = 121
    Height = 24
    CharCase = ecUpperCase
    TabOrder = 3
    Text = 'EDITWO'
  end
  object Editpart_no: TEdit
    Left = 272
    Top = 408
    Width = 145
    Height = 24
    CharCase = ecUpperCase
    TabOrder = 4
    Text = 'EDITPART_NO'
    OnKeyDown = Editpart_noKeyDown
  end
  object Editrecordcount: TEdit
    Left = 544
    Top = 408
    Width = 81
    Height = 24
    ReadOnly = True
    TabOrder = 5
    Text = 'Editrecordcount'
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 8
    Top = 8
  end
  object DataSource1: TDataSource
    DataSet = ClientDataSet1
    Left = 48
    Top = 8
  end
end
