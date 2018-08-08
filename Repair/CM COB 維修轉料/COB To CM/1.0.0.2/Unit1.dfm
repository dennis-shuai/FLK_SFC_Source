object Form1: TForm1
  Left = 215
  Top = 109
  Width = 1065
  Height = 747
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ImageAll: TImage
    Left = 0
    Top = 0
    Width = 1057
    Height = 720
    Align = alClient
  end
  object Label1: TLabel
    Left = 56
    Top = 160
    Width = 26
    Height = 16
    Caption = 'SN:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label7: TLabel
    Left = 689
    Top = 185
    Width = 85
    Height = 16
    AutoSize = False
    Caption = #19981#33391#29694#35937
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    Visible = False
  end
  object Label3: TLabel
    Left = 40
    Top = 24
    Width = 280
    Height = 24
    AutoSize = False
    Caption = 'COB TO CM Transfer'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label2: TLabel
    Left = 42
    Top = 24
    Width = 280
    Height = 24
    AutoSize = False
    Caption = 'COB TO CM Transfer'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblMsg: TLabel
    Left = 53
    Top = 227
    Width = 404
    Height = 149
    Alignment = taCenter
    AutoSize = False
    Color = clMedGray
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -24
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Transparent = False
    Layout = tlCenter
  end
  object Label8: TLabel
    Left = 55
    Top = 205
    Width = 48
    Height = 16
    Caption = 'Status:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label9: TLabel
    Left = 385
    Top = 117
    Width = 113
    Height = 16
    AutoSize = False
    Caption = #25475#25551#25976#37327':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lblCount: TLabel
    Left = 379
    Top = 144
    Width = 129
    Height = 46
    Alignment = taCenter
    AutoSize = False
    Caption = '0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    Layout = tlCenter
  end
  object lblTerminal: TLabel
    Left = 56
    Top = 63
    Width = 369
    Height = 13
    AutoSize = False
    Color = clActiveBorder
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Transparent = True
  end
  object lblWO: TLabel
    Left = 53
    Top = 122
    Width = 30
    Height = 16
    Caption = 'WO:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object edtSN: TEdit
    Left = 135
    Top = 156
    Width = 233
    Height = 21
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 0
    OnKeyPress = edtSNKeyPress
  end
  object edtWO: TEdit
    Left = 134
    Top = 118
    Width = 233
    Height = 21
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 1
    OnKeyPress = edtWOKeyPress
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 16
  end
  object Sproc: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 48
  end
end
