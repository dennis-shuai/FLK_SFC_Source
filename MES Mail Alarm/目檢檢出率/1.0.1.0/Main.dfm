object uMainForm: TuMainForm
  Left = 852
  Top = 171
  Width = 333
  Height = 263
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
  object Timer1: TTimer
    Left = 181
    Top = 12
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
  object QryDate: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 13
    Top = 51
  end
  object QryDefect: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 77
    Top = 51
  end
  object QryTemp2: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 44
    Top = 51
  end
  object QryTemp3: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 123
    Top = 54
  end
  object QryData1: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 180
    Top = 54
  end
  object QryModel: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 234
    Top = 58
  end
end
