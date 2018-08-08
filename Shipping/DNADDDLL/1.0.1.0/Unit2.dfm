object Form2: TForm2
  Left = 576
  Top = 381
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
    Height = 412
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
      ImeName = #20013#25991'(?'#20307') - 2345'#29579#29260#25340#38899'?'#20837#27861
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      OnCellClick = dbgrd1CellClick
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
      ImeName = #20013#25991'(?'#20307') - 2345'#29579#29260#25340#38899'?'#20837#27861
      ParentFont = False
      TabOrder = 1
      OnChange = edt1Change
    end
  end
  object ds1: TDataSource
  end
end
