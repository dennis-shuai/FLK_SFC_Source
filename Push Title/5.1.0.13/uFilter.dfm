object fFilter: TfFilter
  Left = 165
  Top = 146
  Width = 739
  Height = 536
  Color = 16775416
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 731
    Height = 483
    Align = alClient
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 0
    Width = 731
    Height = 483
    Align = alClient
    DataSource = OraDataSource1
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    OnDblClick = DBGrid1DblClick
    OnKeyPress = DBGrid1KeyPress
    OnTitleClick = DBGrid1TitleClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 483
    Width = 731
    Height = 19
    Color = 16775416
    Panels = <
      item
        Width = 180
      end
      item
        Width = 50
      end>
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 248
    Top = 128
  end
  object OraDataSource1: TOraDataSource
    DataSet = ClientDataSet1
    Left = 200
    Top = 112
  end
end
