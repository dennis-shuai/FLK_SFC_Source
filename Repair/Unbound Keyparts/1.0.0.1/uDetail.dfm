object fDetail: TfDetail
  Left = 192
  Top = 112
  BorderStyle = bsNone
  ClientHeight = 717
  ClientWidth = 1400
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 1400
    Height = 717
    Align = alClient
    Color = clCaptionText
    TabOrder = 0
    object ImageAll: TImage
      Left = 1
      Top = 1
      Width = 1398
      Height = 715
      Align = alClient
      ParentShowHint = False
      ShowHint = False
      Transparent = True
    end
    object lblLabTitle2: TLabel
      Left = 32
      Top = 16
      Width = 144
      Height = 20
      Caption = 'Unbond Keyparts '
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
      Width = 144
      Height = 20
      Caption = 'Unbond Keyparts '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label1: TLabel
      Left = 78
      Top = 75
      Width = 108
      Height = 16
      Caption = 'Serial Number:'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = #26032#32048#26126#39636
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblMsg: TLabel
      Left = 102
      Top = 140
      Width = 619
      Height = 132
      Alignment = taCenter
      AutoSize = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -64
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object Label2: TLabel
      Left = 74
      Top = 282
      Width = 5
      Height = 22
      Font.Charset = ANSI_CHARSET
      Font.Color = clNavy
      Font.Height = -19
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object edtSN: TEdit
      Left = 227
      Top = 71
      Width = 326
      Height = 27
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = '@Microsoft YaHei'
      Font.Style = [fsBold]
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      ParentFont = False
      TabOrder = 0
      OnKeyPress = edtSNKeyPress
    end
  end
  object QryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 591
    Top = 30
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp'
    Left = 632
    Top = 26
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 690
    Top = 34
  end
end
