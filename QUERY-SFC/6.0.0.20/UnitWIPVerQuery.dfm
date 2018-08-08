object FormWIPverQuery: TFormWIPverQuery
  Left = 309
  Top = 121
  Width = 546
  Height = 410
  BorderIcons = [biSystemMenu]
  Caption = 'FormWIPverQuery'
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
    Left = 216
    Top = 16
    Width = 127
    Height = 24
    Caption = #23792#20301#26597#35426'       '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 48
    Width = 505
    Height = 49
    TabOrder = 0
    object Label2: TLabel
      Left = 8
      Top = 16
      Width = 49
      Height = 13
      Caption = 'PCBA SN:'
    end
    object Label3: TLabel
      Left = 256
      Top = 16
      Width = 45
      Height = 13
      Caption = 'HDD SN:'
    end
    object Editserialnumber: TEdit
      Left = 64
      Top = 16
      Width = 177
      Height = 21
      CharCase = ecUpperCase
      TabOrder = 0
      Text = 'EDITSERIALNUMBER'
      OnKeyDown = EditserialnumberKeyDown
    end
    object Edititempartsn: TEdit
      Left = 312
      Top = 16
      Width = 177
      Height = 21
      CharCase = ecUpperCase
      TabOrder = 1
      Text = 'EDITITEMPARTSN'
      OnKeyDown = EdititempartsnKeyDown
    end
  end
  object GroupBox2: TGroupBox
    Left = 16
    Top = 104
    Width = 513
    Height = 105
    Caption = 'PCBA:'
    TabOrder = 1
    object DBGridpcba: TDBGrid
      Left = 8
      Top = 16
      Width = 489
      Height = 81
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
    Left = 16
    Top = 216
    Width = 513
    Height = 145
    Caption = 'HDD:'
    TabOrder = 2
    object DBGridhdd: TDBGrid
      Left = 8
      Top = 16
      Width = 489
      Height = 121
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
    end
  end
  object BtnCLOSE: TButton
    Left = 448
    Top = 16
    Width = 65
    Height = 25
    Caption = 'Close'
    TabOrder = 3
    OnClick = BtnCLOSEClick
  end
  object ClientDataSetPCBA: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 72
    Top = 176
  end
  object DSPCBA: TDataSource
    DataSet = ClientDataSetPCBA
    Left = 112
    Top = 176
  end
  object ClientDataSetHDD: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 72
    Top = 280
  end
  object DSHDD: TDataSource
    DataSet = ClientDataSetHDD
    Left = 120
    Top = 280
  end
  object DSNULL: TDataSource
    Left = 16
    Top = 8
  end
end
