object fSetting: TfSetting
  Left = 170
  Top = 115
  Width = 1260
  Height = 603
  Caption = 'fSetting'
  Color = clBtnFace
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
  object lbl5: TLabel
    Left = 32
    Top = 204
    Width = 43
    Height = 13
    Caption = 'Z '#36600#65306'   '
    Transparent = True
  end
  object grdpnl1: TGradPanel
    Left = 8
    Top = 8
    Width = 1241
    Height = 433
    TabOrder = 0
    object lbl1: TLabel
      Left = 16
      Top = 8
      Width = 161
      Height = 17
      Caption = #40670#33184#24179#33274#25511#21046'      '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lbl6: TLabel
      Left = 24
      Top = 44
      Width = 45
      Height = 13
      Caption = #27231#31278#21517':  '
      Transparent = True
    end
    object lbl7: TLabel
      Left = 36
      Top = 178
      Width = 30
      Height = 13
      Caption = #32317#25976': '
      Transparent = True
    end
    object lbl9: TLabel
      Left = 36
      Top = 208
      Width = 33
      Height = 17
      Caption = #34892#25976':  '
      Transparent = True
    end
    object lbl10: TLabel
      Left = 36
      Top = 284
      Width = 33
      Height = 13
      Caption = #21015#25976':  '
      Transparent = True
    end
    object lbl12: TLabel
      Left = 24
      Top = 314
      Width = 45
      Height = 13
      Caption = #21015#38291#36317':  '
      Transparent = True
    end
    object lbl2: TLabel
      Left = 14
      Top = 346
      Width = 55
      Height = 13
      Caption = #36215#22987'X '#36600':  '
      Transparent = True
    end
    object lbl3: TLabel
      Left = 14
      Top = 378
      Width = 52
      Height = 13
      Caption = #36215#22987'Y'#36600':  '
      Transparent = True
    end
    object lbl4: TLabel
      Left = 14
      Top = 410
      Width = 55
      Height = 13
      Caption = #36215#22987'Z '#36600':  '
      Transparent = True
    end
    object lbl11: TLabel
      Left = 24
      Top = 244
      Width = 45
      Height = 13
      Caption = #34892#24207#34399':  '
      Transparent = True
    end
    object lbl13: TLabel
      Left = 24
      Top = 72
      Width = 45
      Height = 13
      Caption = #20018#21475#21517':  '
      Transparent = True
    end
    object lbl14: TLabel
      Left = 24
      Top = 104
      Width = 45
      Height = 17
      Caption = #27874#29305#29575':  '
      Transparent = True
    end
    object lbl15: TLabel
      Left = 36
      Top = 128
      Width = 33
      Height = 13
      Caption = #36895#24230':  '
      Transparent = True
    end
    object cmbCom: TComboBox
      Left = 80
      Top = 70
      Width = 105
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'COM1'
      Items.Strings = (
        'COM1'
        'COM2'
        'COM3'
        'COM4'
        'COM5'
        'COM6')
    end
    object btnOpenMa: TButton
      Left = 216
      Top = 72
      Width = 75
      Height = 25
      Caption = 'Open'
      TabOrder = 1
      OnClick = btnOpenMaClick
    end
    object btnBack: TButton
      Left = 216
      Top = 152
      Width = 75
      Height = 25
      Caption = #22238#21407#40670
      TabOrder = 2
      OnClick = btnBackClick
    end
    object btnMove: TButton
      Left = 216
      Top = 192
      Width = 75
      Height = 25
      Caption = #30456#23565#20301#31227
      TabOrder = 3
      OnClick = btnMoveClick
    end
    object edtBaud: TEdit
      Left = 80
      Top = 99
      Width = 105
      Height = 21
      TabOrder = 4
      Text = '115200'
    end
    object btnCloseMa: TButton
      Left = 216
      Top = 112
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 5
      OnClick = btnCloseMaClick
    end
    object pnlAxis: TPanel
      Left = 304
      Top = 8
      Width = 929
      Height = 417
      Color = clSilver
      TabOrder = 6
    end
    object cmbModel: TComboBox
      Left = 80
      Top = 40
      Width = 105
      Height = 21
      ItemHeight = 13
      TabOrder = 7
      Text = '495'
      OnSelect = cmbModelSelect
    end
    object edtAllCount: TEdit
      Left = 80
      Top = 174
      Width = 89
      Height = 21
      TabOrder = 8
      Text = '25'
      OnChange = edtAllCountChange
    end
    object edtRowCount: TEdit
      Left = 80
      Top = 204
      Width = 89
      Height = 21
      TabOrder = 9
      Text = '2'
      OnChange = edtRowCountChange
    end
    object edtColCount: TEdit
      Left = 80
      Top = 276
      Width = 89
      Height = 21
      TabOrder = 10
      Text = '13'
    end
    object edtColInterval: TEdit
      Left = 80
      Top = 308
      Width = 89
      Height = 21
      TabOrder = 11
      Text = '0'
    end
    object btn1: TButton
      Left = 200
      Top = 280
      Width = 89
      Height = 25
      Caption = #29983#25104#24231#27161#31995
      TabOrder = 12
      OnClick = btn1Click
    end
    object btn2: TButton
      Left = 200
      Top = 344
      Width = 89
      Height = 25
      Caption = #20445#23384
      TabOrder = 13
    end
    object edtX: TEdit
      Left = 80
      Top = 340
      Width = 89
      Height = 21
      TabOrder = 14
      Text = '0'
    end
    object edtY: TEdit
      Left = 80
      Top = 372
      Width = 89
      Height = 21
      TabOrder = 15
      Text = '0'
    end
    object edtZ: TEdit
      Left = 80
      Top = 404
      Width = 89
      Height = 21
      TabOrder = 16
      Text = '0'
    end
    object cbbRowNo: TRzComboBox
      Left = 80
      Top = 240
      Width = 89
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 17
      OnSelect = cbbRowNoSelect
    end
    object edtSpeed: TEdit
      Left = 80
      Top = 128
      Width = 105
      Height = 21
      TabOrder = 18
      Text = '115200'
    end
  end
  object grdpnl2: TGradPanel
    Left = 8
    Top = 448
    Width = 1241
    Height = 89
    TabOrder = 1
    object lbl8: TLabel
      Left = 16
      Top = 16
      Width = 102
      Height = 13
      Caption = #25475#25551#27085#20018#21475#35373#32622'      '
      Transparent = True
    end
    object cmb1: TComboBox
      Left = 40
      Top = 40
      Width = 105
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'COM1'
      Items.Strings = (
        'COM1'
        'COM2'
        'COM3'
        'COM4'
        'COM5'
        'COM6')
    end
    object btnOpenScan: TButton
      Left = 432
      Top = 40
      Width = 75
      Height = 25
      Caption = 'Open'
      TabOrder = 1
    end
    object edt4: TEdit
      Left = 216
      Top = 40
      Width = 105
      Height = 21
      TabOrder = 2
      Text = '9600'
    end
    object btnCloseScan: TButton
      Left = 592
      Top = 40
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 3
      OnClick = btnCloseMaClick
    end
  end
end
