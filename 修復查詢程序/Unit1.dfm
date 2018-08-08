object MainForm: TMainForm
  Left = 453
  Top = 338
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'RepairQuery'
  ClientHeight = 142
  ClientWidth = 395
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 65
    Height = 13
    AutoSize = False
    Caption = #29305#21029#35498#26126':'
    Font.Charset = ANSI_CHARSET
    Font.Color = clTeal
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label2: TLabel
    Left = 8
    Top = 40
    Width = 273
    Height = 97
    AutoSize = False
    Caption = 
      '1.'#26412#31243#24207#20677#33021#20462#24489#26597#35426#31243#24207#19981#33021#20570#20854#20182#20351#29992#13#10'2.'#31243#24207#28858#19968#37749#20462#24489','#23560#28858#26597#35426#31243#24207#24674#24489#32780#23450#21046#13#10#13#10'  '#22914#26377#21839#38988#35531#32879#32363#20316#32773#13#10'   M' +
      'ail:Xiaobo_Yuan@Foxlink.com.tw'#13#10'   Ext:36212'
    Font.Charset = ANSI_CHARSET
    Font.Color = clTeal
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object MSG: TLabel
    Left = 280
    Top = 48
    Width = 105
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = 'Welcome'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Button1: TButton
    Left = 296
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Repair'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = Button1Click
  end
  object SimpleObjectBroker1: TSimpleObjectBroker
    Left = 16
    Top = 8
  end
  object SocketConnection1: TSocketConnection
    ServerGUID = '{AF550BF4-3BA4-415D-B1F3-E2F7C8ADE30C}'
    ServerName = 'SajetApserver.RMDB'
    ObjectBroker = SimpleObjectBroker1
    Left = 72
    Top = 8
  end
  object dsQuery: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    RemoteServer = SocketConnection1
    Left = 104
    Top = 8
  end
end
