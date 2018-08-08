object Form1: TForm1
  Left = 242
  Top = 139
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Amazon Auto Upload Program 2.0.2.0'
  ClientHeight = 391
  ClientWidth = 493
  Color = 14799566
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panl1: TLabel
    Left = 48
    Top = 8
    Width = 386
    Height = 42
    Alignment = taCenter
    Caption = 'Amazon Data Auto Upload'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -35
    Font.Name = 'Calibri'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Panel2: TPanel
    Left = 6
    Top = 56
    Width = 483
    Height = 329
    Color = 14347742
    TabOrder = 0
    object lbl4: TLabel
      Left = 86
      Top = 84
      Width = 75
      Height = 13
      Caption = 'Model Name:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbl5: TLabel
      Left = 64
      Top = 172
      Width = 102
      Height = 13
      Caption = 'Product Segment:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbl6: TLabel
      Left = 112
      Top = 236
      Width = 81
      Height = 13
      AutoSize = False
      Caption = 'Process:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblMac: TLabel
      Left = 184
      Top = 160
      Width = 225
      Height = 13
      AutoSize = False
    end
    object Panl2: TLabel
      Left = 128
      Top = 204
      Width = 29
      Height = 13
      Caption = 'Line:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Panl4: TLabel
      Left = 176
      Top = 104
      Width = 143
      Height = 13
      Caption = '('#24517#38920#21644'FTP'#19978#27231#31278#21517#23565#25033#65289
    end
    object lblMsg: TLabel
      Left = 56
      Top = 480
      Width = 400
      Height = 33
      AutoSize = False
      WordWrap = True
    end
    object lbl7: TLabel
      Left = 118
      Top = 52
      Width = 44
      Height = 13
      Caption = 'FTP IP:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbl1: TLabel
      Left = 56
      Top = 20
      Width = 62
      Height = 13
      Caption = 'Data Path:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbl3: TLabel
      Left = 80
      Top = 132
      Width = 72
      Height = 13
      Caption = 'Folder Prefix'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnSave: TBitBtn
      Left = 96
      Top = 280
      Width = 105
      Height = 25
      Caption = 'Save Settings'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnSaveClick
    end
    object btnUpload: TBitBtn
      Left = 296
      Top = 280
      Width = 105
      Height = 25
      Caption = 'Upload Data'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = btnUploadClick
    end
    object edtModel: TEdit
      Left = 176
      Top = 80
      Width = 209
      Height = 21
      TabOrder = 2
      Text = 'FO50FF-645H_Insomnia'
    end
    object mmo1: TMemo
      Left = 8
      Top = 136
      Width = 57
      Height = 41
      Lines.Strings = (
        'ftp'
        'open '
        '192.168.7'
        '6.251'
        'amz'
        'amz'
        'prompt'
        'binary')
      TabOrder = 3
      Visible = False
    end
    object cmbProcess: TComboBox
      Left = 176
      Top = 232
      Width = 209
      Height = 21
      ItemHeight = 13
      TabOrder = 4
      Items.Strings = (
        'Focus'
        'CCL'
        'FQC'
        'FQA')
    end
    object edtIP: TEdit
      Left = 176
      Top = 48
      Width = 209
      Height = 21
      TabOrder = 5
      Text = '172.16.245.50'
    end
    object edtSourcePath: TEdit
      Left = 136
      Top = 16
      Width = 273
      Height = 21
      TabOrder = 6
      Text = 'D:\Report\'
    end
    object cmbLine: TComboBox
      Left = 176
      Top = 200
      Width = 209
      Height = 21
      ItemHeight = 13
      TabOrder = 7
      Items.Strings = (
        '01'
        '02'
        '03'
        '04'
        '05'
        '06'
        '07'
        '08'
        '09'
        '10')
    end
    object edtPrefix: TEdit
      Left = 176
      Top = 128
      Width = 209
      Height = 21
      TabOrder = 8
      Text = 'Insomnia_645H'
    end
  end
  object cmbSeg: TComboBox
    Left = 184
    Top = 224
    Width = 209
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    Items.Strings = (
      'EVT'
      'DVT'
      'PVT'
      'MP')
  end
  object con1: TSocketConnection
    ServerName = 'SajetApserver.RMDB'
    ObjectBroker = smplbjctbrkr1
    Left = 8
  end
  object smplbjctbrkr1: TSimpleObjectBroker
    Left = 72
  end
  object Qry1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    RemoteServer = con1
    Left = 104
  end
  object dlgOpen1: TOpenDialog
    Filter = 'exe|*.exe'
    Left = 8
    Top = 24
  end
  object idftp2: TIdFTP
    MaxLineAction = maException
    ReadTimeout = 0
    Password = 'amz'
    Username = 'amz'
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    Left = 456
    Top = 8
  end
end
