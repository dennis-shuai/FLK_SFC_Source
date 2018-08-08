object FormQUERYWOBOMERPTOSFC: TFormQUERYWOBOMERPTOSFC
  Left = 255
  Top = 116
  Width = 648
  Height = 596
  Caption = 'FormQUERYWOBOMERPTOSFC'
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
    Left = 192
    Top = 8
    Width = 228
    Height = 20
    Caption = 'BOM ERP TO SFC'#26597#35426'         '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LABEL4: TLabel
    Left = 24
    Top = 520
    Width = 109
    Height = 16
    Caption = 'Record_count:  '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Butquery: TButton
    Left = 525
    Top = 8
    Width = 75
    Height = 25
    Caption = 'QUERY'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = ButqueryClick
  end
  object ButCLOSE: TButton
    Left = 525
    Top = 520
    Width = 75
    Height = 25
    Caption = 'CLOSE'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = ButCLOSEClick
  end
  object Editrecordcount: TEdit
    Left = 144
    Top = 520
    Width = 81
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    ReadOnly = True
    TabOrder = 2
    Text = 'Editrecordcount'
  end
  object GroupBox1: TGroupBox
    Left = 24
    Top = 40
    Width = 593
    Height = 113
    TabOrder = 3
    object Label2: TLabel
      Left = 16
      Top = 17
      Width = 52
      Height = 16
      Caption = #24037#21934#65306'   '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 200
      Top = 17
      Width = 74
      Height = 16
      Caption = 'STATUS:  '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 136
      Top = 57
      Width = 98
      Height = 16
      Caption = 'INPUT_QTY:  '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 240
      Top = 57
      Width = 115
      Height = 16
      Caption = 'OUTPUT_QTY:  '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label7: TLabel
      Left = 472
      Top = 57
      Width = 65
      Height = 16
      Caption = 'TO_ERP:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblscrap_qty: TLabel
      Left = 360
      Top = 57
      Width = 103
      Height = 16
      Caption = 'SCRAP_QTY:  '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = lblscrap_qtyClick
    end
    object Label9: TLabel
      Left = 16
      Top = 56
      Width = 114
      Height = 16
      Caption = 'TARGET_QTY:  '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object EditWO: TEdit
      Left = 64
      Top = 17
      Width = 121
      Height = 24
      CharCase = ecUpperCase
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      Text = 'EDITWO'
    end
    object Editstatus: TEdit
      Left = 272
      Top = 17
      Width = 241
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      Text = 'EditSTATUS'
    end
    object Edittoerp: TEdit
      Left = 472
      Top = 81
      Width = 105
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      Text = 'EditTOERP'
    end
    object Editinputqty: TEdit
      Left = 128
      Top = 81
      Width = 105
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      Text = 'EditINPUTQTY'
    end
    object Editoutputqty: TEdit
      Left = 240
      Top = 81
      Width = 105
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      Text = 'EditOUTPUTQTY'
    end
    object Editscrapqty: TEdit
      Left = 360
      Top = 81
      Width = 105
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      Text = 'EditSCRAPQTY'
    end
    object Edittargetqty: TEdit
      Left = 16
      Top = 80
      Width = 105
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      Text = 'Edittargetqty'
    end
  end
  object DBGrid1: TDBGrid
    Left = 24
    Top = 160
    Width = 593
    Height = 353
    DataSource = DataSource1
    ReadOnly = True
    TabOrder = 4
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 72
    Top = 8
  end
  object DataSource1: TDataSource
    DataSet = ClientDataSet1
    Left = 112
    Top = 8
  end
  object ClientDataSetWO: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 8
  end
end
