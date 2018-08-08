object uMainForm: TuMainForm
  Left = 365
  Top = 155
  BorderStyle = bsDialog
  Caption = 'uMainForm'
  ClientHeight = 206
  ClientWidth = 402
  Color = clBtnHighlight
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 72
    Top = 64
    Width = 321
    Height = 37
    AutoSize = False
    Caption = #36554#38291#22823#30475#26495#22577#34920
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object SimpleObjectBroker1: TSimpleObjectBroker
    Left = 106
    Top = 4
  end
  object QryData: TClientDataSet
    Aggregates = <>
    FetchOnDemand = False
    Params = <>
    ProviderName = 'DspQryData'
    RemoteServer = SocketConnection1
    Left = 3
    Top = 3
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    RemoteServer = SocketConnection1
    Left = 36
    Top = 3
  end
  object SocketConnection1: TSocketConnection
    ServerGUID = '{AF550BF4-3BA4-415D-B1F3-E2F7C8ADE30C}'
    ServerName = 'SajetApserver.RMDB'
    ObjectBroker = SimpleObjectBroker1
    Left = 71
    Top = 6
  end
  object IdMessage1: TIdMessage
    AttachmentEncoding = 'MIME'
    BccList = <>
    CCList = <>
    Encoding = meMIME
    Recipients = <>
    ReplyTo = <>
    Left = 147
    Top = 12
  end
  object IdSMTP1: TIdSMTP
    MaxLineAction = maException
    ReadTimeout = 0
    Port = 25
    AuthenticationType = atNone
    Left = 180
    Top = 12
  end
end
