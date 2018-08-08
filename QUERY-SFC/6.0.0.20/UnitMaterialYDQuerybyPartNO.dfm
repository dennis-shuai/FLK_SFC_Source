object FormYDQueryBYPartNO: TFormYDQueryBYPartNO
  Left = 217
  Top = 164
  Width = 696
  Height = 480
  BorderIcons = [biSystemMenu]
  BorderWidth = 1
  Caption = 'FormYDQueryBYPartNO'
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
    Left = 232
    Top = 8
    Width = 249
    Height = 24
    Caption = #30064#21205#26597#35426' BY Part_NO        '
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
  object GroupBox1: TGroupBox
    Left = 8
    Top = 40
    Width = 673
    Height = 81
    TabOrder = 0
    object Label2: TLabel
      Left = 8
      Top = 48
      Width = 44
      Height = 13
      Caption = 'Part_NO:'
    end
    object Label5: TLabel
      Left = 8
      Top = 16
      Width = 58
      Height = 13
      Caption = 'Time   From:'
    end
    object Label6: TLabel
      Left = 312
      Top = 16
      Width = 15
      Height = 13
      Caption = 'TO'
    end
    object Label4: TLabel
      Left = 256
      Top = 48
      Width = 27
      Height = 13
      Caption = 'Type:'
    end
    object Editpartno: TEdit
      Left = 80
      Top = 48
      Width = 169
      Height = 21
      CharCase = ecUpperCase
      TabOrder = 0
      Text = 'EDITPARTNO'
      OnKeyDown = EditpartnoKeyDown
    end
    object btnclose: TButton
      Left = 504
      Top = 48
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 1
      OnClick = btncloseClick
    end
    object btnquery: TButton
      Left = 424
      Top = 48
      Width = 75
      Height = 25
      Caption = 'Query'
      TabOrder = 2
      OnClick = btnqueryClick
    end
    object DateTimePickerSTART: TDateTimePicker
      Left = 72
      Top = 16
      Width = 137
      Height = 21
      Date = 39087.486522164350000000
      Time = 39087.486522164350000000
      TabOrder = 3
    end
    object DateTimePickerEND: TDateTimePicker
      Left = 344
      Top = 16
      Width = 137
      Height = 21
      Date = 39087.486643692130000000
      Time = 39087.486643692130000000
      TabOrder = 4
    end
    object CMBBOXSSTART: TComboBox
      Left = 256
      Top = 16
      Width = 49
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 5
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
    object CMBBOXSEND: TComboBox
      Left = 528
      Top = 16
      Width = 49
      Height = 21
      ItemHeight = 13
      ItemIndex = 60
      TabOrder = 6
      Text = '60'
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
    object cmbBoxHSTART: TComboBox
      Left = 208
      Top = 16
      Width = 49
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 7
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
      Left = 480
      Top = 16
      Width = 49
      Height = 21
      ItemHeight = 13
      ItemIndex = 23
      TabOrder = 8
      Text = '23'
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
    object cmbtype: TComboBox
      Left = 288
      Top = 48
      Width = 89
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 9
      Text = 'ALL'
      Items.Strings = (
        'ALL'
        'INPUT'
        'OUTPUT'
        'INPUT/OUTPUT'
        'MERGE'
        'SPLIT')
    end
  end
  object StringGridPARTNO: TStringGrid
    Left = 8
    Top = 120
    Width = 673
    Height = 297
    ColCount = 9
    FixedCols = 0
    RowCount = 12
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowMoving, goColMoving, goRowSelect]
    TabOrder = 1
  end
  object ClientDataSetmaterialydbypartno: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 8
  end
end
