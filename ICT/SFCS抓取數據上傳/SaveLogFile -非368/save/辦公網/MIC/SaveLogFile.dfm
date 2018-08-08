object Form1: TForm1
  Left = 200
  Top = 130
  Width = 308
  Height = 234
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 19
    Top = 75
    Width = 75
    Height = 25
    Caption = 'GetDeviceID'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 17
    Top = 103
    Width = 121
    Height = 21
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#20116'??'#20837#27861
    TabOrder = 3
    Text = 'Edit1'
  end
  object Edit2: TEdit
    Left = 143
    Top = 101
    Width = 121
    Height = 21
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#20116'??'#20837#27861
    TabOrder = 4
    Text = 'Edit2'
  end
  object Button2: TButton
    Left = 16
    Top = 129
    Width = 75
    Height = 25
    Caption = 'GetIP'
    TabOrder = 5
    OnClick = Button2Click
  end
  object Edit3: TEdit
    Left = 100
    Top = 133
    Width = 121
    Height = 21
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#20116'??'#20837#27861
    TabOrder = 6
    Text = 'Edit3'
  end
  object Panel1: TPanel
    Left = 10
    Top = 52
    Width = 280
    Height = 114
    BevelOuter = bvLowered
    TabOrder = 7
  end
  object Cmd_Start: TButton
    Left = 56
    Top = 93
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = Cmd_StartClick
  end
  object Cmd_Exit: TButton
    Left = 166
    Top = 92
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 1
    OnClick = Cmd_ExitClick
  end
  object SocketConnection1: TSocketConnection
    ServerName = 'SajetApserver.RMDB'
    ObjectBroker = SimpleObjectBroker1
    Left = 4
    Top = 3
  end
  object SimpleObjectBroker1: TSimpleObjectBroker
    Left = 34
    Top = 4
  end
  object QryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    RemoteServer = SocketConnection1
    Left = 63
    Top = 5
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    RemoteServer = SocketConnection1
    Left = 95
    Top = 6
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    RemoteServer = SocketConnection1
    Left = 125
    Top = 7
  end
  object IdIPWatch1: TIdIPWatch
    Active = False
    HistoryFilename = 'iphist.dat'
    Left = 168
    Top = 5
  end
end
