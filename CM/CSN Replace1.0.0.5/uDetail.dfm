object fDetail: TfDetail
  Left = 789
  Top = 132
  BorderStyle = bsNone
  ClientHeight = 717
  ClientWidth = 1403
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
    Width = 1403
    Height = 717
    Align = alClient
    Color = clCaptionText
    TabOrder = 0
    object ImageAll: TImage
      Left = 1
      Top = 1
      Width = 1401
      Height = 715
      Align = alClient
      ParentShowHint = False
      ShowHint = False
      Transparent = True
    end
    object lblLabTitle2: TLabel
      Left = 32
      Top = 16
      Width = 180
      Height = 20
      AutoSize = False
      Caption = #23458#25142#26781#30908#35299#32129' '
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
      Width = 180
      Height = 20
      AutoSize = False
      Caption = #23458#25142#26781#30908#35299#32129
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label1: TLabel
      Left = 30
      Top = 154
      Width = 118
      Height = 13
      Caption = #33290#20027#26495#26781#30908'(Old SN):'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblMsg: TLabel
      Left = 33
      Top = 247
      Width = 440
      Height = 154
      Alignment = taCenter
      AutoSize = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -35
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object Label2: TLabel
      Left = 30
      Top = 82
      Width = 155
      Height = 13
      Caption = #23458#25142#26781#30908'(CUSTOMER SN):'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object edtSN: TEdit
      Left = 204
      Top = 151
      Width = 228
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      ParentFont = False
      TabOrder = 0
      OnKeyPress = edtSNKeyPress
    end
    object EditCSN: TEdit
      Left = 204
      Top = 79
      Width = 228
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      ParentFont = False
      TabOrder = 1
      OnKeyPress = EditCSNKeyPress
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
