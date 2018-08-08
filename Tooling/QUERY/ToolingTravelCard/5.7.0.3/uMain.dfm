object fMain: TfMain
  Left = 221
  Top = 109
  BorderStyle = bsNone
  ClientHeight = 553
  ClientWidth = 1003
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
    Width = 1003
    Height = 553
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    object Imageall: TImage
      Left = 0
      Top = 0
      Width = 1003
      Height = 265
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
    object TLabel
      Left = 232
      Top = 40
      Width = 3
      Height = 13
    end
    object Label2: TLabel
      Left = 24
      Top = 24
      Width = 71
      Height = 13
      Caption = 'Tooling_SN:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label3: TLabel
      Left = 24
      Top = 56
      Width = 82
      Height = 13
      Caption = 'Tooling_Type:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label4: TLabel
      Left = 24
      Top = 88
      Width = 86
      Height = 13
      Caption = 'Tooling_Name:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label5: TLabel
      Left = 24
      Top = 152
      Width = 104
      Height = 13
      Caption = 'Max_Used_Count:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label6: TLabel
      Left = 24
      Top = 120
      Width = 70
      Height = 13
      Caption = 'Tooling_No:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label7: TLabel
      Left = 488
      Top = 24
      Width = 74
      Height = 13
      Caption = 'Used_Count:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label8: TLabel
      Left = 488
      Top = 56
      Width = 90
      Height = 13
      Caption = 'Tooling_Status:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label11: TLabel
      Left = 256
      Top = 24
      Width = 76
      Height = 13
      Caption = 'Machine_No:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label12: TLabel
      Left = 256
      Top = 56
      Width = 59
      Height = 13
      Caption = 'Asset_No:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label13: TLabel
      Left = 256
      Top = 88
      Width = 45
      Height = 13
      Caption = 'Keeper:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label14: TLabel
      Left = 256
      Top = 120
      Width = 81
      Height = 13
      Caption = 'Monitor_Dept:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label15: TLabel
      Left = 256
      Top = 152
      Width = 105
      Height = 13
      Caption = 'Last_Revise_time:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label9: TLabel
      Left = 256
      Top = 184
      Width = 77
      Height = 13
      Caption = 'Used_Status:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label16: TLabel
      Left = 24
      Top = 184
      Width = 44
      Height = 13
      Caption = 'Locate:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Editsn: TEdit
      Left = 112
      Top = 24
      Width = 121
      Height = 21
      Color = 8454143
      TabOrder = 0
      Text = 'Editsn'
      OnKeyDown = EditsnKeyDown
    end
    object Edittoolingtype: TEdit
      Left = 112
      Top = 56
      Width = 121
      Height = 21
      ReadOnly = True
      TabOrder = 1
      Text = 'Edittoolingtype'
    end
    object Edittoolingname: TEdit
      Left = 112
      Top = 88
      Width = 121
      Height = 21
      ReadOnly = True
      TabOrder = 2
      Text = 'Edittoolingname'
    end
    object Editmaxusedcount: TEdit
      Left = 128
      Top = 152
      Width = 105
      Height = 21
      ReadOnly = True
      TabOrder = 3
      Text = 'Editmaxusedcount'
    end
    object Edittoolingno: TEdit
      Left = 112
      Top = 120
      Width = 121
      Height = 21
      ReadOnly = True
      TabOrder = 4
      Text = 'Edittoolingno'
    end
    object Editusedcount: TEdit
      Left = 576
      Top = 24
      Width = 121
      Height = 21
      ReadOnly = True
      TabOrder = 5
      Text = 'Editusedcount'
    end
    object Edittoolingstatus: TEdit
      Left = 576
      Top = 56
      Width = 121
      Height = 21
      ReadOnly = True
      TabOrder = 6
      Text = 'Edittoolingstatus'
    end
    object Editmachineno: TEdit
      Left = 344
      Top = 24
      Width = 121
      Height = 21
      Color = clYellow
      TabOrder = 7
      Text = 'Editmachineno'
      OnKeyDown = EditmachinenoKeyDown
    end
    object Editassetno: TEdit
      Left = 344
      Top = 56
      Width = 121
      Height = 21
      Color = clYellow
      TabOrder = 8
      Text = 'Editassetno'
      OnKeyDown = EditassetnoKeyDown
    end
    object Editkeeper: TEdit
      Left = 344
      Top = 88
      Width = 121
      Height = 21
      ReadOnly = True
      TabOrder = 9
      Text = 'Editkeeper'
    end
    object Editmonitordept: TEdit
      Left = 344
      Top = 120
      Width = 121
      Height = 21
      ReadOnly = True
      TabOrder = 10
      Text = 'Editmonitordept'
    end
    object Editlastrevisetime: TEdit
      Left = 360
      Top = 152
      Width = 105
      Height = 21
      ReadOnly = True
      TabOrder = 11
      Text = 'Editlastrevisetime'
    end
    object Editusedstatus: TEdit
      Left = 344
      Top = 184
      Width = 121
      Height = 21
      TabOrder = 12
      Text = 'Editusedstatus'
    end
    object Panel2: TPanel
      Left = 0
      Top = 521
      Width = 1003
      Height = 32
      Align = alBottom
      Caption = 'Tooling TravelCard'
      TabOrder = 13
    end
    object Editlocate: TEdit
      Left = 112
      Top = 184
      Width = 121
      Height = 21
      ReadOnly = True
      TabOrder = 14
      Text = 'Editlocate'
    end
    object PCTravelCard: TPageControl
      Left = 0
      Top = 202
      Width = 1003
      Height = 319
      ActivePage = Material
      Align = alBottom
      TabOrder = 15
      object Material: TTabSheet
        Caption = 'Material'
        OnShow = MaterialShow
        object StringGridmaterial: TStringGrid
          Left = 0
          Top = 0
          Width = 995
          Height = 291
          Align = alClient
          FixedCols = 0
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowSelect]
          TabOrder = 0
        end
      end
      object Sn_Status: TTabSheet
        Caption = 'Sn_Status'
        ImageIndex = 1
        OnShow = Sn_StatusShow
        object StringGridsnstatus: TStringGrid
          Left = 0
          Top = 0
          Width = 769
          Height = 291
          Align = alClient
          FixedCols = 0
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowSelect]
          TabOrder = 0
        end
      end
      object Matain: TTabSheet
        Caption = 'Matain'
        ImageIndex = 2
        OnShow = MatainShow
        object StringGridmatain: TStringGrid
          Left = 0
          Top = 0
          Width = 769
          Height = 297
          Align = alClient
          FixedCols = 0
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowSelect]
          TabOrder = 0
        end
      end
      object Revise: TTabSheet
        Caption = 'Revise'
        ImageIndex = 3
        OnShow = ReviseShow
        object StringGridrevise: TStringGrid
          Left = 0
          Top = 0
          Width = 769
          Height = 291
          Align = alClient
          FixedCols = 0
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowSelect]
          TabOrder = 0
        end
      end
    end
  end
  object QryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 688
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 712
  end
  object qryReel: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 656
  end
end
