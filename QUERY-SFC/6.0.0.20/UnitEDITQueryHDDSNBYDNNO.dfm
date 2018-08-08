object FormEdiqueryhddsnbyDNNO: TFormEdiqueryhddsnbyDNNO
  Left = 330
  Top = 117
  Width = 460
  Height = 540
  BorderIcons = [biSystemMenu]
  Caption = 'FormEdiqueryhddsnbyDNNO'
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
  object Label2: TLabel
    Left = 104
    Top = 8
    Width = 250
    Height = 24
    Caption = 'Query HDD SN BY DN_NO'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 8
    Top = 480
    Width = 71
    Height = 13
    Caption = 'Record_count:'
  end
  object lblrecordcount: TLabel
    Left = 88
    Top = 480
    Width = 67
    Height = 13
    Caption = 'lblrecordcount'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 32
    Width = 433
    Height = 49
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 16
      Width = 38
      Height = 13
      Caption = 'DN_NO'
    end
    object btnCLOSE: TButton
      Left = 344
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 0
      OnClick = btnCLOSEClick
    end
    object Editdnno: TEdit
      Left = 64
      Top = 16
      Width = 169
      Height = 21
      CharCase = ecUpperCase
      TabOrder = 1
      Text = 'EDITDNNO'
    end
    object BtnQuery: TButton
      Left = 256
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Query'
      TabOrder = 2
      OnClick = BtnQueryClick
    end
  end
  object StringGridedi: TStringGrid
    Left = 9
    Top = 80
    Width = 432
    Height = 393
    ColCount = 3
    FixedCols = 0
    RowCount = 12
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowMoving, goColMoving, goRowSelect]
    TabOrder = 1
  end
  object Progressfeeder: TProgressBar
    Left = 163
    Top = 480
    Width = 198
    Height = 17
    TabOrder = 2
  end
  object Btnsave: TButton
    Left = 363
    Top = 480
    Width = 78
    Height = 17
    Caption = 'Save to *.txt'
    TabOrder = 3
    OnClick = BtnsaveClick
  end
  object ClientDataSetOUT856: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 8
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '*.txt'
    Filter = '*.txt|*.txt'
    Left = 56
  end
end
