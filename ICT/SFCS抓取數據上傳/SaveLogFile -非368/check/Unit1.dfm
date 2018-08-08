object Form1: TForm1
  Left = 211
  Top = 127
  Width = 333
  Height = 236
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
  object Cmd_Start: TButton
    Left = 57
    Top = 91
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = Cmd_StartClick
  end
  object Cmd_Exit: TButton
    Left = 179
    Top = 90
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
end
