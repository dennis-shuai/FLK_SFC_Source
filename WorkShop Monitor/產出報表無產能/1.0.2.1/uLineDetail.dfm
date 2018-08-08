object LineDetail: TLineDetail
  Left = 346
  Top = 119
  Width = 1254
  Height = 751
  Caption = 'LineDetail'
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Chart2: TDBChart
    Left = 16
    Top = 368
    Width = 1217
    Height = 329
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    Gradient.EndColor = 14729624
    Gradient.StartColor = 16777088
    Gradient.Visible = True
    Title.Text.Strings = (
      'TDBChart')
    BottomAxis.LabelStyle = talValue
    Legend.Visible = False
    View3D = False
    TabOrder = 0
  end
  object Chart1: TDBChart
    Left = 16
    Top = 32
    Width = 1217
    Height = 329
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    Gradient.EndColor = 14729624
    Gradient.StartColor = 16777088
    Gradient.Visible = True
    Title.Text.Strings = (
      'TDBChart')
    BottomAxis.LabelStyle = talValue
    View3D = False
    TabOrder = 1
  end
end
