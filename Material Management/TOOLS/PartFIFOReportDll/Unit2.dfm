object Form2: TForm2
  Left = 548
  Top = 370
  Width = 417
  Height = 439
  Caption = 'Pallet Data'
  Color = clBtnFace
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
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 409
    Height = 405
    Align = alClient
    Color = clWhite
    TabOrder = 0
    object lbl1: TLabel
      Left = 16
      Top = 16
      Width = 26
      Height = 13
      Caption = 'WO:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object dbgrd1: TDBGrid
      Left = 0
      Top = 40
      Width = 409
      Height = 361
      Color = clWhite
      DataSource = ds1
      FixedColor = clSkyBlue
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      OnCellClick = dbgrd1CellClick
      Columns = <
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'PALLET_NO'
          Title.Alignment = taCenter
          Width = 150
          Visible = True
        end
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'QTY'
          Title.Alignment = taCenter
          Width = 80
          Visible = True
        end
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'STATUS'
          Title.Alignment = taCenter
          Width = 80
          Visible = True
        end>
    end
    object edt1: TEdit
      Left = 48
      Top = 8
      Width = 265
      Height = 21
      CharCase = ecUpperCase
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnKeyPress = edt1KeyPress
    end
  end
  object ds1: TDataSource
  end
end
