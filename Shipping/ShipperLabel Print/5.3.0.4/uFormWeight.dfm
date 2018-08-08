object WeightForm: TWeightForm
  Left = 468
  Top = 328
  BorderStyle = bsNone
  Caption = 'WeightForm'
  ClientHeight = 212
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblReadKG: TLabel
    Left = 16
    Top = 8
    Width = 345
    Height = 97
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
  end
  object lblInfomation: TLabel
    Left = 192
    Top = 120
    Width = 97
    Height = 81
    Alignment = taCenter
    AutoSize = False
    Caption = 'Ready'
    Color = clGreen
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -35
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
  end
  object BitBtn1: TBitBtn
    Left = 296
    Top = 176
    Width = 65
    Height = 25
    Caption = 'Close'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 112
    Width = 169
    Height = 89
    Caption = 'Limit'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    object Label1: TLabel
      Left = 15
      Top = 18
      Width = 65
      Height = 16
      Alignment = taRightJustify
      Caption = 'Up_Limit:'
    end
    object Label2: TLabel
      Left = 10
      Top = 56
      Width = 72
      Height = 16
      Alignment = taRightJustify
      Caption = 'Low_Limit:'
    end
    object EditUpLimit: TEdit
      Left = 88
      Top = 16
      Width = 73
      Height = 24
      Enabled = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      Text = '0'
    end
    object EditLowLimit: TEdit
      Left = 88
      Top = 52
      Width = 73
      Height = 24
      Enabled = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      Text = '0'
    end
  end
  object BitBtn2: TBitBtn
    Left = 296
    Top = 148
    Width = 65
    Height = 25
    Caption = 'To obtain'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnClick = BitBtn2Click
  end
  object Button1: TButton
    Left = 296
    Top = 120
    Width = 65
    Height = 25
    Caption = 'Display'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnClick = Button1Click
  end
  object MSComPort: TMSComm
    Left = 48
    Top = 64
    Width = 32
    Height = 32
    OnComm = MSComPortComm
    ControlData = {
      2143341208000000ED030000ED03000001568A64000006000000010000040000
      00020100802500000000080000000000000000003F00000001000000}
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 50
    OnTimer = Timer1Timer
    Left = 16
    Top = 64
  end
end
