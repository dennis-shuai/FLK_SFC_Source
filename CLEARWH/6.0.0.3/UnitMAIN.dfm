object FormMAIN: TFormMAIN
  Left = 246
  Top = 107
  Width = 827
  Height = 643
  BorderIcons = [biSystemMenu]
  Caption = 'FormMAIN'
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 368
    Top = 16
    Width = 73
    Height = 24
    Caption = #28165'  '#20489'   '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label9: TLabel
    Left = 40
    Top = 8
    Width = 48
    Height = 13
    Caption = 'EMP_NO:'
  end
  object Label10: TLabel
    Left = 40
    Top = 32
    Width = 49
    Height = 13
    Caption = 'Password:'
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 56
    Width = 793
    Height = 49
    TabOrder = 0
    object Label2: TLabel
      Left = 8
      Top = 16
      Width = 44
      Height = 13
      Caption = 'Part_NO:'
    end
    object Label3: TLabel
      Left = 208
      Top = 16
      Width = 58
      Height = 13
      Caption = 'Warehouse:'
    end
    object Label4: TLabel
      Left = 416
      Top = 16
      Width = 36
      Height = 13
      Caption = 'Locate:'
    end
    object Label5: TLabel
      Left = 592
      Top = 16
      Width = 36
      Height = 13
      Caption = 'ID_NO:'
    end
    object Editpartno: TEdit
      Left = 56
      Top = 16
      Width = 145
      Height = 21
      CharCase = ecUpperCase
      Color = clYellow
      TabOrder = 0
      Text = 'EDITPARTNO'
    end
    object EditIDNO: TEdit
      Left = 640
      Top = 16
      Width = 137
      Height = 21
      CharCase = ecUpperCase
      Enabled = False
      TabOrder = 1
      Text = 'EDITIDNO'
      OnKeyDown = EditIDNOKeyDown
    end
    object CMBwarehouse: TComboBox
      Left = 272
      Top = 16
      Width = 129
      Height = 21
      Style = csDropDownList
      Color = clYellow
      ItemHeight = 13
      TabOrder = 2
      OnChange = CMBwarehouseChange
      OnDropDown = CMBwarehouseDropDown
    end
    object cmblocate: TComboBox
      Left = 464
      Top = 16
      Width = 121
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 3
      OnDropDown = cmblocateDropDown
    end
  end
  object GroupBox2: TGroupBox
    Left = 16
    Top = 112
    Width = 433
    Height = 313
    Caption = 'Material:'
    TabOrder = 1
    object Label6: TLabel
      Left = 8
      Top = 296
      Width = 27
      Height = 13
      Caption = 'Total:'
    end
    object lbltotalmaterial: TLabel
      Left = 40
      Top = 296
      Width = 66
      Height = 13
      Caption = 'lbltotalmaterial'
    end
    object DBGridmaterial: TDBGrid
      Left = 8
      Top = 16
      Width = 417
      Height = 273
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
    end
  end
  object BTNQuery: TButton
    Left = 480
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Query'
    TabOrder = 2
    OnClick = BTNQueryClick
  end
  object GroupBox3: TGroupBox
    Left = 456
    Top = 112
    Width = 353
    Height = 313
    Caption = 'Inputmaterial'
    TabOrder = 3
    object Label7: TLabel
      Left = 16
      Top = 296
      Width = 27
      Height = 13
      Caption = 'Total:'
    end
    object lbltotalinput: TLabel
      Left = 48
      Top = 296
      Width = 53
      Height = 13
      Caption = 'lbltotalinput'
    end
    object DBGridmaterialCLEAR: TDBGrid
      Left = 8
      Top = 16
      Width = 337
      Height = 273
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
    end
    object BTNCLEAR: TButton
      Left = 272
      Top = 296
      Width = 75
      Height = 17
      Caption = 'Clear'
      Enabled = False
      TabOrder = 1
      OnClick = BTNCLEARClick
    end
  end
  object GroupBox4: TGroupBox
    Left = 16
    Top = 432
    Width = 793
    Height = 161
    Caption = 'Not Input material:'
    TabOrder = 4
    object Label8: TLabel
      Left = 8
      Top = 136
      Width = 27
      Height = 13
      Caption = 'Total:'
    end
    object lbltotalnotinput: TLabel
      Left = 40
      Top = 136
      Width = 68
      Height = 13
      Caption = 'lbltotalnotinput'
    end
    object DBGridnotinputmaterial: TDBGrid
      Left = 8
      Top = 16
      Width = 777
      Height = 113
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
    end
  end
  object BTNCHeck: TButton
    Left = 560
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Check'
    Enabled = False
    TabOrder = 5
    OnClick = BTNCHeckClick
  end
  object BTNConfirm: TButton
    Left = 640
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Confirm'
    Enabled = False
    TabOrder = 6
    OnClick = BTNConfirmClick
  end
  object BTNCLOSE: TButton
    Left = 720
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 7
    OnClick = BTNCLOSEClick
  end
  object Editemp: TEdit
    Left = 96
    Top = 8
    Width = 137
    Height = 21
    TabOrder = 8
  end
  object MaskEditpassword: TMaskEdit
    Left = 96
    Top = 32
    Width = 137
    Height = 21
    PasswordChar = '*'
    TabOrder = 9
  end
  object BtnOK: TButton
    Left = 240
    Top = 32
    Width = 25
    Height = 17
    Caption = 'OK'
    TabOrder = 10
    OnClick = BtnOKClick
  end
  object SocketConnection1: TSocketConnection
    ServerGUID = '{AF550BF4-3BA4-415D-B1F3-E2F7C8ADE30C}'
    ServerName = 'SajetApserver.RMDB'
    ObjectBroker = SimpleObjectBroker1
    Left = 104
    Top = 144
  end
  object SimpleObjectBroker1: TSimpleObjectBroker
    LoadBalanced = True
    Left = 144
    Top = 144
  end
  object Clientdatasetgmaterial: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    RemoteServer = SocketConnection1
    Left = 80
    Top = 216
  end
  object ClientDataSetgmaterialclear: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    RemoteServer = SocketConnection1
    Left = 536
    Top = 240
  end
  object ClientDataSetnoinputmaterial: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    RemoteServer = SocketConnection1
    Left = 264
    Top = 480
  end
  object DSMATERIAL: TDataSource
    DataSet = Clientdatasetgmaterial
    Left = 136
    Top = 216
  end
  object DsMATERIALCLEAR: TDataSource
    DataSet = ClientDataSetgmaterialclear
    Left = 576
    Top = 240
  end
  object DSNOTINPUTmaterial: TDataSource
    DataSet = ClientDataSetnoinputmaterial
    Left = 328
    Top = 480
  end
  object DSNULL: TDataSource
    Left = 184
    Top = 144
  end
  object ClientDataSetwarehouse: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    RemoteServer = SocketConnection1
    Left = 224
    Top = 144
  end
  object ClientDataSetlocate: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    RemoteServer = SocketConnection1
    Left = 256
    Top = 144
  end
  object ClientDataSetIDNO: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    RemoteServer = SocketConnection1
    Left = 288
    Top = 144
  end
  object ClientDataSettemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    RemoteServer = SocketConnection1
    Left = 320
    Top = 144
  end
end
