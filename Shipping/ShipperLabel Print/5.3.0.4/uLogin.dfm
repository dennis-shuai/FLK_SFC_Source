object FormLogin: TFormLogin
  Left = 487
  Top = 370
  Width = 386
  Height = 153
  Caption = 'Login'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 32
    Width = 72
    Height = 16
    Caption = 'PassWord:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'System'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label2: TLabel
    Left = 32
    Top = 72
    Width = 314
    Height = 16
    Caption = 'Pls Enter the Password and change the settings '
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'System'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Edit1: TEdit
    Left = 104
    Top = 29
    Width = 233
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'System'
    Font.Style = [fsBold]
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#20116'??'#20837#27861
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 0
  end
  object QueryPWD: TADOQuery
    Parameters = <>
    Left = 8
  end
end
