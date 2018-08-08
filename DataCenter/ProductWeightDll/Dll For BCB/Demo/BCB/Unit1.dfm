object Form1: TForm1
  Left = 395
  Top = 246
  Width = 382
  Height = 223
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 40
    Top = 8
    Width = 75
    Height = 25
    Caption = #30332#36865
    TabOrder = 0
    OnClick = Button1Click
  end
  object MSComPort: TMSComm
    Left = 112
    Top = 8
    Width = 32
    Height = 32
    OnComm = MSComPortComm
    ControlData = {
      2143341208000000ED030000ED03000001568A64000006000000010000040000
      00020100802500000000080000000000000000003F00000001000000}
  end
  object Button2: TButton
    Left = 40
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Panel1: TPanel
    Left = 16
    Top = 70
    Width = 121
    Height = 35
    Align = alCustom
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
  end
  object Button3: TButton
    Left = 144
    Top = 8
    Width = 113
    Height = 25
    Caption = #21021#22987#21270'Dll'
    TabOrder = 4
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 144
    Top = 32
    Width = 113
    Height = 25
    Caption = #37323#25918'Dll'
    TabOrder = 5
    OnClick = Button4Click
  end
  object Button6: TButton
    Left = 144
    Top = 56
    Width = 113
    Height = 25
    Caption = #35373#32622#36335#21475#21443#25976
    TabOrder = 6
    OnClick = Button6Click
  end
  object Button5: TButton
    Left = 280
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Open Port'
    TabOrder = 7
    OnClick = Button5Click
  end
  object Button8: TButton
    Left = 280
    Top = 32
    Width = 75
    Height = 25
    Caption = 'SendComand'
    TabOrder = 8
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 280
    Top = 56
    Width = 75
    Height = 25
    Caption = 'ReadData'
    TabOrder = 9
    OnClick = Button9Click
  end
  object Button10: TButton
    Left = 280
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Close Port'
    TabOrder = 10
    OnClick = Button10Click
  end
  object Button11: TButton
    Left = 280
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Weight'
    TabOrder = 11
    OnClick = Button11Click
  end
  object Button12: TButton
    Left = 144
    Top = 80
    Width = 113
    Height = 25
    Caption = #21462#24471#37325#37327
    TabOrder = 12
    OnClick = Button12Click
  end
  object Button14: TButton
    Left = 144
    Top = 104
    Width = 113
    Height = 25
    Caption = #39023#31034#31383#39636'(API)'
    TabOrder = 13
    OnClick = Button14Click
  end
  object Button7: TButton
    Left = 144
    Top = 128
    Width = 113
    Height = 25
    Caption = #39023#31034'(MSComm)'
    TabOrder = 14
    OnClick = Button7Click
  end
  object Button13: TButton
    Left = 144
    Top = 152
    Width = 113
    Height = 25
    Caption = 'Stop'
    TabOrder = 15
    OnClick = Button13Click
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 320
    OnTimer = Timer2Timer
    Top = 32
  end
end
