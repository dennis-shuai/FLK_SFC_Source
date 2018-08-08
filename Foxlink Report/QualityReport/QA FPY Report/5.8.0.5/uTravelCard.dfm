object fTravelCard: TfTravelCard
  Left = 202
  Top = 128
  BorderStyle = bsSingle
  Caption = 'Travel Card'
  ClientHeight = 570
  ClientWidth = 760
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GradPanel1: TGradPanel
    Left = 0
    Top = 0
    Width = 760
    Height = 172
    Align = alTop
    TabOrder = 0
    BackGroundEffect = bdDown
    ColorStart = 14206402
    object Bevel1: TBevel
      Left = 1
      Top = 1
      Width = 758
      Height = 51
      Align = alTop
    end
    object Label1: TLabel
      Left = 9
      Top = 10
      Width = 80
      Height = 13
      Caption = 'Serial Number'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Bevel4: TBevel
      Left = 1
      Top = 52
      Width = 758
      Height = 118
      Align = alTop
    end
    object Label8: TLabel
      Left = 17
      Top = 59
      Width = 66
      Height = 13
      Caption = 'Work Order'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label9: TLabel
      Left = 17
      Top = 128
      Width = 44
      Height = 13
      Caption = 'Part No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label10: TLabel
      Left = 17
      Top = 151
      Width = 43
      Height = 13
      Caption = 'Version'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label11: TLabel
      Left = 324
      Top = 59
      Width = 71
      Height = 13
      Caption = 'Route Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label12: TLabel
      Left = 324
      Top = 82
      Width = 90
      Height = 13
      Caption = 'Production Line'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label18: TLabel
      Left = 17
      Top = 105
      Width = 108
      Height = 13
      Caption = 'Master Work Order'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabWO: TLabel
      Left = 137
      Top = 59
      Width = 5
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabMasterWO: TLabel
      Left = 136
      Top = 105
      Width = 5
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabPN: TLabel
      Left = 136
      Top = 128
      Width = 5
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabVersion: TLabel
      Left = 136
      Top = 151
      Width = 5
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabRoute: TLabel
      Left = 425
      Top = 59
      Width = 5
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabLine: TLabel
      Left = 425
      Top = 82
      Width = 5
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 324
      Top = 10
      Width = 74
      Height = 13
      Caption = 'Customer SN'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label3: TLabel
      Left = 10
      Top = 32
      Width = 65
      Height = 13
      Caption = 'Keypart SN'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label4: TLabel
      Left = 324
      Top = 105
      Width = 30
      Height = 13
      Caption = 'Spec'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabSpec: TLabel
      Left = 425
      Top = 105
      Width = 5
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label5: TLabel
      Left = 324
      Top = 32
      Width = 44
      Height = 13
      Caption = 'Remark'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      Visible = False
    end
    object Label16: TLabel
      Left = 17
      Top = 82
      Width = 54
      Height = 13
      Caption = 'WO Type'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabWOType: TLabel
      Left = 137
      Top = 82
      Width = 5
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabRemark: TLabel
      Left = 369
      Top = 32
      Width = 5
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      Visible = False
    end
    object Label24: TLabel
      Left = 324
      Top = 151
      Width = 76
      Height = 13
      Caption = 'Next Process'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lablNextProcess: TLabel
      Left = 425
      Top = 151
      Width = 5
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label26: TLabel
      Left = 324
      Top = 128
      Width = 37
      Height = 13
      Caption = 'Status'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lablStatus: TLabel
      Left = 425
      Top = 128
      Width = 5
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object editSN: TEdit
      Left = 96
      Top = 5
      Width = 225
      Height = 21
      Color = clWhite
      TabOrder = 0
      OnKeyPress = editSNKeyPress
    end
    object editCSN: TEdit
      Left = 403
      Top = 5
      Width = 225
      Height = 21
      TabOrder = 1
      OnKeyPress = editCSNKeyPress
    end
    object editKPSN: TEdit
      Left = 96
      Top = 29
      Width = 225
      Height = 21
      TabOrder = 2
      OnKeyPress = editKPSNKeyPress
    end
  end
  object GradPanel5: TGradPanel
    Left = 0
    Top = 543
    Width = 760
    Height = 27
    Align = alBottom
    BevelInner = bvRaised
    BevelOuter = bvNone
    TabOrder = 1
    BackGroundEffect = bdFlat
    ColorStart = 14206402
  end
  object GradPanel8: TGradPanel
    Left = 0
    Top = 172
    Width = 760
    Height = 112
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvNone
    TabOrder = 2
    BackGroundEffect = bdLeft
    ColorStart = 14206402
    object GradPanel7: TGradPanel
      Left = 313
      Top = 1
      Width = 446
      Height = 110
      Align = alClient
      BevelInner = bvRaised
      BevelOuter = bvNone
      BiDiMode = bdLeftToRight
      ParentBiDiMode = False
      TabOrder = 0
      ColorStart = 14206402
      object Bevel6: TBevel
        Left = 1
        Top = 1
        Width = 444
        Height = 24
        Align = alTop
      end
      object Label7: TLabel
        Left = 11
        Top = 7
        Width = 117
        Height = 13
        Caption = 'Shipping Information'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object Bevel3: TBevel
        Left = 1
        Top = 25
        Width = 444
        Height = 84
        Align = alClient
      end
      object Label13: TLabel
        Left = 153
        Top = 7
        Width = 46
        Height = 13
        Caption = 'Ship No'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        Visible = False
      end
      object Label14: TLabel
        Left = 17
        Top = 33
        Width = 53
        Height = 13
        Caption = 'Customer'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object Label15: TLabel
        Left = 17
        Top = 81
        Width = 45
        Height = 13
        Caption = 'Ship To'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object Label17: TLabel
        Left = 198
        Top = 33
        Width = 43
        Height = 13
        Caption = 'Vehicle'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object Label19: TLabel
        Left = 198
        Top = 57
        Width = 55
        Height = 13
        Caption = 'Container'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object Label20: TLabel
        Left = 17
        Top = 57
        Width = 78
        Height = 13
        Caption = 'Warranty Day'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object Label21: TLabel
        Left = 198
        Top = 81
        Width = 57
        Height = 13
        Caption = 'Ship Time'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object editCustomer: TEdit
        Left = 72
        Top = 29
        Width = 121
        Height = 21
        TabStop = False
        ReadOnly = True
        TabOrder = 0
      end
      object editWarranty: TEdit
        Left = 96
        Top = 53
        Width = 97
        Height = 21
        TabStop = False
        ReadOnly = True
        TabOrder = 1
      end
      object editShipto: TEdit
        Left = 64
        Top = 77
        Width = 129
        Height = 21
        TabStop = False
        ReadOnly = True
        TabOrder = 2
      end
      object editVehicle: TEdit
        Left = 256
        Top = 29
        Width = 163
        Height = 21
        TabStop = False
        ReadOnly = True
        TabOrder = 3
      end
      object editContainer: TEdit
        Left = 256
        Top = 53
        Width = 163
        Height = 21
        TabStop = False
        ReadOnly = True
        TabOrder = 4
      end
      object editShiptime: TEdit
        Left = 256
        Top = 77
        Width = 163
        Height = 21
        TabStop = False
        ReadOnly = True
        TabOrder = 5
      end
    end
    object GradPanel6: TGradPanel
      Left = 1
      Top = 1
      Width = 312
      Height = 110
      Align = alLeft
      BevelInner = bvRaised
      BevelOuter = bvNone
      TabOrder = 1
      ColorStart = 14206402
      object Bevel2: TBevel
        Left = 1
        Top = 1
        Width = 310
        Height = 24
        Align = alTop
      end
      object Label6: TLabel
        Left = 9
        Top = 7
        Width = 114
        Height = 13
        Caption = 'Packing Information'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object Bevel5: TBevel
        Left = 1
        Top = 25
        Width = 310
        Height = 84
        Align = alClient
      end
      object Label22: TLabel
        Left = 17
        Top = 57
        Width = 58
        Height = 13
        Caption = 'Carton No'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object Label23: TLabel
        Left = 17
        Top = 81
        Width = 53
        Height = 13
        Caption = 'Pallet No'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object Label25: TLabel
        Left = 17
        Top = 33
        Width = 42
        Height = 13
        Caption = 'Box No'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object editCarton: TEdit
        Left = 80
        Top = 53
        Width = 209
        Height = 21
        TabStop = False
        ReadOnly = True
        TabOrder = 0
      end
      object editPallet: TEdit
        Left = 80
        Top = 77
        Width = 209
        Height = 21
        TabStop = False
        ReadOnly = True
        TabOrder = 1
      end
      object editBox: TEdit
        Left = 80
        Top = 29
        Width = 209
        Height = 21
        TabStop = False
        ReadOnly = True
        TabOrder = 2
      end
    end
  end
  object tpTravel: TPageControl
    Left = 0
    Top = 284
    Width = 760
    Height = 259
    Align = alClient
    TabOrder = 3
    OnChange = tpTravelChange
  end
end
