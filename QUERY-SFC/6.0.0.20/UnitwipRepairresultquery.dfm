object FormRepairResultQuery: TFormRepairResultQuery
  Left = 184
  Top = 147
  Width = 840
  Height = 480
  BorderIcons = [biSystemMenu]
  Caption = 'FormRepairResultQuery'
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
    Width = 183
    Height = 20
    Caption = 'Repair Result Query    '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
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
  object GroupBox1: TGroupBox
    Left = 8
    Top = 40
    Width = 801
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
      Left = 264
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
    object Label3: TLabel
      Left = 592
      Top = 48
      Width = 57
      Height = 13
      Caption = 'Repair user:'
    end
    object Label4: TLabel
      Left = 200
      Top = 48
      Width = 22
      Height = 13
      Caption = 'line :'
    end
    object Label8: TLabel
      Left = 384
      Top = 48
      Width = 41
      Height = 13
      Caption = 'Process:'
    end
    object btnclose: TButton
      Left = 712
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 0
      OnClick = btncloseClick
    end
    object btnquery: TButton
      Left = 624
      Top = 16
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
      Left = 288
      Top = 16
      Width = 137
      Height = 21
      Date = 39087.486643692130000000
      Time = 39087.486643692130000000
      TabOrder = 3
    end
    object cmbBoxHSTART: TComboBox
      Left = 208
      Top = 16
      Width = 49
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 4
      Text = '00'
      Items.Strings = (
        '00'
        '01'
        '02'
        '03'
        '04'
        '05'
        '06'
        '07'
        '08'
        '09'
        '10'
        '11'
        '12'
        '13'
        '14'
        '15'
        '16'
        '17'
        '18'
        '19'
        '20'
        '21'
        '22'
        '23')
    end
    object cmbBoxHend: TComboBox
      Left = 432
      Top = 16
      Width = 49
      Height = 21
      ItemHeight = 13
      ItemIndex = 23
      TabOrder = 5
      Text = '24'
      Items.Strings = (
        '01'
        '02'
        '03'
        '04'
        '05'
        '06'
        '07'
        '08'
        '09'
        '10'
        '11'
        '12'
        '13'
        '14'
        '15'
        '16'
        '17'
        '18'
        '19'
        '20'
        '21'
        '22'
        '23'
        '24')
    end
    object cmbboxmodelname: TComboBox
      Left = 72
      Top = 48
      Width = 121
      Height = 21
      ItemHeight = 13
      TabOrder = 6
      Text = 'cmbboxmodelname'
    end
    object Editrepairuser: TEdit
      Left = 656
      Top = 48
      Width = 113
      Height = 21
      TabOrder = 7
      Text = 'Editrepairuser'
    end
    object cmbboxline: TComboBox
      Left = 232
      Top = 48
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 8
      Text = 'cmbboxline'
    end
    object cmbboxprocess: TComboBox
      Left = 432
      Top = 48
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 9
      Text = 'cmbboxprocess'
    end
  end
  object StringGridrepair: TStringGrid
    Left = 7
    Top = 120
    Width = 810
    Height = 297
    ColCount = 10
    FixedCols = 0
    RowCount = 12
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowMoving, goColMoving, goRowSelect]
    TabOrder = 1
  end
  object Progressfeeder: TProgressBar
    Left = 224
    Top = 424
    Width = 217
    Height = 17
    TabOrder = 2
  end
  object Btnsave: TButton
    Left = 456
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
    Left = 8
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '*.txt'
    Filter = '*.txt|*.txt'
    Left = 48
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 96
  end
  object ClientDataSetlocation: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 144
  end
end
