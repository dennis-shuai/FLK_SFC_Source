object fItem: TfItem
  Left = 339
  Top = 212
  Width = 470
  Height = 350
  Caption = 'Item'
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
  object LVItem: TListView
    Left = 0
    Top = 0
    Width = 462
    Height = 316
    Align = alClient
    Columns = <
      item
        Caption = 'Part No'
        Width = 120
      end
      item
        Caption = 'Ver'
        Width = 80
      end
      item
        Caption = 'Description'
        Width = 150
      end
      item
        Caption = 'Location'
        Width = 100
      end>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    SortType = stText
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = LVItemDblClick
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 200
    Top = 128
  end
end
