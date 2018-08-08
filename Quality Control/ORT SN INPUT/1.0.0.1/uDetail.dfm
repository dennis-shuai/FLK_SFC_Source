object fDetail: TfDetail
  Left = 202
  Top = 112
  BorderStyle = bsNone
  ClientHeight = 709
  ClientWidth = 1171
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 1171
    Height = 709
    Align = alClient
    Color = clCaptionText
    TabOrder = 0
    object ImageAll: TImage
      Left = 1
      Top = 1
      Width = 1169
      Height = 707
      Align = alClient
      ParentShowHint = False
      ShowHint = False
      Transparent = True
    end
    object lblLabTitle2: TLabel
      Left = 32
      Top = 16
      Width = 128
      Height = 20
      Caption = 'ORT SN INPUT '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblLabTitle1: TLabel
      Left = 31
      Top = 15
      Width = 128
      Height = 20
      Caption = 'ORT SN INPUT '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label1: TLabel
      Left = 40
      Top = 104
      Width = 80
      Height = 20
      Caption = #26009#34399':       :'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblNCount: TLabel
      Left = 40
      Top = 624
      Width = 177
      Height = 24
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label3: TLabel
      Left = 40
      Top = 56
      Width = 145
      Height = 20
      AutoSize = False
      Caption = 'ORT '#38917#30446#21517#31281':      '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label4: TLabel
      Left = 40
      Top = 152
      Width = 55
      Height = 20
      Caption = #26781#30908':   '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object sbtnNewLot: TSpeedButton
      Left = 400
      Top = 48
      Width = 25
      Height = 28
      Flat = True
      Glyph.Data = {
        DE000000424DDE0000000000000076000000280000000D0000000D0000000100
        0400000000006800000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFF2222FFF
        F000FFFFAAAA2FFFF000FFFFAAAA2FFFF000FFFFAAAA2FFFF000F222AAAA2222
        2000AAAAAAAAAAAA2000AAAAAAAAAAAA2000AAAAAAAAAAAA2000AAAAAAAAAAAA
        F000FFFFAAAA2FFFF000FFFFAAAA2FFFF000FFFFAAAA2FFFF000FFFFAAAAFFFF
        F000}
      Spacing = 0
      OnClick = sbtnNewLotClick
    end
    object edtPartNo: TEdit
      Left = 200
      Top = 96
      Width = 233
      Height = 28
      Color = clYellow
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnChange = edtPartNoChange
    end
    object edtSN: TEdit
      Left = 200
      Top = 144
      Width = 233
      Height = 28
      Color = clYellow
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnKeyPress = edtSNKeyPress
    end
    object cmbName: TComboBox
      Left = 200
      Top = 48
      Width = 201
      Height = 28
      Color = clYellow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ItemHeight = 20
      ParentFont = False
      TabOrder = 2
      OnSelect = cmbNameSelect
    end
    object DBGrid1: TDBGrid
      Left = 40
      Top = 192
      Width = 697
      Height = 425
      DataSource = DataSource1
      TabOrder = 3
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'ORT_NAME'
          Width = 150
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'SERIAL_NUMBER'
          Width = 80
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'PART_NO'
          Width = 80
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CUSTOMER_SN'
          Width = 85
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'EMP_NO'
          Width = 60
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'EMP_NAME'
          Width = 65
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'UPDATE_TIME'
          Width = 80
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ENABLED'
          Visible = True
        end>
    end
  end
  object QryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 360
    Top = 392
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp'
    Left = 416
    Top = 392
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 480
    Top = 392
  end
  object DataSource1: TDataSource
    DataSet = QryData
    Left = 807
    Top = 22
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Excel Document|*.xls'
    Left = 856
    Top = 24
  end
  object QryDefect: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 557
    Top = 396
  end
  object DataSource2: TDataSource
    DataSet = QryDefect
    Left = 913
    Top = 42
  end
end
