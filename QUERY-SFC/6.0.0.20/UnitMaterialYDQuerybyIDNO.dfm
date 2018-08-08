object FormYDQueryByIDNO: TFormYDQueryByIDNO
  Left = 253
  Top = 171
  Width = 735
  Height = 483
  BorderIcons = [biSystemMenu]
  Caption = 'FormYDQueryByIDNO'
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
    Left = 272
    Top = 16
    Width = 232
    Height = 24
    Caption = #30064#21205#26597#35426' BY ID_NO        '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 16
    Top = 424
    Width = 71
    Height = 13
    Caption = 'Record_count:'
  end
  object lblrecordcount: TLabel
    Left = 96
    Top = 424
    Width = 67
    Height = 13
    Caption = 'lblrecordcount'
  end
  object Label4: TLabel
    Left = 448
    Top = 424
    Width = 159
    Height = 13
    Caption = #27880': ID NO '#20837#24235#20197#24460#30340#30064#21205#26597#35426
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 56
    Width = 713
    Height = 49
    TabOrder = 0
    object Label2: TLabel
      Left = 16
      Top = 16
      Width = 36
      Height = 13
      Caption = 'ID_NO:'
    end
    object Editidno: TEdit
      Left = 64
      Top = 16
      Width = 153
      Height = 21
      CharCase = ecUpperCase
      TabOrder = 0
      Text = 'EDITIDNO'
      OnKeyDown = EditidnoKeyDown
    end
    object btnclose: TButton
      Left = 320
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 1
      OnClick = btncloseClick
    end
    object btnquery: TButton
      Left = 240
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Query'
      TabOrder = 2
      OnClick = btnqueryClick
    end
  end
  object StringGridIDNO: TStringGrid
    Left = 8
    Top = 120
    Width = 713
    Height = 297
    ColCount = 10
    FixedCols = 0
    RowCount = 10
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowMoving, goColMoving, goRowSelect]
    TabOrder = 1
  end
  object ClientDataSetmaterialydbyidno: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 8
  end
end
