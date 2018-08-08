object FormWIPQCQuery: TFormWIPQCQuery
  Left = 241
  Top = 129
  Width = 696
  Height = 505
  BorderIcons = [biSystemMenu]
  Caption = 'FormWIPQCQuery'
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
    Left = 296
    Top = 16
    Width = 94
    Height = 24
    Caption = 'QC Query'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 16
    Top = 432
    Width = 83
    Height = 13
    Caption = 'Recordcount:      '
  end
  object lblrecordcount: TLabel
    Left = 88
    Top = 432
    Width = 57
    Height = 13
    Caption = 'recordcount'
  end
  object labltotal: TLabel
    Left = 280
    Top = 432
    Width = 66
    Height = 13
    Caption = 'Total Lot_size'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 48
    Width = 673
    Height = 49
    TabOrder = 0
    object Label2: TLabel
      Left = 8
      Top = 16
      Width = 27
      Height = 13
      Caption = 'Type:'
    end
    object CMBTYPE: TComboBox
      Left = 40
      Top = 16
      Width = 113
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'Work_Order'
      Items.Strings = (
        'Work_Order'
        'QC LOT_NO'
        'QC QTY_ID')
    end
    object EditTYPE: TEdit
      Left = 152
      Top = 16
      Width = 249
      Height = 21
      TabOrder = 1
      Text = 'EditTYPE'
      OnKeyDown = EditTYPEKeyDown
    end
    object BTNQUERY: TButton
      Left = 408
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Query'
      TabOrder = 2
      OnClick = BTNQUERYClick
    end
    object BTNCLOSE: TButton
      Left = 488
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 3
      OnClick = BTNCLOSEClick
    end
  end
  object StringgridQC: TStringGrid
    Left = 8
    Top = 112
    Width = 673
    Height = 313
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowSelect]
    TabOrder = 1
  end
  object EditTotal: TEdit
    Left = 360
    Top = 432
    Width = 121
    Height = 21
    TabOrder = 2
  end
  object ClientDataSetqc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 8
  end
end
