object FormMaterialRT: TFormMaterialRT
  Left = 359
  Top = 209
  Width = 859
  Height = 490
  Caption = #29289#26009#26597#35426'RT'#21934#34399
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 40
    Top = 40
    Width = 89
    Height = 16
    Caption = 'Matierail No:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object edtMaterial: TEdit
    Left = 144
    Top = 32
    Width = 137
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnKeyPress = edtMaterialKeyPress
  end
  object DBGrid1: TDBGrid
    Left = 3
    Top = 79
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
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clBlack
    TitleFont.Height = -13
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = [fsBold]
    Columns = <
      item
        Expanded = False
        FieldName = 'RT_NO'
        Width = 57
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'PART_NO'
        Width = 110
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DATECODE'
        Width = 90
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'RECEIVE_TIME'
        Width = 110
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'INCOMING_QTY'
        Width = 120
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'MFGER_NAME'
        Width = 110
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'PRINT_QTY'
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'TYPE'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'MFGER_PART_NO'
        Width = 70
        Visible = True
      end>
  end
  object QryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    RemoteServer = FormMain.SocketConnection1
    Left = 16
    Top = 8
  end
  object DataSource1: TDataSource
    DataSet = QryData
    Left = 96
    Top = 16
  end
end
