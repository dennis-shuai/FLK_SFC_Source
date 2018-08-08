object uMainForm: TuMainForm
  Left = 192
  Top = 114
  Width = 332
  Height = 250
  Caption = 'uMainForm'
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
  object SocketConnection1: TSocketConnection
    ServerName = 'SajetApserver.RMDB'
    ObjectBroker = SimpleObjectBroker1
    Left = 10
    Top = 5
  end
  object SimpleObjectBroker1: TSimpleObjectBroker
    Left = 43
    Top = 7
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    RemoteServer = SocketConnection1
    Left = 74
    Top = 9
  end
end
