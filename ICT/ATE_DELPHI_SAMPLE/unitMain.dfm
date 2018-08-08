object Form1: TForm1
  Left = 321
  Top = 173
  Width = 696
  Height = 235
  Caption = 'mkj '
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 96
    Top = 160
    Width = 49
    Height = 13
    Caption = 'Result : '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 352
    Top = 32
    Width = 73
    Height = 13
    Caption = 'LOOP COUNT:'
  end
  object Button1: TButton
    Left = 24
    Top = 8
    Width = 169
    Height = 33
    Caption = 'Start'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 24
    Top = 40
    Width = 169
    Height = 33
    Caption = 'Close'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 24
    Top = 72
    Width = 169
    Height = 33
    Caption = 'Send Data'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnClick = Button3Click
  end
  object Edit1: TEdit
    Left = 80
    Top = 112
    Width = 577
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
  end
  object SpinEdit1: TSpinEdit
    Left = 24
    Top = 112
    Width = 49
    Height = 30
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    MaxLength = 1
    MaxValue = 1000
    MinValue = 1
    ParentFont = False
    TabOrder = 4
    Value = 1
  end
  object Edit2: TEdit
    Left = 440
    Top = 24
    Width = 73
    Height = 21
    TabOrder = 5
    Text = '10'
  end
end
