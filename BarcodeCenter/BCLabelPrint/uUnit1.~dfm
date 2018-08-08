object PrintForm: TPrintForm
  Left = 343
  Top = 310
  Width = 675
  Height = 509
  Caption = 'BCLabelPrint'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 6
    Top = 172
    Width = 73
    Height = 13
    Caption = 'Work_Order:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 667
    Height = 65
    Align = alTop
    TabOrder = 0
    object lbl2: TLabel
      Left = 22
      Top = 20
      Width = 73
      Height = 13
      Caption = 'Work_Order:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object EdtWO: TEdit
      Left = 104
      Top = 16
      Width = 145
      Height = 24
      CharCase = ecUpperCase
      Color = clYellow
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      Text = 'NIS14001AA'
      OnKeyPress = EdtWOKeyPress
    end
    object PrintStart: TButton
      Left = 288
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Start'
      Enabled = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = PrintStartClick
    end
    object PrintStop: TButton
      Left = 400
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Stop'
      Enabled = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = PrintStopClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 65
    Width = 667
    Height = 342
    Align = alClient
    TabOrder = 1
    object Label3: TLabel
      Left = 22
      Top = 44
      Width = 49
      Height = 13
      Caption = 'Box_No:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblCount: TLabel
      Left = 22
      Top = 316
      Width = 75
      Height = 13
      Caption = 'S/N_Count:0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label4: TLabel
      Left = 22
      Top = 220
      Width = 60
      Height = 13
      Caption = 'GoTo_SN:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblROW: TLabel
      Left = 22
      Top = 268
      Width = 87
      Height = 13
      Caption = 'Present_Row:0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Bevel1: TBevel
      Left = 0
      Top = 168
      Width = 233
      Height = 1
      Shape = bsBottomLine
      Style = bsRaised
    end
    object Label5: TLabel
      Left = 22
      Top = 108
      Width = 63
      Height = 13
      Caption = 'Print_QTY:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object DBGrid1: TDBGrid
      Left = 232
      Top = 1
      Width = 434
      Height = 340
      Align = alRight
      DataSource = DataSource1
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
      ParentFont = False
      TabOrder = 0
      TitleFont.Charset = ANSI_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -13
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = [fsBold]
      Columns = <
        item
          Expanded = False
          FieldName = 'BOX_NO'
          Width = 120
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'WORK_ORDER'
          Width = 100
          Visible = True
        end>
    end
    object EditBOX: TEdit
      Left = 72
      Top = 40
      Width = 145
      Height = 24
      CharCase = ecUpperCase
      Color = clInfoBk
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
      OnKeyPress = EdtWOKeyPress
    end
    object GOTOSN: TEdit
      Left = 88
      Top = 216
      Width = 129
      Height = 24
      CharCase = ecUpperCase
      Color = clBtnFace
      Enabled = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnChange = GOTOSNChange
    end
    object cbbPrintQTY: TComboBox
      Left = 96
      Top = 104
      Width = 121
      Height = 24
      Style = csDropDownList
      Color = clYellow
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ItemHeight = 16
      ParentFont = False
      TabOrder = 3
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 407
    Width = 667
    Height = 68
    Align = alBottom
    TabOrder = 2
    object lablLabel: TLabel
      Left = 22
      Top = 18
      Width = 96
      Height = 13
      Caption = 'Label File Name:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lablDesc: TLabel
      Left = 128
      Top = 18
      Width = 366
      Height = 13
      Caption = 'MQ_ + Part No   /  MQ_ + Part No Label File   /   MQ_ + Default'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lbl6: TLabel
      Left = 24
      Top = 42
      Width = 167
      Height = 13
      Caption = 'Version: 5.3.0.1  (20110415)'
      Font.Charset = CHINESEBIG5_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
  end
  object SimpleObjectBroker1: TSimpleObjectBroker
    Left = 360
    Top = 120
  end
  object dsQryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    RemoteServer = SocketConnection1
    Left = 472
    Top = 120
  end
  object DataSource1: TDataSource
    DataSet = dsQryData
    OnDataChange = DataSource1DataChange
    Left = 400
    Top = 177
  end
  object SocketConnection1: TSocketConnection
    ServerName = 'SajetApserver.RMDB'
    ObjectBroker = SimpleObjectBroker1
    Left = 416
    Top = 120
  end
end
