object Form1: TForm1
  Left = 196
  Top = 119
  Width = 1007
  Height = 724
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
    Width = 999
    Height = 690
    Align = alClient
    Color = clCaptionText
    TabOrder = 0
    object ImageAll: TImage
      Left = 1
      Top = 1
      Width = 997
      Height = 688
      Align = alClient
      ParentShowHint = False
      ShowHint = False
      Transparent = True
    end
    object lblLabTitle2: TLabel
      Left = 32
      Top = 16
      Width = 288
      Height = 20
      Caption = 'COB Replace Carrier(COB '#25563#36617#20855') : '
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
      Width = 288
      Height = 20
      Caption = 'COB Replace Carrier(COB '#25563#36617#20855') : '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label1: TLabel
      Left = 64
      Top = 88
      Width = 193
      Height = 20
      AutoSize = False
      Caption = 'Old Carrier('#33290#36617#20855'):'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 64
      Top = 152
      Width = 193
      Height = 20
      AutoSize = False
      Caption = 'New Carrier('#26032#36617#20855'):'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblMsg: TLabel
      Left = 64
      Top = 504
      Width = 617
      Height = 145
      Alignment = taCenter
      AutoSize = False
      Color = clGreen
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Layout = tlCenter
    end
    object lblTerminal: TLabel
      Left = 56
      Top = 48
      Width = 5
      Height = 16
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object edtNewCar: TEdit
      Left = 272
      Top = 152
      Width = 225
      Height = 21
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      ReadOnly = True
      TabOrder = 0
      OnKeyPress = edtNewCarKeyPress
    end
    object DBGrid1: TDBGrid
      Left = 62
      Top = 186
      Width = 638
      Height = 299
      DataSource = DataSource1
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
    end
    object edtOldCar: TEdit
      Left = 272
      Top = 88
      Width = 225
      Height = 21
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      TabOrder = 2
      OnKeyPress = edtOldCarKeyPress
    end
  end
  object QryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 832
    Top = 280
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp'
    Left = 712
    Top = 288
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 760
    Top = 280
  end
  object DataSource1: TDataSource
    DataSet = QryData
    Left = 487
    Top = 22
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Excel Document|*.xls'
    Left = 856
    Top = 24
  end
end
