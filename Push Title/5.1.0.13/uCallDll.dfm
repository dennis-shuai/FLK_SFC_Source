object CallDll: TCallDll
  Left = 185
  Top = 108
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 590
  ClientWidth = 818
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PanelParent: TPanel
    Left = 0
    Top = 0
    Width = 818
    Height = 590
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
  end
  object SimpleObjectBroker1: TSimpleObjectBroker
    LoadBalanced = True
    Left = 376
    Top = 80
  end
  object SocketConnection1: TSocketConnection
    ServerGUID = '{AF550BF4-3BA4-415D-B1F3-E2F7C8ADE30C}'
    ServerName = 'SajetApserver.RMDB'
    ObjectBroker = SimpleObjectBroker1
    Left = 440
    Top = 80
  end
end
