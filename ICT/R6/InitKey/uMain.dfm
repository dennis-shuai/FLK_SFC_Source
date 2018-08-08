object fMain: TfMain
  Left = 1146
  Top = 635
  Width = 409
  Height = 218
  Caption = 'InitKey_SFCS'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object PLSN1: TPanel
    Left = 120
    Top = 32
    Width = 193
    Height = 57
    TabOrder = 0
  end
  object PLRT1: TPanel
    Left = 56
    Top = 88
    Width = 313
    Height = 57
    TabOrder = 1
  end
  object stat1: TStatusBar
    Left = 0
    Top = 160
    Width = 401
    Height = 24
    Color = clSkyBlue
    Panels = <>
  end
  object Timer1: TTimer
    Interval = 5000
    OnTimer = Timer1Timer
  end
end
