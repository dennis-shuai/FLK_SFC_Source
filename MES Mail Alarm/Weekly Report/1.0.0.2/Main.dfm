object uMainForm: TuMainForm
  Left = 261
  Top = 115
  Width = 445
  Height = 387
  Caption = 'CCM MES Mail Alarm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 30
    Top = 161
    Width = 93
    Height = 153
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 0
  end
  object Memo2: TMemo
    Left = 146
    Top = 164
    Width = 98
    Height = 152
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 1
  end
  object Memo3: TMemo
    Left = 265
    Top = 165
    Width = 103
    Height = 152
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 2
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
    Left = 291
    Top = 75
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
  object QryTemp4: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 73
    Top = 106
  end
end
