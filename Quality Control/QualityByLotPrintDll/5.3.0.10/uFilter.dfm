object fFilter: TfFilter
  Left = 244
  Top = 278
  BorderStyle = bsSingle
  ClientHeight = 309
  ClientWidth = 465
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
  object DBGrid11: TDBGrid1
    Left = 0
    Top = 0
    Width = 465
    Height = 309
    Align = alClient
    DataSource = DataSource1
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    OnDblClick = DBGrid11DblClick
    Columns = <
      item
        Expanded = False
        FieldName = 'WORK_ORDER'
        Title.Caption = 'Work Order'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'MS Sans Serif'
        Title.Font.Style = [fsBold]
        Width = 127
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'PART_NO'
        Title.Caption = 'Part No'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'MS Sans Serif'
        Title.Font.Style = [fsBold]
        Width = 149
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'WO_STATUS'
        Title.Caption = 'WO Status'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'MS Sans Serif'
        Title.Font.Style = [fsBold]
        Width = 136
        Visible = True
      end>
  end
  object DataSource1: TDataSource
    DataSet = qryData
    Left = 240
    Top = 176
  end
  object qryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 64
    Top = 176
  end
end
