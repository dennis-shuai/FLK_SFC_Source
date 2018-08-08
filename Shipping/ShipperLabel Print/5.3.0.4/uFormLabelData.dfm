object FormLabelData: TFormLabelData
  Left = 443
  Top = 442
  Width = 526
  Height = 404
  Caption = 'LabelData'
  Color = clBtnFace
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
    Width = 518
    Height = 81
    Align = alTop
    TabOrder = 0
    object LabType1: TLabel
      Left = 32
      Top = 18
      Width = 102
      Height = 16
      Caption = 'SKU Label List'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lbl1: TLabel
      Left = 45
      Top = 43
      Width = 70
      Height = 13
      Caption = 'Search SKU'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabType2: TLabel
      Left = 31
      Top = 18
      Width = 102
      Height = 16
      Caption = 'SKU Label List'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object edtComm: TEdit
      Left = 123
      Top = 41
      Width = 193
      Height = 21
      CharCase = ecUpperCase
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnChange = edtCommChange
    end
  end
  object dbgrd1: TDBGrid
    Left = 0
    Top = 81
    Width = 518
    Height = 239
    Align = alClient
    DataSource = DataSource1
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = ANSI_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = [fsBold]
    OnCellClick = dbgrd1CellClick
    OnDblClick = dbgrd1DblClick
    Columns = <
      item
        Expanded = False
        FieldName = 'LABELFILE_ID'
        Title.Caption = 'LABEL_ID'
        Width = 86
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'LABEL_NAME'
        Width = 132
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'LABEL_FILE'
        Width = 79
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'LABEL_TYPE'
        Width = 110
        Visible = True
      end>
  end
  object pnl2: TPanel
    Left = 0
    Top = 320
    Width = 518
    Height = 50
    Align = alBottom
    TabOrder = 2
    object Button1: TButton
      Left = 336
      Top = 16
      Width = 75
      Height = 25
      Caption = 'OK'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 424
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Cancel'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = Button2Click
    end
  end
  object DataSource1: TDataSource
    Left = 72
    Top = 200
  end
end
