object fDetail: TfDetail
  Left = 192
  Top = 113
  BorderStyle = bsNone
  ClientHeight = 717
  ClientWidth = 1400
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 1400
    Height = 717
    Align = alClient
    Color = clCaptionText
    TabOrder = 0
    object ImageAll: TImage
      Left = 1
      Top = 1
      Width = 1398
      Height = 715
      Align = alClient
      ParentShowHint = False
      ShowHint = False
      Transparent = True
    end
    object lblLabTitle2: TLabel
      Left = 32
      Top = 16
      Width = 180
      Height = 20
      AutoSize = False
      Caption = #26781#30908#25171#21360#26367#25563#35352#37636
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblLabTitle1: TLabel
      Left = 31
      Top = 15
      Width = 180
      Height = 20
      AutoSize = False
      Caption = #26781#30908#25171#21360#26367#25563#35352#37636
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label1: TLabel
      Left = 78
      Top = 67
      Width = 30
      Height = 20
      Caption = 'SN:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 74
      Top = 282
      Width = 5
      Height = 22
      Font.Charset = ANSI_CHARSET
      Font.Color = clNavy
      Font.Height = -19
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label3: TLabel
      Left = 79
      Top = 111
      Width = 162
      Height = 20
      AutoSize = False
      Caption = #25171#21360#35352#37636
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label4: TLabel
      Left = 79
      Top = 287
      Width = 162
      Height = 20
      AutoSize = False
      Caption = #26367#25563#35352#37636
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object edtSN: TEdit
      Left = 123
      Top = 63
      Width = 270
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      ParentFont = False
      TabOrder = 0
      OnKeyPress = edtSNKeyPress
    end
    object DBGrid1: TDBGrid
      Left = 88
      Top = 136
      Width = 617
      Height = 129
      DataSource = DataSource1
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = #24037#21934
          Width = 80
          Visible = True
        end
        item
          Expanded = False
          FieldName = #26781#30908
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = #24037#34399
          Width = 60
          Visible = True
        end
        item
          Expanded = False
          FieldName = #22995#21517
          Width = 60
          Visible = True
        end
        item
          Expanded = False
          FieldName = #25171#21360#26178#38291
          Width = 150
          Visible = True
        end>
    end
    object DBGrid2: TDBGrid
      Left = 88
      Top = 312
      Width = 617
      Height = 169
      DataSource = DataSource2
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = #24037#21934
          Width = 80
          Visible = True
        end
        item
          Expanded = False
          FieldName = #26781#30908
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = #23458#25142#26781#30908
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = #33290#26781#30908
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = #33290#23458#25142#26781#30908
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = #24037#34399
          Width = 60
          Visible = True
        end
        item
          Expanded = False
          FieldName = #22995#21517
          Width = 60
          Visible = True
        end
        item
          Expanded = False
          FieldName = #26367#25563#26178#38291
          Width = 150
          Visible = True
        end>
    end
  end
  object QryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 591
    Top = 30
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp'
    Left = 632
    Top = 26
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 690
    Top = 34
  end
  object DataSource1: TDataSource
    DataSet = QryData
    Left = 616
    Top = 80
  end
  object DataSource2: TDataSource
    DataSet = QryTemp
    Left = 664
    Top = 80
  end
end
