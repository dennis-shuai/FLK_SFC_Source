object Form1: TForm1
  Left = 341
  Top = 137
  Width = 828
  Height = 542
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
  object lblMsg: TLabel
    Left = 40
    Top = 352
    Width = 745
    Height = 105
    AutoSize = False
  end
  object lbl1: TLabel
    Left = 152
    Top = 24
    Width = 61
    Height = 47
    Caption = 'SN:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -37
    Font.Name = #24494#36575#27491#40657#39636
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lbl2: TLabel
    Left = 16
    Top = 8
    Width = 94
    Height = 13
    Caption = 'version :1'
  end
  object Label1: TLabel
    Left = 40
    Top = 192
    Width = 140
    Height = 47
    Caption = 'Data'#65306'  '
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -37
    Font.Name = #24494#36575#27491#40657#39636
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btn4: TButton
    Left = 192
    Top = 80
    Width = 185
    Height = 49
    Caption = #38617#25885#20687#38957#19978#20659
    TabOrder = 0
    OnClick = btn4Click
  end
  object btn5: TButton
    Left = 424
    Top = 80
    Width = 209
    Height = 49
    Caption = #21934#25885#20687#38957#19978#20659
    TabOrder = 1
    OnClick = btn5Click
  end
  object edtSN: TEdit
    Left = 232
    Top = 16
    Width = 369
    Height = 55
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -37
    Font.Name = #24494#36575#27491#40657#39636
    Font.Style = [fsBold]
    ImeName = #20013#25991'(?'#20307') - 2345'#29579#29260#25340#38899'?'#20837#27861
    ParentFont = False
    TabOrder = 2
    Text = 'DFQPT0385892GJ'
  end
  object mmoData: TMemo
    Left = 168
    Top = 176
    Width = 601
    Height = 89
    ImeName = #20013#25991'(?'#20307') - 2345'#29579#29260#25340#38899'?'#20837#27861
    TabOrder = 3
  end
  object btnUploadString: TButton
    Left = 240
    Top = 280
    Width = 369
    Height = 49
    Caption = #23383#31526#20018#19978#20659
    TabOrder = 4
    OnClick = btnUploadStringClick
  end
  object sp1: TADOStoredProc
    Parameters = <>
    Left = 88
    Top = 144
  end
  object con1: TADOConnection
    Left = 72
    Top = 288
  end
end
