object formTrayIcon: TformTrayIcon
  Left = 307
  Top = 207
  Width = 217
  Height = 153
  Caption = 'formTrayIcon'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ppMenu: TPopupMenu
    Left = 48
    Top = 24
    object mmShow: TMenuItem
      Caption = 'Show'
      OnClick = mmShowClick
    end
    object mmClose: TMenuItem
      Caption = 'Close'
      OnClick = mmCloseClick
    end
  end
end
