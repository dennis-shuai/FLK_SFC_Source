object Form1: TForm1
  Left = 213
  Top = 177
  Width = 979
  Height = 563
  Caption = 'CCM'#28204#35430#25976#25818#26597#35426#31243#24207
  Color = clCaptionText
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 48
    Top = 334
    Width = 89
    Height = 20
    Caption = 'Start Time:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 46
    Top = 214
    Width = 70
    Height = 20
    Caption = 'Process:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 43
    Top = 106
    Width = 80
    Height = 20
    Caption = 'Server IP:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 44
    Top = 164
    Width = 91
    Height = 20
    Caption = 'Data Base:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 49
    Top = 395
    Width = 81
    Height = 20
    Caption = 'End Time:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 50
    Top = 276
    Width = 30
    Height = 20
    Caption = 'SN:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 312
    Top = 29
    Width = 419
    Height = 29
    AutoSize = False
    Caption = 'CCM'#28204#35430#25976#25818#26597#35426#31243#24207
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -24
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblQty: TLabel
    Left = 373
    Top = 481
    Width = 250
    Height = 13
    AutoSize = False
  end
  object DateTimePicker1: TDateTimePicker
    Left = 152
    Top = 330
    Width = 100
    Height = 24
    Date = 41757.571400960650000000
    Time = 41757.571400960650000000
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentFont = False
    TabOrder = 0
  end
  object DateTimePicker2: TDateTimePicker
    Left = 254
    Top = 330
    Width = 83
    Height = 24
    Date = 0.571480532409623300
    Time = 0.571480532409623300
    DateFormat = dfLong
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    Kind = dtkTime
    ParentFont = False
    TabOrder = 1
  end
  object cmbProcess: TComboBox
    Left = 150
    Top = 209
    Width = 180
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ItemHeight = 20
    ParentFont = False
    TabOrder = 2
    Items.Strings = (
      'All'
      'FF'
      'FQC'
      'MIC'
      'AUTO-TEST')
  end
  object edtIPAddr: TEdit
    Left = 150
    Top = 101
    Width = 176
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentFont = False
    TabOrder = 3
    Text = '192.168.77.4'
  end
  object edtDb: TEdit
    Left = 149
    Top = 157
    Width = 179
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentFont = False
    TabOrder = 4
    Text = 'CCM'
  end
  object DateTimePicker3: TDateTimePicker
    Left = 154
    Top = 390
    Width = 98
    Height = 24
    Date = 41757.571400960650000000
    Time = 41757.571400960650000000
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentFont = False
    TabOrder = 5
  end
  object DateTimePicker4: TDateTimePicker
    Left = 255
    Top = 389
    Width = 81
    Height = 24
    Date = 0.571480532409623300
    Time = 0.571480532409623300
    DateFormat = dfLong
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    Kind = dtkTime
    ParentFont = False
    TabOrder = 6
  end
  object edtSN: TEdit
    Left = 149
    Top = 269
    Width = 184
    Height = 28
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    ParentFont = False
    TabOrder = 7
  end
  object DBGrid1: TDBGrid
    Left = 371
    Top = 101
    Width = 578
    Height = 321
    DataSource = DataSource1
    ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
    TabOrder = 8
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object ProgressBar1: TProgressBar
    Left = 374
    Top = 447
    Width = 455
    Height = 17
    TabOrder = 9
  end
  object btnConnect: TBitBtn
    Left = 62
    Top = 451
    Width = 90
    Height = 29
    Caption = #36899#25509#25976#25818#24235
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 10
    OnClick = btnConnectClick
  end
  object btnQuery: TBitBtn
    Left = 243
    Top = 451
    Width = 86
    Height = 26
    Caption = #26597#35426
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 11
    OnClick = btnQueryClick
  end
  object BitBtn1: TBitBtn
    Left = 845
    Top = 447
    Width = 90
    Height = 31
    Caption = #23566#20986#25976#25818
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 12
    OnClick = BitBtn1Click
  end
  object DataSource1: TDataSource
    DataSet = ADOQry
    Left = 776
    Top = 45
  end
  object ADOQry: TADOQuery
    Connection = ADOConn
    Parameters = <>
    Left = 840
    Top = 42
  end
  object ADOConn: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=SQLOLEDB.1;Persist Security Info=False;User ID=sa;Initi' +
      'al Catalog=CCM;PWD=foxlinkccm;Data Source=192.168.77.4'
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 730
    Top = 44
  end
  object SaveDialog1: TSaveDialog
    Filter = 'CSV|*.CSV'
    Left = 877
    Top = 44
  end
end
