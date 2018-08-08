object fMain: TfMain
  Left = 362
  Top = 272
  Width = 354
  Height = 352
  Caption = 'fMain'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 32
    Top = 16
    Width = 273
    Height = 105
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Memo2: TMemo
    Left = 32
    Top = 152
    Width = 273
    Height = 105
    Lines.Strings = (
      'Memo2')
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object VSSComm321: TVSSComm32
    CommPort = Com1
    BaudRate = __19200
    Parity = None
    DataBits = _8
    StopBits = _1
    Left = 208
    Top = 8
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 144
    Top = 16
  end
  object SaveDialog1: TSaveDialog
    Left = 97
    Top = 17
  end
end
