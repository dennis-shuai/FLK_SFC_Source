object fRetry: TfRetry
  Left = 328
  Top = 228
  BorderStyle = bsNone
  Caption = 'Retry'
  ClientHeight = 108
  ClientWidth = 301
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
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 301
    Height = 108
    Align = alClient
  end
  object labSN: TLabel
    Left = 8
    Top = 32
    Width = 30
    Height = 20
    Caption = 'S/N'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object lablMsg: TLabel
    Left = 7
    Top = 72
    Width = 289
    Height = 25
    AutoSize = False
    Caption = 'Result:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object SpeedButton1: TSpeedButton
    Left = 280
    Top = 88
    Width = 23
    Height = 22
    Flat = True
    OnClick = SpeedButton1Click
  end
  object edtSN: TEdit
    Left = 56
    Top = 29
    Width = 241
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnKeyPress = edtSNKeyPress
  end
end
