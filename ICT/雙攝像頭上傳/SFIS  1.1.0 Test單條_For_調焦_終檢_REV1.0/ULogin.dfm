object FrmLogin: TFrmLogin
  Left = 369
  Top = 355
  Width = 543
  Height = 267
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'SFIS 1.0.9'
  Color = clSilver
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 33
    Width = 535
    Height = 200
    Align = alTop
    BevelInner = bvLowered
    Color = 15198183
    TabOrder = 0
    object Label4: TLabel
      Left = 19
      Top = 67
      Width = 75
      Height = 16
      Caption = #28204#35430#31449#21029#65306'     '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 10485760
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 18
      Top = 102
      Width = 81
      Height = 16
      Caption = #28204#35430#35352#37636#65306'       '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 10485760
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label9: TLabel
      Left = 281
      Top = 67
      Width = 75
      Height = 16
      Caption = #29128#31665#32232#34399#65306'     '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 10485760
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label7: TLabel
      Left = 19
      Top = 35
      Width = 75
      Height = 16
      Caption = #27231#31278#21517#31281#65306'     '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 10485760
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label8: TLabel
      Left = 282
      Top = 35
      Width = 75
      Height = 16
      Caption = #27231#31278#39006#21029#65306'     '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 10485760
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Ed_WoQty: TEdit
      Left = 360
      Top = 33
      Width = 146
      Height = 21
      CharCase = ecUpperCase
      Color = 15198183
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3026478
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #26234#33021#38515#27211#36664#20837#24179#21488'  5.2'
      ParentFont = False
      ReadOnly = True
      TabOrder = 2
    end
    object Ed_WorkOrder: TEdit
      Left = 103
      Top = 33
      Width = 146
      Height = 21
      CharCase = ecUpperCase
      Color = 15198183
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3026478
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #26234#33021#38515#27211#36664#20837#24179#21488'  5.2'
      ParentFont = False
      ReadOnly = True
      TabOrder = 6
    end
    object Ed_FilePath: TEdit
      Left = 103
      Top = 100
      Width = 403
      Height = 21
      CharCase = ecUpperCase
      Color = 15198183
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3026478
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #26234#33021#38515#27211#36664#20837#24179#21488'  5.2'
      ParentFont = False
      ReadOnly = True
      TabOrder = 3
    end
    object Cmd_Start: TBitBtn
      Left = 129
      Top = 140
      Width = 96
      Height = 30
      Cursor = crHandPoint
      Caption = ' '#38283' '#22987
      DragCursor = crHandPoint
      DragKind = dkDock
      TabOrder = 4
      OnClick = Cmd_StartClick
      Glyph.Data = {
        E6040000424DE604000000000000360000002800000013000000140000000100
        180000000000B004000000000000000000000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFCFEFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFEFEFFFFFD
        FFFFF8FCFFEAEAEDCECBCDB6B1A8ABA490A39A91AEA7A1B9BDBAD5D9E1F4F4F8
        FDFFFFF9FEFFEEFDFFF6FCFCFFFFFF000000FFFFFFFFFFFEFEFFFFEDF1F3C8C3
        BAB09574AB8845BA9438C19131CE9E349B7E2D927245897F6E9E9D9FBBC2C8B6
        CCD2A7D1D9A4C4CCFFFFFF000000FFFFFFFEFFFFEAEAECBCA48DA87635B17413
        CCA55FF4E6C9BBA780E7AE44B1864AAF7C25A26E298D61388A7060978783BCAD
        A894928CFEFEFF000000FFFFFFF3F6F9B596839E5A20B26E24B67920CDB283FF
        FFFFB1B2A2A8781AA07E59AB793EB2762D9E69308E613C8D7569BAB4B0AB9A90
        FBF9FB000000FFFFFFC8B8B17C3D109A5420A7703B9E6720AF8C58F8F7F3EED5
        C820798E4A83B1517F987770548E6D4589654278563C91918EB7BFC2FEFDFE00
        0000FFFFFF6B39157F3F0F8D572F85552D80511F885821E5D9CAFFFFF8009AE4
        0CB1FF1293F448779F8B623E9C62338945197D5D4CC9C9CFFFFFFF000000E3DE
        DB3B0000874F2A8C502C945627966529996516D2BFA1FFFFFF28A3C50AD8FF09
        ACFF3B7FC1834E2F994F1C8B481C6735139B9899FEFFFF0000009F8275511700
        7443278A4D29A6692CB1823BC9A861A38662FFFFFFBCBBC13DFFFF1CFFFF13C8
        ED645853884511874F24591900817271F6FBFC0000005936266C3A186739237F
        4B27A87235B98F4EEBD39E93774DF3F3EBFFFFFF00121A34072A315F9B61688D
        81401E7F4421551C00644F49F1F5F60000003111006F3B2659301E683F1DB381
        34DBB064E6D2A1FFFFFF000000FFFFFFBEC7AF31F0A144914D413A04602F136A
        41264E2100543B2FEEF2F50000003218045D34175D351B4E261A422733745E4E
        A284614A5353000000D0FEF5FFFFFF2BA2832DCC8D418A564F371C623319390D
        005A483FF6F9FC000000655443300F00553312502F212D389B0039D80041AA00
        C3FF20C3FF183B05F1FFFFB1CCC320935D347C42433F20542D171E00007C6D72
        FFFFFF000000BFBAB00000004E2D1762462C807AA4315CEE187AFB1997EE10D6
        FF1E000050FFC9D1CECD6697751F64273647243D2211240200A3A0A1FFFFFF00
        0000FEFEFE1100003F1F0D65513CA8A1AA7073D73A4FD23B6AD4369BFF3C224D
        58CA788E928EBEB8B5475A3A383C202F1708533B2AD5D7D5FFFFFF000000FFFF
        FF897B7027080059402FA8A198DBDBF2BFC0E8BAC1E3B7C6F2C2BFDAC1CBB5BF
        B8B7E9E4E7A49A95483121391E0C9B938DF9FAFAFFFFFF000000FFFFFFECEAE8
        665246412517988C82C8C1BBB4A89EB2A59AB5A69BB7AAA3B3A2A1B0A29DBBB3
        AF9A8D85462D1B7D695EE6E5E4FFFFFFFFFFFF000000FFFFFFFFFFFFDCD9D56E
        5C524B312687716B93807C806B6975635D74645D837270968581796358452C19
        7F6E64E1DEDEFFFFFFFDFCFDFFFFFF000000FFFFFFFDFDFFFFFFFFEDECEA9A8C
        853616093B190D846861A68E88A68F8B7359522809003C271CB3ABA5F4F3F3FF
        FFFFFFFFFFFCFCFDFFFFFF000000FFFFFFFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF
        E0DBD791827A6659496255449F9386ECEBEDFFFFFFFFFFFFFFFFFFFFFFFFFEFE
        FFFFFFFFFFFFFF000000}
    end
    object Ed_TestStation: TEdit
      Left = 103
      Top = 65
      Width = 90
      Height = 21
      CharCase = ecUpperCase
      Color = 15198183
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3026478
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #26234#33021#38515#27211#36664#20837#24179#21488'  5.2'
      ParentFont = False
      ReadOnly = True
      TabOrder = 5
      OnChange = Ed_TestStationChange
    end
    object Ed_StationCode: TEdit
      Left = 198
      Top = 65
      Width = 51
      Height = 21
      Color = 15198183
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3026478
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #26234#33021#38515#27211#36664#20837#24179#21488'  5.2'
      ParentFont = False
      ReadOnly = True
      TabOrder = 7
    end
    object Ed_LightBoxNo: TEdit
      Left = 360
      Top = 65
      Width = 146
      Height = 21
      CharCase = ecUpperCase
      Color = 15198183
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3026478
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #26234#33021#38515#27211#36664#20837#24179#21488'  5.2'
      MaxLength = 3
      OEMConvert = True
      ParentFont = False
      ReadOnly = True
      TabOrder = 8
      OnChange = Ed_LightBoxNoChange
    end
    object Cmd_Exit: TBitBtn
      Left = 276
      Top = 140
      Width = 96
      Height = 30
      Caption = #36864#20986
      TabOrder = 9
      OnClick = Cmd_ExitClick
      Glyph.Data = {
        EE000000424DEE000000000000007600000028000000100000000F0000000100
        0400000000007800000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00F8F8F8F8F8F8
        F8F88F8F0F8F8F8F8F8FF8F00800F8F8F8F88F0E0F8F0F8F8F8F000E00000000
        F8F880EE07770F8F8F8FF0EE077708F8F8F880EE07770F8F0F8FF0EE077708F0
        08F880EE07770F00000FF0EE077708F008F880EE07770F8F0F8FF000777708F8
        F8F8800777770F8F8F8FF000000008F8F8F8}
    end
    object Ed_Model: TEdit
      Left = 103
      Top = 32
      Width = 146
      Height = 21
      CharCase = ecUpperCase
      Color = 15198183
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3026478
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #26234#33021#38515#27211#36664#20837#24179#21488'  5.2'
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
      OnChange = Ed_ModelChange
    end
    object Ed_Type: TEdit
      Left = 360
      Top = 32
      Width = 146
      Height = 21
      CharCase = ecUpperCase
      Color = 15198183
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3026478
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #26234#33021#38515#27211#36664#20837#24179#21488'  5.2'
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
    end
  end
  object PL_Computer: TPanel
    Left = 0
    Top = 0
    Width = 535
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    Color = clSkyBlue
    Font.Charset = ANSI_CHARSET
    Font.Color = clNavy
    Font.Height = -19
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
  end
  object ADOQ_LineStation: TADOQuery
    Connection = DmWorkOrder.ADOConnFoxSystemTest
    Parameters = <>
    Left = 5
    Top = 4
  end
  object tmr_start: TTimer
    Interval = 10000
    OnTimer = tmr_startTimer
    Left = 216
    Top = 8
  end
end
