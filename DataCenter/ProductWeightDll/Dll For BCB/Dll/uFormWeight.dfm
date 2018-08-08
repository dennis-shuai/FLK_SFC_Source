object WeightForm: TWeightForm
  Left = 448
  Top = 339
  BorderStyle = bsNone
  Caption = 'WeightForm'
  ClientHeight = 117
  ClientWidth = 344
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblReadKG: TLabel
    Left = 0
    Top = 0
    Width = 344
    Height = 117
    Align = alClient
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0000.00g'
    Color = clBlack
    Font.Charset = ANSI_CHARSET
    Font.Color = clYellow
    Font.Height = -67
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
    OnDblClick = lblReadKGDblClick
    OnMouseDown = lblReadKGMouseDown
  end
  object MSComPort: TMSComm
    Left = 8
    Top = 8
    Width = 32
    Height = 32
    OnComm = MSComPortComm
    ControlData = {
      2143341208000000ED030000ED03000001568A64000006000000010000040000
      00020100802500000000080000000000000000003F00000001000000}
  end
  object SendComTime: TTimer
    Enabled = False
    Interval = 80
    OnTimer = SendComTimeTimer
    Left = 48
    Top = 8
  end
  object MSCommTimer: TTimer
    Enabled = False
    Interval = 80
    OnTimer = MSCommTimerTimer
    Left = 88
    Top = 8
  end
end
