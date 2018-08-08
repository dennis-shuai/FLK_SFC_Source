object ModelDetail: TModelDetail
  Left = 291
  Top = 172
  Width = 1285
  Height = 755
  Caption = 'Model Detail'
  Color = clBtnHighlight
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
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
    BottomAxis.LabelStyle = talValue
    Legend.Visible = False
    View3D = False
    TabOrder = 0
  end
  object Chart2: TDBChart
    Left = 16
    Top = 376
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
