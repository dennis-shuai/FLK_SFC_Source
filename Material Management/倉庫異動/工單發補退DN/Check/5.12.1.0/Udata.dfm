object FData: TFData
  Left = 333
  Top = 142
  Width = 499
  Height = 480
  BorderIcons = [biSystemMenu]
  Caption = 'FData'
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
  object Panelalias: TPanel
    Left = 0
    Top = 0
    Width = 491
    Height = 446
    Align = alClient
    Color = clLime
    TabOrder = 0
    object label1: TLabel
      Left = 16
      Top = 8
      Width = 44
      Height = 16
      Caption = 'label1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Editalias: TEdit
      Left = 104
      Top = 8
      Width = 273
      Height = 21
      TabOrder = 0
    end
    object Sgalias: TStringGrid
      Left = 1
      Top = 40
      Width = 489
      Height = 405
      Align = alBottom
      ColCount = 1
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
      TabOrder = 1
      ColWidths = (
        459)
    end
  end
end
