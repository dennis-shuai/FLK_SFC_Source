object fMailRepairReport: TfMailRepairReport
  Left = 770
  Top = 144
  Width = 278
  Height = 169
  Caption = 'Mail and SMS Testing'
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
  object btnSendMail: TButton
    Left = 17
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Send Mail'
    TabOrder = 0
  end
  object Button1: TButton
    Left = 136
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 1
    OnClick = Button1Click
  end
  object SMTP1: TIdSMTP
    MaxLineAction = maException
    ReadTimeout = 0
    Port = 25
    AuthenticationType = atNone
    Left = 376
    Top = 8
  end
  object DBConn: TADOConnection
    ConnectionString = 
      'Provider=MSDASQL.1;Password=jasson@db;Persist Security Info=True' +
      ';User ID=mas;Extended Properties="DSN=MSDASQL;SERVER=192.168.78.' +
      '162;UID=mas;PWD={jasson@db};DATABASE=dbadapter;PORT=21306";Initi' +
      'al Catalog=dbadapter'
    LoginPrompt = False
    Provider = 'MSDASQL.1'
    Left = 414
    Top = 9
  end
  object dbCommand: TADOCommand
    Connection = DBConn
    Parameters = <>
    Left = 509
    Top = 13
  end
  object SocketConnection1: TSocketConnection
    ServerName = 'SajetApserver.RMDB'
    ObjectBroker = SimpleObjectBroker1
    Left = 1
  end
  object SimpleObjectBroker1: TSimpleObjectBroker
    Left = 30
  end
  object Qrytemp: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 86
    Top = 65533
  end
  object QryDate: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 34
    Top = 96
  end
  object QryTemp2: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 144
    Top = 97
  end
  object QryDefect: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 171
    Top = 96
  end
  object QryTemp4: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 85
    Top = 97
  end
  object QryData1: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 114
    Top = 98
  end
  object QryModel: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 4
    Top = 96
  end
  object QryTemp3: TClientDataSet
    Aggregates = <>
    Params = <>
    RemoteServer = SocketConnection1
    Left = 61
    Top = 98
  end
  object QryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    RemoteServer = SocketConnection1
    Left = 60
  end
  object IdSMTP1: TIdSMTP
    MaxLineAction = maException
    ReadTimeout = 0
    Port = 25
    AuthenticationType = atNone
    Left = 131
    Top = 1
  end
  object IdMessage1: TIdMessage
    AttachmentEncoding = 'MIME'
    BccList = <>
    CCList = <>
    Encoding = meMIME
    Recipients = <>
    ReplyTo = <>
    Left = 161
    Top = 2
  end
end
