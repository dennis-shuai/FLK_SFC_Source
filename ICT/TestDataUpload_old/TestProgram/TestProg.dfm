object Form1: TForm1
  Left = 192
  Top = 107
  Width = 1088
  Height = 563
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object shp1: TShape
    Left = 40
    Top = 8
    Width = 41
    Height = 41
    Shape = stCircle
    Visible = False
  end
  object shp2: TShape
    Left = 40
    Top = 72
    Width = 41
    Height = 41
    Shape = stCircle
    Visible = False
  end
  object shp3: TShape
    Left = 952
    Top = 192
    Width = 105
    Height = 105
    Shape = stCircle
  end
  object lbl1: TLabel
    Left = 232
    Top = 216
    Width = 369
    Height = 33
    AutoSize = False
  end
  object Model: TLabel
    Left = 224
    Top = 24
    Width = 49
    Height = 17
    AutoSize = False
    Caption = 'Model'
  end
  object lbl3: TLabel
    Left = 224
    Top = 64
    Width = 49
    Height = 17
    AutoSize = False
    Caption = 'Path'
  end
  object lbl4: TLabel
    Left = 224
    Top = 96
    Width = 49
    Height = 17
    AutoSize = False
    Caption = 'SN'
  end
  object Connect: TButton
    Left = 104
    Top = 8
    Width = 97
    Height = 41
    Caption = 'Connect Server'
    TabOrder = 0
    Visible = False
    OnClick = ConnectClick
  end
  object btn1: TButton
    Left = 104
    Top = 72
    Width = 97
    Height = 41
    Caption = 'Upload Data'
    TabOrder = 1
    Visible = False
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 104
    Top = 136
    Width = 97
    Height = 41
    Caption = 'Close Connect'
    TabOrder = 2
    Visible = False
    OnClick = btn2Click
  end
  object btn3: TButton
    Left = 232
    Top = 144
    Width = 369
    Height = 49
    Caption = 'Connect And Upload Data'
    TabOrder = 3
    OnClick = btn3Click
  end
  object edtModel: TEdit
    Left = 280
    Top = 16
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'FH50AF-429H'
  end
  object edtPath: TEdit
    Left = 280
    Top = 56
    Width = 601
    Height = 21
    TabOrder = 5
    Text = 'F:\Delphi\SFC Source Code\ICT\TestDataUpload\TestProgram\'
  end
  object edtSN: TEdit
    Left = 280
    Top = 96
    Width = 121
    Height = 21
    TabOrder = 6
  end
end
