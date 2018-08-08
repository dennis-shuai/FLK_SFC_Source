object fDetail: TfDetail
  Left = 196
  Top = 107
  BorderStyle = bsNone
  ClientHeight = 536
  ClientWidth = 644
  Color = clSilver
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 39
    Top = 5
    Width = 126
    Height = 16
    Caption = 'RT / Item Maintain'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label10: TLabel
    Left = 32
    Top = 6
    Width = 126
    Height = 16
    Caption = 'RT / Item Maintain'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 644
    Height = 536
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    object ImageAll: TImage
      Left = 0
      Top = 0
      Width = 644
      Height = 536
      Align = alClient
      ParentShowHint = False
      ShowHint = False
      Transparent = True
    end
    object LabTitle2: TLabel
      Left = 8
      Top = 6
      Width = 200
      Height = 16
      Caption = 'Work Order Abnormal Feed'
      Font.Charset = CHINESEBIG5_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabTitle1: TLabel
      Left = 7
      Top = 5
      Width = 200
      Height = 16
      Caption = 'Work Order Abnormal Feed'
      Font.Charset = CHINESEBIG5_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label7: TLabel
      Left = 11
      Top = 34
      Width = 80
      Height = 16
      Caption = 'Work Order'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object sbtnRT: TSpeedButton
      Left = 250
      Top = 31
      Width = 21
      Height = 21
      Flat = True
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000000000000000000000000000000000000000FF0000FF
        63494A5A595A8C8E8C0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF0000FF63494A7B719CAD86845A595A8C8E8C0000FF00
        00FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF63BEF7
        428EDE7B79A5AD86845A595A8C8E8C0000FF0000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF0000FF8496FF52B6FF428EDE7B79A5AD86845A595A8C
        8E8C0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF
        8496FF52B6FF428EDE7B79A5B586845A595A8C8E8C0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF0000FF0000FF0000FF8496FF52BEFF4279D67B79A5AD
        86846B616B6B616B6B616B6B616B6B616B8C8E8C0000FF0000FF0000FF0000FF
        0000FF0000FF8496FF52B6FF428EDE8C8E8C7B797BC69E84D6AE94E7CFB5D6B6
        A57371736B616B0000FF0000FF0000FF0000FF0000FF0000FF8496FF8496FFB5
        8684F7D7ADFFF7C6FFFFD6FFFFDEFFFFDEFFF7E7AD86846B616B0000FF0000FF
        0000FF0000FF0000FF0000FFD6AE94EFCFADFFF7BDFFF7C6FFFFDEFFFFEFFFFF
        FFFFFFFFF7EFCE7361630000FF0000FF0000FF0000FF0000FF0000FFD6B6A5FF
        F7C6FFE7B5FFFFC6FFFFDEFFFFEFFFFFFFFFFFF7FFFFDEC69E8C0000FF0000FF
        0000FF0000FF0000FF0000FFD6AE94FFF7CEFFDFADFFF7C6FFFFD6FFFFE7FFFF
        EFFFFFE7FFFFDED6AE940000FF0000FF0000FF0000FF0000FF0000FFD6B6A5FF
        F7C6FFE7BDFFEFBDFFFFCEFFFFD6FFFFDEFFFFDEFFFFD6D6AE940000FF0000FF
        0000FF0000FF0000FF0000FFD6B6A5FFF7CEFFF7D6FFE7B5FFF7BDFFF7C6FFFF
        C6FFF7C6FFFFC6B58E840000FF0000FF0000FF0000FF0000FF0000FFDEB69CEF
        E7C6FFFFFFFFFFEFFFEFBDFFDFADFFE7B5FFF7BDF7D7AD9C71730000FF0000FF
        0000FF0000FF0000FF0000FF0000FFD6B6A5F7EFCEFFFFEFFFF7CEFFEFBDFFF7
        C6FFD7A5BD968C0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00
        00FFD6B6A5D6B6A5CEA68CE7BEA5DEB69C8C8E8C0000FF0000FF}
      OnClick = sbtnRTClick
    end
    object Label12: TLabel
      Left = 51
      Top = 66
      Width = 40
      Height = 16
      Caption = 'ID No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lablMsg: TLabel
      Left = 19
      Top = 384
      Width = 5
      Height = 16
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 163
      Top = 482
      Width = 54
      Height = 16
      Caption = 'Display'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      Visible = False
    end
    object lablQty: TLabel
      Left = 360
      Top = 34
      Width = 5
      Height = 16
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clTeal
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label3: TLabel
      Left = 283
      Top = 34
      Width = 74
      Height = 16
      Caption = 'Target Qty'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label11: TLabel
      Left = 430
      Top = 34
      Width = 58
      Height = 16
      Caption = 'Pick Qty'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabPICK: TLabel
      Left = 493
      Top = 34
      Width = 5
      Height = 16
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clTeal
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label4: TLabel
      Left = 259
      Top = 10
      Width = 34
      Height = 16
      Caption = 'ORG'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object edtWo: TEdit
      Left = 96
      Top = 32
      Width = 153
      Height = 21
      Color = 8454143
      TabOrder = 0
      OnKeyPress = edtWoKeyPress
    end
    object DBGrid2: TDBGrid
      Left = 368
      Top = 88
      Width = 256
      Height = 305
      DataSource = DataSource1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      OnTitleClick = DBGrid2TitleClick
      Columns = <
        item
          Expanded = False
          FieldName = 'Part_No'
          Title.Caption = 'Part No'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'MS Sans Serif'
          Title.Font.Style = [fsBold]
          Width = 107
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Material_No'
          Title.Caption = 'ID No'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'MS Sans Serif'
          Title.Font.Style = [fsBold]
          Width = 108
          Visible = True
        end
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'qty'
          Title.Alignment = taCenter
          Title.Caption = 'Qty'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'MS Sans Serif'
          Title.Font.Style = [fsBold]
          Width = 76
          Visible = True
        end>
    end
    object edtMaterial: TEdit
      Left = 96
      Top = 64
      Width = 188
      Height = 21
      Color = 8454143
      Enabled = False
      TabOrder = 2
      OnKeyPress = edtMaterialKeyPress
    end
    object chkPush: TRzCheckBox
      Left = 448
      Top = 8
      Width = 97
      Height = 17
      Caption = 'Push Title'
      Checked = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ReadOnly = True
      State = cbChecked
      TabOrder = 3
      Transparent = True
      OnMouseDown = chkPushMouseDown
    end
    object combDisplay: TComboBox
      Left = 224
      Top = 480
      Width = 119
      Height = 23
      Style = csDropDownList
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Times New Roman'
      Font.Style = []
      ItemHeight = 15
      ItemIndex = 0
      ParentFont = False
      TabOrder = 4
      Text = 'ALL'
      Visible = False
      Items.Strings = (
        'ALL'
        'Unfinish'
        'Finish')
    end
    object DBGrid1: TDBGrid
      Left = 3
      Top = 88
      Width = 362
      Height = 305
      DataSource = DataSource2
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 5
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      OnTitleClick = DBGrid1TitleClick
      Columns = <
        item
          ButtonStyle = cbsNone
          Expanded = False
          FieldName = 'PART_NO'
          Title.Caption = 'Part No'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'MS Sans Serif'
          Title.Font.Style = [fsBold]
          Width = 106
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Request_Qty'
          Title.Caption = 'Request'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'MS Sans Serif'
          Title.Font.Style = [fsBold]
          Width = 55
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Issue_Qty'
          Title.Caption = 'Issue'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'MS Sans Serif'
          Title.Font.Style = [fsBold]
          Width = 57
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'qty'
          Title.Caption = 'Instock'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'MS Sans Serif'
          Title.Font.Style = [fsBold]
          Width = 54
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'over_request'
          Title.Caption = 'Over Request'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'MS Sans Serif'
          Title.Font.Style = [fsBold]
          Width = 83
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'AB_ISSUE'
          Title.Caption = 'Abnormal Pick'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'MS Sans Serif'
          Title.Font.Style = [fsBold]
          Width = 85
          Visible = True
        end>
    end
    object EditORG: TEdit
      Left = 304
      Top = 8
      Width = 121
      Height = 21
      ReadOnly = True
      TabOrder = 6
    end
  end
  object QryMaterial: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 464
    Top = 304
  end
  object DataSource1: TDataSource
    AutoEdit = False
    DataSet = QryMaterial
    Left = 408
    Top = 248
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 72
    Top = 168
  end
  object SaveDialog1: TSaveDialog
    Left = 72
    Top = 104
  end
  object QryDetail: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 168
    Top = 136
  end
  object DataSource2: TDataSource
    AutoEdit = False
    DataSet = QryDetail
    OnDataChange = DataSource2DataChange
    Left = 200
    Top = 136
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 104
    Top = 168
  end
end
