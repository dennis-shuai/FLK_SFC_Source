object fMain: TfMain
  Left = 261
  Top = 196
  Width = 1339
  Height = 660
  Caption = 'fMain'
  Color = clTeal
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object mmo1: TMemo
    Left = 856
    Top = 0
    Width = 465
    Height = 217
    TabOrder = 0
  end
  object strngrd: TStringGrid1
    Left = 8
    Top = 224
    Width = 1313
    Height = 281
    ColCount = 14
    DefaultColWidth = 92
    FixedColor = clBackground
    RowCount = 3
    TabOrder = 1
  end
  object grdpnl1: TGradPanel
    Left = 8
    Top = 0
    Width = 841
    Height = 97
    TabOrder = 2
    ColorShadow = clPurple
    ColorStart = clGreen
    object lbl7: TLabel
      Left = 56
      Top = 16
      Width = 398
      Height = 37
      Caption = 'CCM  SFC '#33258#21205#25475#25551#27231'       '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -32
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
  end
  object grdpnl2: TGradPanel
    Left = 8
    Top = 104
    Width = 841
    Height = 113
    TabOrder = 3
    ColorStart = clGreen
    object lbl1: TLabel
      Left = 16
      Top = 28
      Width = 52
      Height = 13
      Alignment = taCenter
      Caption = #27231#31278#65306
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
      Layout = tlCenter
    end
    object lbl2: TLabel
      Left = 282
      Top = 24
      Width = 64
      Height = 17
      Alignment = taCenter
      Caption = #32317#25976#37327#65306
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
      Layout = tlCenter
    end
    object lbl3: TLabel
      Left = 312
      Top = 60
      Width = 76
      Height = 13
      Alignment = taCenter
      Caption = #25976#37327#35373#32622#65306
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
      Layout = tlCenter
    end
    object lbl4: TLabel
      Left = 16
      Top = 64
      Width = 49
      Height = 17
      Caption = 'Tray NO. :'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object lbl5: TLabel
      Left = 516
      Top = 24
      Width = 44
      Height = 17
      Alignment = taCenter
      Caption = #21015#25976#65306
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
      Layout = tlCenter
    end
    object lbl6: TLabel
      Left = 640
      Top = 28
      Width = 52
      Height = 13
      Alignment = taCenter
      Caption = #34892#25976#65306
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
      Layout = tlCenter
    end
    object edt1: TEdit
      Left = 360
      Top = 20
      Width = 129
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object edt2: TEdit
      Left = 392
      Top = 52
      Width = 129
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object cmb1: TComboBox
      Left = 72
      Top = 20
      Width = 145
      Height = 21
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemHeight = 13
      ParentFont = False
      TabOrder = 2
    end
    object edt3: TEdit
      Left = 80
      Top = 56
      Width = 209
      Height = 25
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object edt4: TEdit
      Left = 560
      Top = 20
      Width = 65
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
    end
    object edt5: TEdit
      Left = 696
      Top = 20
      Width = 65
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
    end
    object btn1: TRzButton
      Left = 712
      Top = 80
      Caption = #35373#32622
      TabOrder = 6
      OnClick = btn1Click
    end
  end
  object commMa: TComm
    CommName = 'COM1'
    BaudRate = 9600
    ParityCheck = False
    Outx_CtsFlow = False
    Outx_DsrFlow = False
    DtrControl = DtrEnable
    DsrSensitivity = False
    TxContinueOnXoff = True
    Outx_XonXoffFlow = True
    Inx_XonXoffFlow = True
    ReplaceWhenParityError = False
    IgnoreNullChar = False
    RtsControl = RtsEnable
    XonLimit = 500
    XoffLimit = 500
    ByteSize = _8
    Parity = None
    StopBits = _1
    XonChar = #17
    XoffChar = #19
    ReplacedChar = #0
    ReadIntervalTimeout = 100
    ReadTotalTimeoutMultiplier = 0
    ReadTotalTimeoutConstant = 0
    WriteTotalTimeoutMultiplier = 0
    WriteTotalTimeoutConstant = 0
    OnReceiveData = commMaReceiveData
    Left = 16
    Top = 8
  end
  object commScan: TComm
    CommName = 'COM1'
    BaudRate = 9600
    ParityCheck = False
    Outx_CtsFlow = False
    Outx_DsrFlow = False
    DtrControl = DtrEnable
    DsrSensitivity = False
    TxContinueOnXoff = True
    Outx_XonXoffFlow = True
    Inx_XonXoffFlow = True
    ReplaceWhenParityError = False
    IgnoreNullChar = False
    RtsControl = RtsEnable
    XonLimit = 500
    XoffLimit = 500
    ByteSize = _8
    Parity = None
    StopBits = _1
    XonChar = #17
    XoffChar = #19
    ReplacedChar = #0
    ReadIntervalTimeout = 100
    ReadTotalTimeoutMultiplier = 0
    ReadTotalTimeoutConstant = 0
    WriteTotalTimeoutMultiplier = 0
    WriteTotalTimeoutConstant = 0
    OnReceiveData = commMaReceiveData
    Left = 48
    Top = 8
  end
end
