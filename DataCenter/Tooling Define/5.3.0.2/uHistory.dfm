object fHistory: TfHistory
  Left = 247
  Top = 176
  Width = 583
  Height = 479
  Caption = 'History Log'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 575
    Height = 29
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 63
      Height = 13
      Caption = 'Tooling No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object editCode: TEdit
      Left = 112
      Top = 3
      Width = 121
      Height = 21
      TabOrder = 0
      OnKeyPress = editCodeKeyPress
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 29
    Width = 575
    Height = 416
    Align = alClient
    DataSource = DataSource1
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object QryData1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData1'
    Left = 128
    Top = 168
  end
  object DataSource1: TDataSource
    AutoEdit = False
    DataSet = QryData1
    Left = 200
    Top = 168
  end
end
