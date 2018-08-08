object Login: TLogin
  Left = 377
  Top = 157
  Width = 544
  Height = 310
  Caption = 'Login'
  Color = clBtnHighlight
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 119
    Top = 83
    Width = 69
    Height = 16
    AutoSize = False
    Caption = #29992#25142#21517':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 119
    Top = 139
    Width = 61
    Height = 16
    AutoSize = False
    Caption = #23494#30908':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Edit1: TEdit
    Left = 206
    Top = 75
    Width = 212
    Height = 32
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentFont = False
    TabOrder = 0
    OnKeyPress = Edit1KeyPress
  end
  object Edit2: TEdit
    Left = 206
    Top = 128
    Width = 216
    Height = 32
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 1
    OnKeyPress = Edit2KeyPress
  end
  object QryData: TClientDataSet
    Aggregates = <>
    AutoCalcFields = False
    FetchOnDemand = False
    Params = <>
    ProviderName = 'DspQryData'
    RemoteServer = SocketConnection1
    Left = 12
    Top = 6
  end
  object SocketConnection1: TSocketConnection
    ServerGUID = '{AF550BF4-3BA4-415D-B1F3-E2F7C8ADE30C}'
    ServerName = 'SajetApserver.RMDB'
    ObjectBroker = SimpleObjectBroker1
    Left = 45
    Top = 8
  end
  object SimpleObjectBroker1: TSimpleObjectBroker
    Left = 76
    Top = 8
  end
  object Sproc: TClientDataSet
    Aggregates = <>
    FetchOnDemand = False
    Params = <>
    ProviderName = 'DspStoreproc'
    RemoteServer = SocketConnection1
    Left = 107
    Top = 8
  end
end
