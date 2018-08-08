object uMainForm: TuMainForm
  Left = 212
  Top = 130
  Width = 804
  Height = 270
  Caption = 'CCM MES Mail Alarm'
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
  object mmo1: TMemo
    Left = 8
    Top = 40
    Width = 777
    Height = 177
    TabOrder = 0
  end
  object SimpleObjectBroker1: TSimpleObjectBroker
    Left = 44
    Top = 11
  end
  object SocketConnection1: TSocketConnection
    ServerName = 'SajetApserver.RMDB'
    ObjectBroker = SimpleObjectBroker1
    Left = 14
    Top = 10
  end
  object Qrytemp: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 79
    Top = 11
  end
  object IdMessage1: TIdMessage
    AttachmentEncoding = 'MIME'
    BccList = <>
    CCList = <>
    Encoding = meMIME
    Recipients = <>
    ReplyTo = <>
    Left = 115
    Top = 12
  end
  object IdSMTP1: TIdSMTP
    MaxLineAction = maException
    ReadTimeout = 0
    Port = 25
    AuthenticationType = atNone
    Left = 148
    Top = 12
  end
  object SaveDialog1: TSaveDialog
    Left = 217
    Top = 12
  end
  object QryFail: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 77
    Top = 51
  end
  object QryWarning: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 28
    Top = 51
  end
  object QryDate: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 181
    Top = 11
  end
end
