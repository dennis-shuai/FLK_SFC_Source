object fDetail: TfDetail
  Left = 202
  Top = 113
  BorderStyle = bsNone
  ClientHeight = 718
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
    Height = 718
    Align = alClient
    Color = clCaptionText
    TabOrder = 0
    object ImageAll: TImage
      Left = 1
      Top = 1
      Width = 1401
      Height = 716
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
      Caption = #29986#21697#25163#21205#25171#19981#33391' '
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
      Caption = #29986#21697#25163#21205#25171#19981#33391' '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label1: TLabel
      Left = 61
      Top = 127
      Width = 74
      Height = 13
      AutoSize = False
      Caption = #19981#33391#20195#30908':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblMsg: TLabel
      Left = 53
      Top = 225
      Width = 492
      Height = 146
      Alignment = taCenter
      AutoSize = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -29
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object Label3: TLabel
      Left = 63
      Top = 180
      Width = 74
      Height = 13
      Caption = #29986#21697#26781#30908':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 63
      Top = 67
      Width = 74
      Height = 13
      AutoSize = False
      Caption = #32218#21029':'
      Color = clYellow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Transparent = True
    end
    object Label4: TLabel
      Left = 289
      Top = 64
      Width = 74
      Height = 13
      AutoSize = False
      Caption = #31449#21029':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lbl1: TLabel
      Left = 184
      Top = 152
      Width = 481
      Height = 13
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object edtSN: TEdit
      Left = 185
      Top = 176
      Width = 228
      Height = 21
      Color = clYellow
      Enabled = False
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
    object cmbPdline: TComboBox
      Left = 116
      Top = 59
      Width = 145
      Height = 21
      Style = csDropDownList
      Color = clYellow
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      ItemHeight = 13
      TabOrder = 1
      OnSelect = cmbPdlineSelect
    end
    object cmbTerminal: TComboBox
      Left = 350
      Top = 62
      Width = 145
      Height = 21
      Style = csDropDownList
      Color = clYellow
      Enabled = False
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      ItemHeight = 13
      TabOrder = 2
      OnSelect = cmbTerminalSelect
    end
    object cmbDefect: TComboBox
      Left = 184
      Top = 120
      Width = 233
      Height = 22
      Style = csSimple
      Color = clYellow
      Enabled = False
      ItemHeight = 13
      TabOrder = 3
      OnKeyPress = cmbDefectKeyPress
      OnSelect = cmbDefectSelect
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
