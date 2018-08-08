object FormUpdate: TFormUpdate
  Left = 435
  Top = 437
  BorderStyle = bsNone
  Caption = 'FormUpdate'
  ClientHeight = 66
  ClientWidth = 367
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 367
    Height = 45
    Align = alClient
    Caption = #27491#22312#27298#26597#31243#24207#26356#26032'...'
    Font.Charset = ANSI_CHARSET
    Font.Color = clGreen
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 45
    Width = 367
    Height = 21
    Align = alBottom
    TabOrder = 1
  end
  object auAutoUpgrader1: TauAutoUpgrader
    InfoFileURL = 'http://'
    VersionControl = byNumber
    VersionDate = '03/15/2012'
    VersionDateAutoSet = True
    ShowMessages = [mConnLost, mHostUnreachable, mLostFile, mNoInfoFile, mNoUpdateAvailable, mPasswordRequest]
    Wizard.Enabled = False
    OnEndUpgrade = auAutoUpgrader1EndUpgrade
    OnProgress = auAutoUpgrader1Progress
    OnFileStart = auAutoUpgrader1FileStart
    OnFileDone = auAutoUpgrader1FileDone
    OnConnLost = auAutoUpgrader1ConnLost
    OnHostUnreachable = auAutoUpgrader1HostUnreachable
    OnNoUpdateAvailable = auAutoUpgrader1NoUpdateAvailable
    OnNoInfoFile = auAutoUpgrader1NoInfoFile
    Left = 296
    Top = 8
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer1Timer
    Left = 264
    Top = 8
  end
  object IdHTTP1: TIdHTTP
    MaxLineAction = maException
    ReadTimeout = 0
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = 0
    Request.ContentRangeStart = 0
    Request.ContentType = 'text/html'
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 328
    Top = 8
  end
end
