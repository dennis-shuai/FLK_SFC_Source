object FormWIPQCDIRquery: TFormWIPQCDIRquery
  Left = 92
  Top = 127
  Width = 806
  Height = 524
  BorderIcons = [biSystemMenu]
  Caption = 'FormWIPQCDIRquery'
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
    Left = 304
    Top = 8
    Width = 205
    Height = 20
    Caption = ' QC'#27298#39511#26085#22577#34920'(DIR)         '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 64
    Top = 456
    Width = 71
    Height = 13
    Caption = 'Record_count:'
  end
  object lblrecordcount: TLabel
    Left = 144
    Top = 456
    Width = 67
    Height = 13
    Caption = 'lblrecordcount'
  end
  object GroupBox1: TGroupBox
    Left = 7
    Top = 40
    Width = 762
    Height = 113
    TabOrder = 0
    object Label5: TLabel
      Left = 8
      Top = 16
      Width = 58
      Height = 13
      Caption = 'Time   From:'
    end
    object Label6: TLabel
      Left = 320
      Top = 16
      Width = 15
      Height = 13
      Caption = 'TO'
    end
    object btnclose: TButton
      Left = 664
      Top = 48
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 0
      OnClick = btncloseClick
    end
    object btnquery: TButton
      Left = 664
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
      Left = 344
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
      Left = 488
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
    object Memomodel: TMemo
      Left = 72
      Top = 40
      Width = 577
      Height = 25
      Lines.Strings = (
        'Memomodel')
      TabOrder = 6
    end
    object Memoline: TMemo
      Left = 72
      Top = 72
      Width = 577
      Height = 25
      Lines.Strings = (
        'Memoline')
      TabOrder = 7
    end
    object btnmodel: TBitBtn
      Left = 8
      Top = 40
      Width = 57
      Height = 25
      Caption = 'Model'
      TabOrder = 8
      OnClick = btnmodelClick
    end
    object btnline: TBitBtn
      Left = 8
      Top = 72
      Width = 57
      Height = 25
      Caption = 'line'
      TabOrder = 9
      OnClick = btnlineClick
    end
    object Cmbboxmstart: TComboBox
      Left = 264
      Top = 16
      Width = 49
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 10
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
        '23'
        '24'
        '25'
        '26'
        '27'
        '28'
        '29'
        '30'
        '31'
        '32'
        '33'
        '34'
        '35'
        '36'
        '37'
        '38'
        '39'
        '40'
        '41'
        '42'
        '43'
        '44'
        '45'
        '46'
        '47'
        '48'
        '49'
        '50'
        '51'
        '52'
        '53'
        '54'
        '55'
        '56'
        '57'
        '58'
        '59'
        '60')
    end
    object cmbboxmend: TComboBox
      Left = 544
      Top = 16
      Width = 49
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 11
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
        '23'
        '24'
        '25'
        '26'
        '27'
        '28'
        '29'
        '30'
        '31'
        '32'
        '33'
        '34'
        '35'
        '36'
        '37'
        '38'
        '39'
        '40'
        '41'
        '42'
        '43'
        '44'
        '45'
        '46'
        '47'
        '48'
        '49'
        '50'
        '51'
        '52'
        '53'
        '54'
        '55'
        '56'
        '57'
        '58'
        '59'
        '60')
    end
  end
  object StringGridQC: TStringGrid
    Left = 6
    Top = 152
    Width = 763
    Height = 297
    ColCount = 9
    FixedCols = 0
    RowCount = 12
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowMoving, goColMoving, goRowSelect]
    TabOrder = 1
  end
  object Progressfeeder: TProgressBar
    Left = 272
    Top = 456
    Width = 217
    Height = 17
    TabOrder = 2
  end
  object Btnsave: TButton
    Left = 504
    Top = 456
    Width = 89
    Height = 17
    Caption = 'Save to *.txt'
    TabOrder = 3
    OnClick = BtnsaveClick
  end
  object GroupBoxmodel: TGroupBox
    Left = 80
    Top = 80
    Width = 353
    Height = 265
    TabOrder = 4
    object ListBoxmodelleft: TListBox
      Left = 8
      Top = 8
      Width = 145
      Height = 225
      ItemHeight = 13
      Sorted = True
      TabOrder = 0
    end
    object ListBoxmodelright: TListBox
      Left = 192
      Top = 8
      Width = 145
      Height = 225
      ItemHeight = 13
      Sorted = True
      TabOrder = 1
    end
    object btnmodeltoright: TBitBtn
      Left = 160
      Top = 32
      Width = 25
      Height = 25
      Caption = '>'
      TabOrder = 2
      OnClick = btnmodeltorightClick
    end
    object btnmodeltorightall: TBitBtn
      Left = 160
      Top = 72
      Width = 25
      Height = 25
      Caption = '>>'
      TabOrder = 3
      OnClick = btnmodeltorightallClick
    end
    object btnmodeltoleft: TBitBtn
      Left = 160
      Top = 112
      Width = 25
      Height = 25
      Caption = '<'
      TabOrder = 4
      OnClick = btnmodeltoleftClick
    end
    object btnmodeltoleftall: TBitBtn
      Left = 160
      Top = 152
      Width = 25
      Height = 25
      Caption = '<<'
      TabOrder = 5
      OnClick = btnmodeltoleftallClick
    end
    object btnmodelok: TButton
      Left = 96
      Top = 240
      Width = 75
      Height = 17
      Caption = 'OK'
      TabOrder = 6
      OnClick = btnmodelokClick
    end
    object btnmodelcancel: TButton
      Left = 192
      Top = 240
      Width = 75
      Height = 17
      Caption = 'Cancel'
      TabOrder = 7
      OnClick = btnmodelcancelClick
    end
  end
  object GroupBoxline: TGroupBox
    Left = 80
    Top = 112
    Width = 353
    Height = 265
    TabOrder = 5
    object ListBoxlineleft: TListBox
      Left = 8
      Top = 8
      Width = 145
      Height = 225
      ItemHeight = 13
      Sorted = True
      TabOrder = 0
    end
    object ListBoxlineright: TListBox
      Left = 192
      Top = 8
      Width = 145
      Height = 225
      ItemHeight = 13
      Sorted = True
      TabOrder = 1
    end
    object btnlinetoright: TBitBtn
      Left = 160
      Top = 32
      Width = 25
      Height = 25
      Caption = '>'
      TabOrder = 2
      OnClick = btnlinetorightClick
    end
    object btnlinetorightall: TBitBtn
      Left = 160
      Top = 72
      Width = 25
      Height = 25
      Caption = '>>'
      TabOrder = 3
      OnClick = btnlinetorightallClick
    end
    object btnlinetoleft: TBitBtn
      Left = 160
      Top = 112
      Width = 25
      Height = 25
      Caption = '<'
      TabOrder = 4
      OnClick = btnlinetoleftClick
    end
    object btnlinetoleftall: TBitBtn
      Left = 160
      Top = 152
      Width = 25
      Height = 25
      Caption = '<<'
      TabOrder = 5
      OnClick = btnlinetoleftallClick
    end
    object btnlineok: TButton
      Left = 96
      Top = 240
      Width = 75
      Height = 17
      Caption = 'OK'
      TabOrder = 6
      OnClick = btnlineokClick
    end
    object btnlinecancel: TButton
      Left = 192
      Top = 240
      Width = 75
      Height = 17
      Caption = 'Cancel'
      TabOrder = 7
      OnClick = btnlinecancelClick
    end
  end
  object ClientDatasetqc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 136
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '*.txt'
    Filter = '*.txt|*.txt'
    Left = 176
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 224
  end
end
