object uMainForm: TuMainForm
  Left = 306
  Top = 125
  BorderStyle = bsDialog
  Caption = #29986#32218#27231#21488#32173#20462#32113#35336#31995#32113' 1.0.1.0 '
  ClientHeight = 647
  ClientWidth = 692
  Color = 14478579
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 160
    Top = 8
    Width = 321
    Height = 37
    AutoSize = False
    Caption = #29986#32218#35373#20633#32173#20462#32113#35336
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    OnDblClick = Label1DblClick
  end
  object Panel1: TPanel
    Left = 16
    Top = 232
    Width = 657
    Height = 113
    Color = 13297596
    TabOrder = 0
    object lbl3: TLabel
      Left = 64
      Top = 88
      Width = 338
      Height = 13
      Caption = #22914#26524#27231#22120#22750#20102#35531#35069#36896#37096#21729#24037#36664#20837#20197#19979#20449#24687#65292#28982#24460#40670#25802#25353#37397#65306
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #26032#32048#26126#39636
      Font.Style = []
      ParentFont = False
    end
    object lbl4: TLabel
      Left = 16
      Top = 8
      Width = 233
      Height = 16
      AutoSize = False
      Caption = #29986#32218#29983#29986#20154#21729#25033#36664#20837#20449#24687#65306
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lblMfgMsg: TLabel
      Left = 488
      Top = 80
      Width = 153
      Height = 25
      AutoSize = False
      Layout = tlCenter
    end
    object btnDefect: TButton
      Left = 136
      Top = 40
      Width = 361
      Height = 41
      Caption = #27231#22120#22750#20102
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnDefectClick
    end
  end
  object Panel2: TPanel
    Left = 16
    Top = 352
    Width = 657
    Height = 281
    Color = 14799566
    TabOrder = 1
    object lbl1: TLabel
      Left = 16
      Top = 209
      Width = 130
      Height = 24
      Caption = #32173#20462#38917#30446#65306'    '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbl5: TLabel
      Left = 16
      Top = 64
      Width = 112
      Height = 24
      Caption = #32173#20462#20154#21729#65306' '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbl6: TLabel
      Left = 16
      Top = 16
      Width = 180
      Height = 25
      AutoSize = False
      Caption = #32173#20462#20154#21729#25033#35442#36664#20837#20449#24687#65306
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lbl7: TLabel
      Left = 56
      Top = 96
      Width = 260
      Height = 13
      Caption = #65288#32173#20462#20154#21729#38283#22987#32173#20462#26178#20505#65292#35531#36984#25799#33258#24049#22995#21517#65289
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #26032#32048#26126#39636
      Font.Style = []
      ParentFont = False
    end
    object lbl8: TLabel
      Left = 56
      Top = 240
      Width = 260
      Height = 13
      Caption = #65288#32173#20462#20154#21729#23436#25104#32173#20462#26178#20505#65292#35531#36984#25799#32173#20462#38917#30446#65289
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #26032#32048#26126#39636
      Font.Style = []
      ParentFont = False
    end
    object lblSRmsg: TLabel
      Left = 488
      Top = 96
      Width = 153
      Height = 25
      AutoSize = False
      Layout = tlCenter
    end
    object lbl2: TLabel
      Left = 24
      Top = 141
      Width = 96
      Height = 20
      Caption = #19981#33391#27512#39006#65306'  '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnEndRepair: TButton
      Left = 488
      Top = 152
      Width = 153
      Height = 73
      Caption = #32173#20462#23436#25104
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnEndRepairClick
    end
    object cmbRepair: TComboBox
      Left = 152
      Top = 201
      Width = 305
      Height = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #20013#25991'(?'#20307') - 2345'#29579#29260#25340#38899'?'#20837#27861
      ItemHeight = 24
      ParentFont = False
      TabOrder = 1
      OnSelect = cmbRepairSelect
    end
    object btnStartRepair: TButton
      Left = 488
      Top = 48
      Width = 153
      Height = 49
      Caption = #38283#22987#32173#20462
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = btnStartRepairClick
    end
    object cmbEmp: TComboBox
      Left = 152
      Top = 57
      Width = 305
      Height = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #20013#25991'(?'#20307') - 2345'#29579#29260#25340#38899'?'#20837#27861
      ItemHeight = 24
      ParentFont = False
      TabOrder = 3
      OnSelect = cmbEmpSelect
    end
    object cmbDefect: TComboBox
      Left = 152
      Top = 137
      Width = 305
      Height = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #20013#25991'(?'#20307') - 2345'#29579#29260#25340#38899'?'#20837#27861
      ItemHeight = 24
      ParentFont = False
      TabOrder = 4
      OnSelect = cmbDefectSelect
    end
  end
  object Panel3: TPanel
    Left = 16
    Top = 56
    Width = 657
    Height = 169
    Color = 12701689
    TabOrder = 2
    object lbl9: TLabel
      Left = 40
      Top = 64
      Width = 86
      Height = 20
      Caption = #27231#21488#21517#31281#65306
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblMachine: TLabel
      Left = 40
      Top = 96
      Width = 465
      Height = 65
      Alignment = taCenter
      AutoSize = False
      Color = 12701689
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -64
      Font.Name = #26032#32048#26126#39636
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Layout = tlCenter
    end
    object lblDept: TLabel
      Left = 512
      Top = 28
      Width = 36
      Height = 13
      Caption = #37096#38272#65306
      Visible = False
    end
    object Label2: TLabel
      Left = 40
      Top = 24
      Width = 86
      Height = 20
      Caption = #27231#21488#39006#22411#65306
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cmbMachine: TComboBox
      Left = 160
      Top = 56
      Width = 313
      Height = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #20013#25991'(?'#20307') - 2345'#29579#29260#25340#38899'?'#20837#27861
      ItemHeight = 24
      ParentFont = False
      TabOrder = 0
      OnSelect = cmbMachineSelect
    end
    object cmbType: TComboBox
      Left = 160
      Top = 16
      Width = 313
      Height = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #20013#25991'(?'#20307') - 2345'#29579#29260#25340#38899'?'#20837#27861
      ItemHeight = 24
      ParentFont = False
      TabOrder = 1
      OnSelect = cmbTypeSelect
    end
  end
  object cmbDept: TComboBox
    Left = 568
    Top = 80
    Width = 89
    Height = 21
    Style = csDropDownList
    ImeName = #20013#25991'(?'#20307') - 2345'#29579#29260#25340#38899'?'#20837#27861
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 3
    Text = 'CCM-2330'
    Visible = False
    OnSelect = cmbDeptSelect
    Items.Strings = (
      'CCM-2330'
      'CCM-9865'
      'CCM-9866')
  end
  object SimpleObjectBroker1: TSimpleObjectBroker
    Left = 106
    Top = 4
  end
  object QryData: TClientDataSet
    Aggregates = <>
    FetchOnDemand = False
    Params = <>
    ProviderName = 'DspQryData'
    RemoteServer = SocketConnection1
    Left = 3
    Top = 3
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    RemoteServer = SocketConnection1
    Left = 36
    Top = 3
  end
  object SocketConnection1: TSocketConnection
    ServerGUID = '{AF550BF4-3BA4-415D-B1F3-E2F7C8ADE30C}'
    ServerName = 'SajetApserver.RMDB'
    ObjectBroker = SimpleObjectBroker1
    Left = 71
    Top = 6
  end
end
