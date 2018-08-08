object formProject: TformProject
  Left = 192
  Top = 114
  Width = 640
  Height = 520
  Caption = 'Shift Setup'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object MainMenu1: TMainMenu
    Left = 584
    Top = 40
    object ChangeShift1: TMenuItem
      Caption = 'Change Shift'
      OnClick = ChangeShift1Click
    end
  end
end
