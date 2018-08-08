object FormPrinterSelect: TFormPrinterSelect
  Left = 230
  Top = 192
  BorderStyle = bsDialog
  Caption = 'PrinterSelect'
  ClientHeight = 379
  ClientWidth = 514
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object rg1: TRadioGroup
    Left = 72
    Top = 16
    Width = 369
    Height = 297
    Align = alCustom
    Font.Charset = ANSI_CHARSET
    Font.Color = clHighlight
    Font.Height = -48
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Items.Strings = (
      'Label View'
      'Code Soft')
    ParentFont = False
    TabOrder = 0
    OnClick = rg1Click
  end
end
