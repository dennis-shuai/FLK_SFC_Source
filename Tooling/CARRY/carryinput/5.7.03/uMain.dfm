object fMain: TfMain
  Left = 389
  Top = 149
  BorderStyle = bsNone
  ClientHeight = 255
  ClientWidth = 506
  Color = clSilver
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 39
    Top = 5
    Width = 126
    Height = 16
    Caption = 'RT / Item Maintain'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label10: TLabel
    Left = 32
    Top = 6
    Width = 126
    Height = 16
    Caption = 'RT / Item Maintain'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 506
    Height = 255
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    object ImageAll: TImage
      Left = 0
      Top = 0
      Width = 506
      Height = 255
      Align = alClient
      Enabled = False
      ParentShowHint = False
      ShowHint = False
      Transparent = True
    end
    object LabTitle2: TLabel
      Left = 8
      Top = 6
      Width = 65
      Height = 16
      Caption = 'CARRY   '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabTitle1: TLabel
      Left = 7
      Top = 5
      Width = 65
      Height = 16
      Caption = 'CARRY   '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object labCnt: TLabel
      Left = 9
      Top = 508
      Width = 3
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object labcost: TLabel
      Left = 223
      Top = 508
      Width = 3
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 88
      Top = 88
      Width = 62
      Height = 13
      Caption = 'Carry LOT:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object TLabel
      Left = 232
      Top = 40
      Width = 3
      Height = 13
    end
    object Label5: TLabel
      Left = 160
      Top = 32
      Width = 199
      Height = 24
      Caption = 'CARRY INPUT'#12288#12288#12288
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblstatus: TLabel
      Left = 136
      Top = 136
      Width = 481
      Height = 16
      Caption = 'lblstatus'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object EditCarrySN: TEdit
      Left = 176
      Top = 88
      Width = 209
      Height = 21
      Color = clYellow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      Text = 'EditCarrySN'
      OnKeyDown = EditCarrySNKeyDown
    end
    object Editmonitordept: TEdit
      Left = 328
      Top = 24
      Width = 121
      Height = 21
      TabOrder = 1
      Text = 'Editmonitordept'
      Visible = False
    end
    object Edittoolingsn: TEdit
      Left = 328
      Top = 48
      Width = 121
      Height = 21
      Enabled = False
      TabOrder = 2
      Text = 'Edittoolingsn'
      Visible = False
    end
  end
  object QryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 688
  end
  object DataSource1: TDataSource
    AutoEdit = False
    DataSet = QryData
    Left = 600
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 712
  end
  object SaveDialog1: TSaveDialog
    Left = 664
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 736
  end
  object SaveDialog2: TSaveDialog
    Left = 568
  end
  object qryReel: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 632
  end
end
