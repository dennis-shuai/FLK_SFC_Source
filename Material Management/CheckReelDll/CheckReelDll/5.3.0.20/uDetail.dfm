object fDetail: TfDetail
  Left = 210
  Top = 158
  BorderStyle = bsNone
  ClientHeight = 371
  ClientWidth = 680
  Color = clSilver
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 39
    Top = 5
    Width = 126
    Height = 16
    Caption = 'RT / Item Maintain'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label10: TLabel
    Left = 32
    Top = 6
    Width = 126
    Height = 16
    Caption = 'RT / Item Maintain'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 680
    Height = 371
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    object ImageAll: TImage
      Left = 0
      Top = 0
      Width = 680
      Height = 371
      Align = alClient
      ParentShowHint = False
      ShowHint = False
      Transparent = True
    end
    object Bevel2: TBevel
      Left = 7
      Top = 58
      Width = 629
      Height = 199
    end
    object LabTitle2: TLabel
      Left = 8
      Top = 6
      Width = 82
      Height = 16
      Caption = 'Check Reel'
      Font.Charset = CHINESEBIG5_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabTitle1: TLabel
      Left = 7
      Top = 5
      Width = 82
      Height = 16
      Caption = 'Check Reel'
      Font.Charset = CHINESEBIG5_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label7: TLabel
      Left = 11
      Top = 34
      Width = 91
      Height = 16
      Caption = 'BOX/QTY No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lablType: TLabel
      Left = 96
      Top = 184
      Width = 5
      Height = 16
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lablOutput: TLabel
      Left = 288
      Top = 184
      Width = 5
      Height = 16
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 8
      Top = 264
      Width = 43
      Height = 13
      Caption = 'ID_NO:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label6: TLabel
      Left = 8
      Top = 288
      Width = 53
      Height = 13
      Caption = 'Part_NO:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label8: TLabel
      Left = 8
      Top = 312
      Width = 52
      Height = 13
      Caption = 'Reel_no:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label9: TLabel
      Left = 8
      Top = 336
      Width = 30
      Height = 13
      Caption = 'QTY:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LBLmaterialno: TLabel
      Left = 464
      Top = 432
      Width = 233
      Height = 16
      Caption = '                                                          '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblstatus: TLabel
      Left = 392
      Top = 296
      Width = 329
      Height = 16
      Caption = 
        '                                                                ' +
        '                  '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object edtBOXNO: TEdit
      Left = 104
      Top = 32
      Width = 153
      Height = 21
      TabOrder = 0
      OnKeyPress = edtBOXNOKeyPress
    end
    object StringGridReel: TStringGrid
      Left = 8
      Top = 64
      Width = 625
      Height = 185
      ColCount = 9
      FixedCols = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
      TabOrder = 1
    end
    object Editidno: TEdit
      Left = 88
      Top = 264
      Width = 417
      Height = 21
      Color = clYellow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      Text = 'EditIDNO'
      OnKeyDown = EditidnoKeyDown
    end
    object Editpartno: TEdit
      Left = 88
      Top = 288
      Width = 169
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ReadOnly = True
      TabOrder = 3
      Text = 'EditPARTNO'
    end
    object EditREELNO: TEdit
      Left = 88
      Top = 312
      Width = 241
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ReadOnly = True
      TabOrder = 4
      Text = 'EditreelNO'
    end
    object Editqty: TEdit
      Left = 88
      Top = 336
      Width = 121
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ReadOnly = True
      TabOrder = 5
      Text = 'EditQTY'
    end
  end
  object QryMaterial: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 488
    Top = 120
  end
  object DataSource1: TDataSource
    AutoEdit = False
    DataSet = QryMaterial
    Left = 424
    Top = 128
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 96
    Top = 128
  end
  object SaveDialog1: TSaveDialog
    Left = 72
    Top = 104
  end
  object QryDetail: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 168
    Top = 136
  end
  object DataSource2: TDataSource
    AutoEdit = False
    DataSet = QryDetail
    Left = 200
    Top = 136
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 168
    Top = 104
  end
end
