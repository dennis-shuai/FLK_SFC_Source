object FormWipRepairresultforQC: TFormWipRepairresultforQC
  Left = 196
  Top = 165
  Width = 836
  Height = 480
  BorderIcons = [biSystemMenu]
  Caption = 'FormWipRepairresultforQC'
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 296
    Top = 8
    Width = 255
    Height = 20
    Caption = 'Repair Result Query For QC      '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 8
    Top = 424
    Width = 71
    Height = 13
    Caption = 'Record_count:'
  end
  object lblrecordcount: TLabel
    Left = 88
    Top = 424
    Width = 67
    Height = 13
    Caption = 'lblrecordcount'
  end
  object GroupBox1: TGroupBox
    Left = 7
    Top = 40
    Width = 538
    Height = 73
    TabOrder = 0
    object Label5: TLabel
      Left = 8
      Top = 16
      Width = 58
      Height = 13
      Caption = 'Time   From:'
    end
    object Label6: TLabel
      Left = 224
      Top = 16
      Width = 15
      Height = 13
      Caption = 'TO'
    end
    object Label2: TLabel
      Left = 8
      Top = 48
      Width = 39
      Height = 13
      Caption = #27231' '#31278#65306
    end
    object Label8: TLabel
      Left = 216
      Top = 48
      Width = 41
      Height = 13
      Caption = 'Process:'
    end
    object btnclose: TButton
      Left = 440
      Top = 40
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 0
      OnClick = btncloseClick
    end
    object btnquery: TButton
      Left = 440
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Query'
      TabOrder = 1
      OnClick = btnqueryClick
    end
    object DateTimePickerSTART: TDateTimePicker
      Left = 72
      Top = 16
      Width = 137
      Height = 21
      Date = 39087.486522164350000000
      Time = 39087.486522164350000000
      TabOrder = 2
    end
    object DateTimePickerEND: TDateTimePicker
      Left = 264
      Top = 16
      Width = 145
      Height = 21
      Date = 39087.486643692130000000
      Time = 39087.486643692130000000
      TabOrder = 3
    end
    object cmbboxmodelname: TComboBox
      Left = 72
      Top = 48
      Width = 137
      Height = 21
      ItemHeight = 13
      TabOrder = 4
      Text = 'cmbboxmodelname'
    end
    object cmbboxprocess: TComboBox
      Left = 264
      Top = 48
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 5
      Text = 'cmbboxprocess'
    end
  end
  object StringGridrepair: TStringGrid
    Left = 6
    Top = 112
    Width = 810
    Height = 297
    ColCount = 9
    FixedCols = 0
    RowCount = 12
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowMoving, goColMoving, goRowSelect]
    TabOrder = 1
  end
  object Progressfeeder: TProgressBar
    Left = 216
    Top = 424
    Width = 217
    Height = 17
    TabOrder = 2
  end
  object Btnsave: TButton
    Left = 448
    Top = 424
    Width = 89
    Height = 17
    Caption = 'Save to *.txt'
    TabOrder = 3
    OnClick = BtnsaveClick
  end
  object ClientDatasetrepair: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 16
    Top = 8
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '*.txt'
    Filter = '*.txt|*.txt'
    Left = 56
    Top = 8
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 104
    Top = 8
  end
end
