object Form1: TForm1
  Left = 540
  Top = 695
  Width = 340
  Height = 124
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 16
    Top = 8
    Width = 73
    Height = 25
    Caption = #21021#22987#21270'DLL'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 16
    Top = 32
    Width = 145
    Height = 25
    Caption = #39023#31034#31383#39636'(MSComm)'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 16
    Top = 56
    Width = 145
    Height = 25
    Caption = #39023#31034#31383#39636'(API)'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 224
    Top = 8
    Width = 73
    Height = 25
    Caption = 'Free DLL'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 176
    Top = 32
    Width = 121
    Height = 25
    Caption = 'MSComm'#36820#22238
    TabOrder = 4
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 176
    Top = 56
    Width = 121
    Height = 25
    Caption = 'API'#36820#22238
    TabOrder = 5
    OnClick = Button6Click
  end
end
