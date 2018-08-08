object fFilter: TfFilter
  Left = 312
  Top = 278
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Unfinish / Empty'
  ClientHeight = 309
  ClientWidth = 465
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid11: TStringGrid1
    Left = 0
    Top = 0
    Width = 465
    Height = 309
    Align = alClient
    Color = 8454143
    ColCount = 3
    DefaultColWidth = 10
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    TabOrder = 0
    OnDblClick = StringGrid11DblClick
    ColWidths = (
      10
      187
      152)
  end
end
