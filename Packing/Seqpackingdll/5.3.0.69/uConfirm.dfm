object fConfirm: TfConfirm
  Left = 240
  Top = 214
  Width = 531
  Height = 272
  BorderIcons = [biMinimize, biMaximize]
  Caption = 'Confirm'
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
  object Button1: TButton
    Left = 216
    Top = 192
    Width = 97
    Height = 33
    Caption = 'OK'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ModalResult = 1
    ParentFont = False
    TabOrder = 0
    TabStop = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 523
    Height = 185
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 1
    object LabMsg: TLabel
      Left = 1
      Top = 1
      Width = 521
      Height = 183
      Align = alClient
      Alignment = taCenter
      BiDiMode = bdLeftToRight
      Caption = 'LabMsg'
      Color = 9830399
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -32
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentColor = False
      ParentFont = False
      Layout = tlCenter
    end
  end
end
