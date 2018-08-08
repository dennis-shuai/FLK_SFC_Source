object fMessage: TfMessage
  Left = 388
  Top = 351
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Message'
  ClientHeight = 81
  ClientWidth = 223
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 8
    Width = 223
    Height = 41
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object BnOK: TButton
    Left = 64
    Top = 48
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = BnOKClick
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 192
    Top = 56
  end
end
