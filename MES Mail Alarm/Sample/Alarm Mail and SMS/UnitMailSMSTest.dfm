object formMailSMSTest: TformMailSMSTest
  Left = 494
  Top = 282
  Width = 245
  Height = 169
  Caption = 'Mail and SMS Testing'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnSendMail: TButton
    Left = 15
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Send Mail'
    TabOrder = 0
    OnClick = btnSendMailClick
  end
  object btnSendSMS: TButton
    Left = 144
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Send SMS'
    TabOrder = 1
    OnClick = btnSendSMSClick
  end
  object IdMessage1: TIdMessage
    AttachmentEncoding = 'MIME'
    BccList = <>
    CCList = <>
    Encoding = meMIME
    Recipients = <>
    ReplyTo = <>
    Left = 344
    Top = 8
  end
  object SMTP1: TIdSMTP
    MaxLineAction = maException
    ReadTimeout = 0
    Port = 25
    AuthenticationType = atNone
    Left = 376
    Top = 8
  end
  object IdMessage2: TIdMessage
    AttachmentEncoding = 'MIME'
    BccList = <>
    CCList = <>
    Encoding = meMIME
    Recipients = <>
    ReplyTo = <>
    Left = 344
    Top = 8
  end
  object IdSMTP1: TIdSMTP
    MaxLineAction = maException
    ReadTimeout = 0
    Port = 25
    AuthenticationType = atNone
    Left = 376
    Top = 8
  end
  object IdMessage3: TIdMessage
    AttachmentEncoding = 'MIME'
    BccList = <>
    CCList = <>
    Encoding = meMIME
    Recipients = <>
    ReplyTo = <>
    Left = 344
    Top = 8
  end
  object IdSMTP2: TIdSMTP
    MaxLineAction = maException
    ReadTimeout = 0
    Port = 25
    AuthenticationType = atNone
    Left = 376
    Top = 8
  end
  object IdMessage4: TIdMessage
    AttachmentEncoding = 'MIME'
    BccList = <>
    CCList = <>
    Encoding = meMIME
    Recipients = <>
    ReplyTo = <>
    Left = 344
    Top = 8
  end
  object IdSMTP3: TIdSMTP
    MaxLineAction = maException
    ReadTimeout = 0
    Port = 25
    AuthenticationType = atNone
    Left = 376
    Top = 8
  end
  object IdMessage5: TIdMessage
    AttachmentEncoding = 'MIME'
    BccList = <>
    CCList = <>
    Encoding = meMIME
    Recipients = <>
    ReplyTo = <>
    Left = 344
    Top = 8
  end
  object IdSMTP4: TIdSMTP
    MaxLineAction = maException
    ReadTimeout = 0
    Port = 25
    AuthenticationType = atNone
    Left = 376
    Top = 8
  end
  object IdSMTP5: TIdSMTP
    MaxLineAction = maException
    ReadTimeout = 0
    Port = 25
    AuthenticationType = atNone
    Left = 208
  end
  object IdMessage6: TIdMessage
    AttachmentEncoding = 'MIME'
    BccList = <>
    CCList = <>
    Encoding = meMIME
    Recipients = <>
    ReplyTo = <>
    Left = 176
  end
  object DBConn: TADOConnection
    ConnectionString = 
      'Provider=MSDASQL.1;Password=jasson@db;Persist Security Info=True' +
      ';User ID=mas;Extended Properties="Driver=MySQL ODBC 5.2 Unicode ' +
      'Driver;SERVER=192.168.78.162;UID=mas;PWD={jasson@db};DATABASE=db' +
      'adapter;PORT=21306;COLUMN_SIZE_S32=1";Initial Catalog=dbadapter'
    Provider = 'MSDASQL.1'
    Left = 144
  end
  object dbCommand: TADOCommand
    Parameters = <>
    Left = 112
  end
end
