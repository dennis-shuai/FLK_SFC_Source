object Form1: TForm1
  Left = 1120
  Top = 139
  Width = 307
  Height = 213
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
    Left = 18
    Top = 80
    Width = 75
    Height = 25
    Caption = 'GetDeviceID'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 17
    Top = 104
    Width = 121
    Height = 21
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#20116'??'#20837#27861
    TabOrder = 3
    Text = 'Edit1'
  end
  object Edit2: TEdit
    Left = 139
    Top = 103
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
    Left = 11
    Top = 43
    Width = 264
    Height = 115
    BevelInner = bvLowered
    TabOrder = 7
  end
  object Cmd_Exit: TButton
    Left = 157
    Top = 87
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 1
    OnClick = Cmd_ExitClick
  end
  object Cmd_Start: TButton
    Left = 52
    Top = 87
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = Cmd_StartClick
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
