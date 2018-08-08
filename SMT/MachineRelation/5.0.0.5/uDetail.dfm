object fDetail: TfDetail
  Left = 611
  Top = 213
  Width = 450
  Height = 427
  Caption = 'Part No'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 0
    Top = 0
    Width = 442
    Height = 393
    Align = alClient
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    OnDblClick = DBGrid1DblClick
  end
  object Qrypart: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 232
    Top = 48
  end
  object DataSource1: TDataSource
    DataSet = Qrypart
    Left = 320
    Top = 56
  end
end
