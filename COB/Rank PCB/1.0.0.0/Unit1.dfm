object Form1: TForm1
  Left = 602
  Top = 247
  Width = 849
  Height = 635
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 841
    Height = 601
    Align = alClient
    Color = clCaptionText
    TabOrder = 0
    object ImageAll: TImage
      Left = 1
      Top = 1
      Width = 839
      Height = 599
      Align = alClient
      ParentShowHint = False
      ShowHint = False
      Transparent = True
    end
    object lblLabTitle2: TLabel
      Left = 32
      Top = 16
      Width = 350
      Height = 20
      AutoSize = False
      Caption = 'COB Rank PCB By WO(COB '#25353#24037#21934#25490#29255') '
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
      Width = 350
      Height = 20
      AutoSize = False
      Caption = 'COB Rank PCB By WO(COB '#25353#24037#21934#25490#29255') '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label1: TLabel
      Left = 34
      Top = 80
      Width = 58
      Height = 13
      Caption = 'Work Order:'
      Transparent = True
    end
    object Label2: TLabel
      Left = 40
      Top = 128
      Width = 33
      Height = 13
      Caption = 'Carrier:'
      Transparent = True
    end
    object lblMsg: TLabel
      Left = 24
      Top = 472
      Width = 609
      Height = 113
      Alignment = taCenter
      AutoSize = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
    end
    object lblTerminal: TLabel
      Left = 32
      Top = 48
      Width = 85
      Height = 18
      Caption = 'lblTerminal'
      Font.Charset = ANSI_CHARSET
      Font.Color = clYellow
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label3: TLabel
      Left = 304
      Top = 80
      Width = 27
      Height = 13
      Caption = #32317#25976':'
      Transparent = True
    end
    object lblRest: TLabel
      Left = 304
      Top = 120
      Width = 27
      Height = 13
      Caption = #36996#21097':'
      Transparent = True
    end
    object DBGrid1: TDBGrid
      Left = 27
      Top = 160
      Width = 606
      Height = 302
      DataSource = DataSource1
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
    end
    object edtWO: TEdit
      Left = 104
      Top = 80
      Width = 153
      Height = 21
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      TabOrder = 1
      OnKeyPress = edtWOKeyPress
    end
    object edtCarrier: TEdit
      Left = 104
      Top = 120
      Width = 153
      Height = 21
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      TabOrder = 2
      OnKeyPress = edtCarrierKeyPress
    end
  end
  object QryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 632
    Top = 16
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp'
    Left = 664
    Top = 16
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 704
    Top = 16
  end
  object DataSource1: TDataSource
    DataSet = QryData
    Left = 591
    Top = 14
  end
end
