object Form1: TForm1
  Left = 226
  Top = 227
  Width = 979
  Height = 563
  Caption = 'Form1'
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
  object Label1: TLabel
    Left = 130
    Top = 116
    Width = 19
    Height = 13
    Caption = 'File:'
  end
  object Label2: TLabel
    Left = 202
    Top = 205
    Width = 167
    Height = 110
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -96
    Font.Name = 'Arial'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
  end
  object Edit1: TEdit
    Left = 180
    Top = 111
    Width = 314
    Height = 21
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ReadOnly = True
    TabOrder = 0
  end
  object BitBtn1: TBitBtn
    Left = 479
    Top = 224
    Width = 75
    Height = 25
    Caption = 'Insert'
    TabOrder = 1
    OnClick = BitBtn1Click
  end
  object BitBtn2: TBitBtn
    Left = 481
    Top = 279
    Width = 75
    Height = 25
    Caption = 'Update'
    TabOrder = 2
    OnClick = BitBtn2Click
  end
  object BitBtn3: TBitBtn
    Left = 511
    Top = 110
    Width = 50
    Height = 25
    Caption = 'Open'
    TabOrder = 3
    OnClick = BitBtn3Click
  end
  object Memo1: TMemo
    Left = 602
    Top = 62
    Width = 299
    Height = 421
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 4
  end
  object OpenDialog1: TOpenDialog
    Filter = '*.csv|*.csv'
    Left = 467
    Top = 58
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    RemoteServer = SocketConnection1
    Left = 352
    Top = 400
  end
  object SimpleObjectBroker1: TSimpleObjectBroker
    LoadBalanced = True
    Left = 320
    Top = 400
  end
  object SocketConnection1: TSocketConnection
    ServerGUID = '{AF550BF4-3BA4-415D-B1F3-E2F7C8ADE30C}'
    ServerName = 'SajetApserver.RMDB'
    ObjectBroker = SimpleObjectBroker1
    Left = 288
    Top = 400
  end
end
