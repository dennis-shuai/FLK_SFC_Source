object LineDetail: TLineDetail
  Left = 385
  Top = 133
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
  object Chart1: TDBChart
    Left = 16
    Top = 24
    Width = 1217
    Height = 329
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    Gradient.EndColor = 14729624
    Gradient.StartColor = 16777088
    Gradient.Visible = True
    Title.Text.Strings = (
      'TDBChart')
    BottomAxis.ExactDateTime = False
    BottomAxis.LabelStyle = talValue
    LeftAxis.TickOnLabelsOnly = False
    Legend.LegendStyle = lsSeries
    Legend.Visible = False
    View3D = False
    TabOrder = 0
  end
  object Chart2: TDBChart
    Left = 16
    Top = 376
    Width = 1217
    Height = 329
    AnimatedZoomSteps = 13
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    Gradient.EndColor = 14729624
    Gradient.StartColor = 16777088
    Gradient.Visible = True
    Title.Text.Strings = (
      'TDBChart')
    BottomAxis.LabelsMultiLine = True
    BottomAxis.LabelStyle = talValue
    LeftAxis.GridCentered = True
    Legend.Inverted = True
    Legend.ResizeChart = False
    Legend.TextStyle = ltsPlain
    Legend.Visible = False
    RightAxis.Labels = False
    View3D = False
    View3DWalls = False
    BevelOuter = bvNone
    Color = 8453888
    TabOrder = 1
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    RemoteServer = uMainForm.SocketConnection1
    Left = 268
    Top = 27
  end
end
