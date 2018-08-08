object ErrorForm: TErrorForm
  Left = 301
  Top = 230
  BorderStyle = bsNone
  Caption = 'Exception Information'
  ClientHeight = 606
  ClientWidth = 862
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDblClick = FormDblClick
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 96
    Top = 168
    Width = 718
    Height = 33
    Alignment = taCenter
    Caption = 'Exception information, programs stopped and locked'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -27
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label2: TLabel
    Left = 256
    Top = 216
    Width = 409
    Height = 33
    Alignment = taCenter
    Caption = 'Inform QA confirm and unlock'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -27
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label3: TLabel
    Left = 296
    Top = 452
    Width = 88
    Height = 23
    Caption = 'PassWord:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clYellow
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Label4: TLabel
    Left = 248
    Top = 256
    Width = 466
    Height = 33
    Alignment = taCenter
    Caption = '('#30064#24120#20449#24687','#31243#24207#37782#23450#35531#36890#30693'IPQC'#35299#37782')'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -27
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Edit1: TEdit
    Left = 384
    Top = 448
    Width = 193
    Height = 31
    CharCase = ecUpperCase
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 0
  end
  object Memo1: TMemo
    Left = 176
    Top = 320
    Width = 569
    Height = 113
    Color = clBlack
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    Lines.Strings = (
      'Repeat SN')
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
  end
end
