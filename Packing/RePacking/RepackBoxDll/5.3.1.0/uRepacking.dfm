object fRepacking: TfRepacking
  Left = 800
  Top = 194
  BorderStyle = bsNone
  ClientHeight = 511
  ClientWidth = 792
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 100
    Top = 64
    Width = 75
    Height = 13
    Caption = 'W/O Number'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label7: TLabel
    Left = 100
    Top = 168
    Width = 46
    Height = 13
    Caption = 'Process'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label9: TLabel
    Left = 100
    Top = 216
    Width = 33
    Height = 13
    Caption = 'Pallet'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label10: TLabel
    Left = 100
    Top = 264
    Width = 38
    Height = 13
    Caption = 'Carton'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 792
    Height = 511
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    object ImageAll: TImage
      Left = 0
      Top = 0
      Width = 792
      Height = 511
      Align = alClient
      ParentShowHint = False
      ShowHint = False
      Transparent = True
    end
    object LabTitle2: TLabel
      Left = 16
      Top = 8
      Width = 115
      Height = 16
      Caption = 'Repacking / Box'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabTitle1: TLabel
      Left = 15
      Top = 7
      Width = 115
      Height = 16
      Caption = 'Repacking / Box'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label3: TLabel
      Left = 65
      Top = 34
      Width = 51
      Height = 16
      Caption = 'Box No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label5: TLabel
      Left = 43
      Top = 62
      Width = 91
      Height = 16
      Caption = 'Customer SN'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object sbtnNewCarton: TSpeedButton
      Left = 412
      Top = 58
      Width = 23
      Height = 22
      Flat = True
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333303333
        333333333337FF3333333333330003333333333333777F333333333333080333
        3333333F33777FF33F3333B33B000B33B3333373F777773F7333333BBB0B0BBB
        33333337737F7F77F333333BBB0F0BBB33333337337373F73F3333BBB0F7F0BB
        B333337F3737F73F7F3333BB0FB7BF0BB3333F737F37F37F73FFBBBB0BF7FB0B
        BBB3773F7F37337F377333BB0FBFBF0BB333337F73F333737F3333BBB0FBF0BB
        B3333373F73FF7337333333BBB000BBB33333337FF777337F333333BBBBBBBBB
        3333333773FF3F773F3333B33BBBBB33B33333733773773373333333333B3333
        333333333337F33333333333333B333333333333333733333333}
      NumGlyphs = 2
      Visible = False
      OnClick = sbtnNewCartonClick
    end
    object Label19: TLabel
      Left = 13
      Top = 89
      Width = 59
      Height = 13
      Caption = 'CSN QTY:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lablQty: TLabel
      Left = 77
      Top = 89
      Width = 8
      Height = 13
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Image3: TImage
      Left = 411
      Top = 29
      Width = 104
      Height = 19
      Picture.Data = {
        07544269746D617026140000424D261400000000000036000000280000004D00
        0000160000000100180000000000F0130000120B0000120B0000000000000000
        0000B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3
        B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5
        B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8
        B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3
        B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5
        B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8
        B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3
        B8B5B3B8B5B3B8B5B300B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8
        B5B3B8B5B3B8B5B31515150D0D0D0D0D0D0D0D130D0D130D0D0D0D0D0D0D0D0D
        0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D
        0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D0D15151515151515151515151515
        1515151515151515151515151515151515151515151515151515151515151515
        1515151515151515151515151515151515151515151515151515151515151515
        15151515151515151515151515151515151515B8B5B3B8B5B3B8B5B3B8B5B3B8
        B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B300B8B5B3B8B5B3B8B5B3B8B5B3B8B5
        B3B8B5B3B8B5B3B8B5B3151515151515151515D0AA8ACBB7A9D7C5AAD7C5AAD7
        C5AAE1CFA6E1CFA6E1CFA6E1CFA6E1CFA6D7C5AAE1CFA6E1CFA6E1CFA6E1CFA6
        E1CFA6E1CFA6E1CFA6E1CFA6E1CFA6E1CFA6E1CFA6E1CFA6E1CFA6E1CFA6E1CF
        A6E1CFA6E1CFA6E1CFA6E1CFA6E1CFA6E1CFA6E1CFA6E1CFA6E1CFA6E1CFA6E1
        CFA6E2CFA6E2CFA6E2CFA6E2CFA6E2CFA6E2D0A6E2D0A6E2D0A6E2CFA6E2CEA5
        E1CDA5E1CCA4E0CBA3DFCAA3DFC9A2DFC9A2DFC9A2D0AA8A1515151515151515
        15B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B300B8B5B3B8B5B3
        B8B5B3B8B5B3B8B5B3B8B5B3151515161618151515D0AA8AD0AA8AD0AA8AE7D7
        AAEBE0B6EBE0B6EBE0B6EBE0B6EBE0B6EBE0B6EBE0B6EBE0B6EBE0B6EBE0B6EB
        E0B6EBE0B6EBE0B6EBE0B6EBE0B6EBE0B6EBE0B6EBE0B6EBE0B6EBE0B6EBE0B6
        EBE0B6EBE1B7EBE1B7ECE1B7ECE2B8ECE2B8ECE2B9ECE2B9EDE3B9EDE3BAEDE3
        BAEDE3BAEDE4BAEDE4BAEEE4BBEEE5BBEEE5BBEEE5BBEEE5BCEEE5BCEFE6BCEF
        E6BDEFE6BDEFE6BDF0E7BEF0E7BEF0E7BFF1E8BFF1E8BFF1E8BFF1E8BFD0AA8A
        D0AA8AD0AA8A151515161618151515B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5
        B300B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3151515151515D0AA8AC5A78AE3CA94
        EAD9AAF0E5BAF8EEC5FAF3CDFAF3CDFAF3CDFAF3CDFAF3CDFAF3CDFAF3CDFAF3
        CDFAF3CDFAF3CDFAF3CDFAF3CDFAF3CDFAF3CDFAF3CDFAF3CDFAF3CDFAF3CDFA
        F3CDFAF3CDFAF3CDFAF3CDFAF3CDFAF3CDFAF4CEFAF4CEFAF4CEFAF4CFFAF4CF
        FAF5CFFBF5CFFBF5D0FBF5D0FBF5D0FCF5D1FCF6D1FCF6D1FCF6D1FCF6D1FCF6
        D1FCF6D1FCF7D2FCF7D2FCF7D2FCF7D2FCF7D3FDF8D3FDF8D3FDF8D4FDF8D4FD
        F8D4FDF8D4F0E5BAEAD9AAE3CA94C5A78AD0AA8A151515151515B8B5B3B8B5B3
        B8B5B3B8B5B3B8B5B300B8B5B3B8B5B3B8B5B3B8B5B3151515151515C39C6DD9
        B885E6CF96EBDAA5F4E4B7F9EDC4FEF4CDFFF9D7FFF9D7FFF9D7FFF9D7FFF9D7
        FFF9D7FFF9D7FFF9D7FFF9D7FFF9D7FFF9D7FFF9D7FFF9D7FFF9D7FFF9D7FFF9
        D7FFF9D7FFF9D7FFF9D7FFF9D7FFF9D7FFF9D7FFF9D7FFF9D7FFF9D8FFF9D8FF
        F9D8FFF9D8FFF9D8FFFAD9FFFAD9FFFAD9FFFAD9FFFAD9FFFAD9FEFADAFEFADA
        FEFADAFEFADAFEFADAFEFADAFEFADBFEFADBFEFADBFEFADBFEFADBFEFBDCFEFB
        DCFEFBDCFEFBDCFEFBDCFEFBDCF9EDC4F4E4B7EBDAA5E6CF96D9B885C39C6D15
        1515151515B8B5B3B8B5B3B8B5B3B8B5B300B8B5B3B8B5B3B8B5B31515151515
        15C99962D7B379E3C68AEED799F3E0A9F7E7BAFBF1C4FFF7CDFEFAD4FEFAD4FE
        FAD4FEFAD4FEFAD4FEFAD4FEFAD4FEFAD4FEFAD4FEFAD4FEFAD4FEFAD4FEFAD4
        FEFAD4FEFAD4FEFAD4FEFAD4FEFAD4FEFAD4FEFAD4FEFAD4FEFAD4FEFAD4FEFA
        D5FEFAD5FEFAD5FEFAD5FEFAD5FEFAD5FEFAD5FEFAD5FEFAD5FEFAD5FEFAD5FE
        FAD5FEFAD6FEFAD6FEFAD6FEFAD6FEFAD6FEFAD6FDFAD6FDFAD6FDFAD6FDFAD6
        FDFAD6FDFAD7FDFAD7FDFAD7FDFAD7FDFAD7FDFAD7FBF1C4F7E7BAF3E0A9EED7
        99E3C68AD7B379C99962151515151515B8B5B3B8B5B3B8B5B300B8B5B3B8B5B3
        151515151515C38858D4A46CDBB87AE8C789F2D599F8DEA3FBE6ADF9EDBAFCF1
        C1FCF4C6FCF4C6FCF4C6FCF4C6FCF4C6FCF4C6FCF4C6FCF4C6FCF4C6FCF4C6FC
        F4C6FCF4C6FCF4C6FCF4C6FCF4C6FCF4C6FCF4C6FCF4C6FCF4C6FCF4C6FCF4C6
        FCF4C6FCF4C6FCF4C7FCF4C7FCF4C7FCF4C7FCF4C7FCF4C7FCF4C7FCF4C7FCF4
        C7FCF4C7FCF4C7FCF4C7FBF4C8FBF4C8FBF4C8FBF4C8FBF4C8FBF4C8FBF4C8FB
        F4C8FBF4C8FBF4C8FBF4C8FBF4C9FBF4C9FBF4C9FBF4C9FBF4C9FBF4C9F9EDBA
        FBE6ADF8DEA3F2D599E8C789DBB87AD4A46CC38858151515151515B8B5B3B8B5
        B300B8B5B3272727151515D0AA8AC98C52D7A467E3B26FECBF7DF3CA8AF7D292
        FBDC9AFEE1A2FFE6A6FFE7ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7
        ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7ACFF
        E7ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7ACFFE7AC
        FFE7ADFFE7ADFFE7ADFFE7ADFFE7ADFFE7ADFFE7ADFFE7ADFFE7ADFFE7ADFFE7
        ADFFE7ADFEE7ADFEE7ADFEE7ADFEE7ADFEE7ADFEE7ADFEE7ADFEE7ADFEE7ADFE
        E7ADFEE7ADFEE1A2FBDC9AF7D292F3CA8AECBF7DE3B26FD7A467C98C52D0AA8A
        151515151515B8B5B300B8B5B32F2F35C08E67B97844CA8B4DD39B5AE0A663E7
        B06BEFBB76F4C27DF9CA83FDD087FED28BFDD38EFDD38EFDD38EFDD38EFDD38E
        FDD38EFDD38EFDD38EFDD38EFDD38EFDD38EFDD38EFDD38EFDD38EFDD38EFDD3
        8EFDD38EFDD38EFDD38EFDD38EFDD38EFDD38EFDD38EFDD38EFDD38EFDD38EFD
        D38EFDD38EFDD38EFDD38EFDD38EFDD38EFDD38EFDD38EFDD38EFDD38EFDD38E
        FDD38EFDD38EFDD38EFDD38EFDD48FFDD48FFDD48FFDD48FFDD48FFDD48FFDD4
        8FFDD48FFDD48FFDD48FFDD48FFDD087F9CA83F4C27DEFBB76E7B06BE0A663D3
        9B5ACA8B4DB97844C08E67151515B8B5B300B8B5B3292935C08E67B46F3CC97E
        46D38B4BDA9452E69E5AEEA661F4AC64F8B168FAB769FCB86CFEBA6EFEBA6EFE
        BA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6E
        FEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA
        6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFE
        BA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBA6EFEBB6EFEBB6EFEBB6EFEBB6E
        FEBB6EFEBB6EFEBB6EFEBB6EFEBB6EFEBB6EFEBB6EFAB769F8B168F4AC64EEA6
        61E69E5ADA9452D38B4BC97E46B46F3CC08E67151515B8B5B300B8B5B327262F
        C08E67AE6834C1743BCD7C3FD68444E08C46E6924AED9B52F5A259F9A65BFCA7
        5DFDA95FFDA95FFDA95FFDA95FFDA95FFDA95FFDA95FFDA95FFDA95FFDA95FFD
        A95FFDA95FFDA95FFDA95FFDA95FFDA95FFDA95FFDA95FFDA95FFDA95FFDA95F
        FDA95FFDA95FFDA95FFDA95FFDA95FFDA95FFDA95FFDA95FFDA95FFDA95FFDA9
        5FFDA95FFDA95FFDA95FFDA960FDA960FDA960FDA960FDA960FDA960FDAA60FD
        AA60FDAA60FDAA60FDAA60FDAA60FDAA60FDAA60FDAA60FDAA60FDAA60F9A65B
        F5A259ED9B52E6924AE08C46D68444CD7C3FC1743BAE6834C08E67151515B8B5
        B300B8B5B3282729C08E67A74204B8662FC77439D27A38D77D3BE6914EEF9C5A
        F5A060F7A362FBA563FDA764FDA764FDA764FDA764FDA764FDA764FDA764FDA7
        64FDA764FDA764FDA764FDA764FDA764FDA764FDA764FDA764FDA764FDA764FD
        A764FDA764FDA764FDA764FDA764FDA764FDA764FDA764FDA764FDA764FDA764
        FEA764FEA764FEA764FEA764FEA764FEA764FEA764FEA764FEA764FEA764FEA7
        64FEA764FEA764FEA764FEA764FEA764FEA764FFA864FFA864FFA864FFA864FF
        A864FFA864F7A362F5A060EF9C5AE6914ED77D3BD27A38C77439B8662FA74204
        C08E67151515B8B5B300B8B5B3262625151515D0AA8AAE541FBC682BC66A2ADB
        854BE9A270EBA274F3A774F6A975F8AB76FBAD77FBAD77FBAD77FBAD77FBAD77
        FBAD77FBAD77FBAD77FBAD77FBAD77FBAD77FBAD77FBAD77FBAD77FBAD77FBAD
        77FBAD77FBAD77FBAD77FBAD77FBAD77FBAD77FBAD77FBAD77FBAD77FBAD77FB
        AD77FBAD77FBAD77FCAE77FCAE77FCAE77FCAE77FCAE77FCAE77FCAE76FCAE76
        FCAE76FCAE76FCAE76FCAE76FCAE76FCAE76FCAE76FCAE76FCAE76FDAF76FDAF
        76FDAF76FDAF76FDAF76FDAF76F6A975F3A774EBA274E9A270DB854BC66A2ABC
        682BAE541FD0AA8A151515151515B8B5B300B8B5B3B8B5B3151515151515D0AA
        8AAC5012B55D18DB9865E8B898E6B48FF4B88FF2B991F4BA92F7BB92F7BB92F7
        BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92
        F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB
        92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7
        BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92F7BB92
        F7BB92F8BB92F8BB92F8BB92F8BB92F8BB92F8BB92F2B991F4B88FE6B48FE8B8
        98DB9865B55D18AC5012D0AA8A151515151515B8B5B3B8B5B300B8B5B3B8B5B3
        B8B5B3151515151515D0AA8AA74204BA6A38EFCBB3E8D5C0EFCAB6F3CCB2F3CD
        B1F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7
        CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3
        F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CEB3F7CE
        B3F7CEB3F7CEB3F7CEB3F7CEB4F7CEB4F7CEB4F7CEB4F7CEB4F7CEB4F7CEB4F7
        CEB4F7CEB4F7CEB4F7CEB4F7CEB4F7CEB4F7CEB4F7CEB4F7CEB4F7CEB4F3CCB2
        EFCAB6E8D5C0EFCBB3BA6A38A74204D0AA8A151515151515B8B5B3B8B5B3B8B5
        B300B8B5B3B8B5B3B8B5B3B8B5B3151515151515D0AA8AA74204C57440E3C8A9
        F0EBE1F6E7DCF5E1D6F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9DF
        D5F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9
        DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5F9DFD5
        F9DFD4F9DFD4F9DFD4F9DFD4F9DFD4F9DFD4F9DFD4F9DFD4F9DFD4F9DFD4F9DF
        D4F9DFD4F9DFD4F9DFD4F9DFD4F9DFD4F9DFD4F9DFD4F9DFD3F9DFD3F9DFD3F9
        DFD3F9DFD3F6E7DCF0EBE1E3C8A9C57440A74204D0AA8A151515151515B8B5B3
        B8B5B3B8B5B3B8B5B300B8B5B3B8B5B3B8B5B3B8B5B3B8B5B315151515151515
        1515D0AA8AC57440C57440D5B7B0EDDBCEF7EDE7F7EDE7F7EDE7F7EDE7F7EDE7
        F7EDE7F7EDE7F7EDE7F7EDE7F7EDE7F7EDE7F7EDE7F7EDE7F7EDE7F7EDE7F7ED
        E7F7EDE7F7EDE7F7EDE7F7EDE7F7EDE7F7EDE7F7EEE8F7EEE8F8EEE8F8EFE9F8
        EFE9F8F0EAF9F0EAF9F0EAF9F0EAF9F1EBF9F1EBF9F2ECF9F2ECF9F3EDF9F3ED
        F9F4EEF9F4EEF9F5EFF9F5EFFAF5EFFAF6F0FAF6F0FAF6F0FAF7F1FBF7F1FBF8
        F2FBF8F2FBF8F2FBF8F2FBF8F2D5B7B0C57440C57440D0AA8A15151515151515
        1515B8B5B3B8B5B3B8B5B3B8B5B3B8B5B300B8B5B3B8B5B3B8B5B3B8B5B3B8B5
        B3B8B5B3B8B5B3151515151515161618D0AA8AD0AA8AC28761CDA18BCDA18BCD
        A18BD2A588D2A588D2A588D2A588D2A588CDA18BD2A588D2A689D2A689D3A689
        D3A78AD3A78AD3A78AD3A88BD3A88BD3A88BD3A88BD3A88BD3A88BD3A88BD3A8
        8BD3A78AD3A78AD3A78AD3A78AD3A78AD2A78AD2A78AD2A78AD2A78AD2A78AD2
        A78AD3A88AD3A88AD3A88AD3A88AD3A88AD3A98AD3A98BD3A98BD3A98BD3A98B
        D3A98BD3A98CD3A98CD3A98CD3A98CD3A98CD3A98CD0AA8AD0AA8A1616181515
        15151515B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B300B8B5B3B8B5B3
        B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3151515151515151515D0AA
        8AC28762C28762C28762C58960C58960C58960C58960C58960C28762C58960C5
        8960C58960C58960C58960C58960C58960C58960C58960C58960C58960C58960
        C58960C58960C58960C58960C58960C58960C58960C58960C58960C58960C589
        60C58960C58960C58960C58960C58960C58960C58960C58960C58960C58960C5
        8960C58960C58960C58960C58960C58960C58960C58960C58960C58960161618
        151515151515B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5
        B300B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3
        B8B5B31515151515151515151616181515151515151515151515151515151515
        1515151515151515151515151515151515151515151515151515151515151515
        1515151515151515151515151515151515151515151515151515151515151515
        1515151515151515151515151515151515151515151515151515151515151515
        1515151515151515151515151515151515151515151515151515151515151515
        1515151515151515B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3
        B8B5B3B8B5B3B8B5B300B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8
        B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3
        B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5
        B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8
        B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3
        B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5
        B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8
        B5B3B8B5B3B8B5B3B8B5B3B8B5B3B8B5B300}
      Stretch = True
      Transparent = True
    end
    object sbtnCloseCarton: TSpeedButton
      Left = 411
      Top = 29
      Width = 104
      Height = 19
      Caption = 'Box Close'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = sbtnCloseCartonClick
    end
    object Label1: TLabel
      Left = 237
      Top = 89
      Width = 57
      Height = 13
      Caption = 'FIFOCDE:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Lablfifocode: TLabel
      Left = 309
      Top = 89
      Width = 8
      Height = 13
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 405
      Top = 89
      Width = 32
      Height = 13
      Caption = 'ORG:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabLORG: TLabel
      Left = 453
      Top = 89
      Width = 8
      Height = 13
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object editReBoxNo: TEdit
      Left = 143
      Top = 30
      Width = 257
      Height = 24
      CharCase = ecUpperCase
      Color = 8454143
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      ParentFont = False
      TabOrder = 0
      OnChange = editReBoxNoChange
      OnKeyPress = editReBoxNoKeyPress
    end
    object editCSN: TEdit
      Left = 143
      Top = 58
      Width = 257
      Height = 24
      Color = 8454143
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      ParentFont = False
      TabOrder = 1
      OnKeyPress = editCSNKeyPress
    end
    object lvCSNDetail: TListView
      Left = 9
      Top = 105
      Width = 616
      Height = 390
      Columns = <
        item
          Caption = 'Customer SN'
          Width = 100
        end
        item
          Caption = 'Serial Number'
          Width = 120
        end
        item
          Caption = 'Work Order'
          Width = 80
        end
        item
          Caption = 'Part No'
          Width = 120
        end
        item
          Caption = 'Carton No'
          Width = 80
        end
        item
          Caption = 'Pallet No'
          Width = 80
        end>
      TabOrder = 2
      ViewStyle = vsReport
    end
  end
  object QryCartonData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 408
    Top = 240
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 448
    Top = 240
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 336
    Top = 240
  end
  object DataSource1: TDataSource
    DataSet = QryTemp
    Left = 368
    Top = 240
  end
  object QryFIFO: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 488
    Top = 240
  end
  object QryMaterial: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 528
    Top = 240
  end
  object Qryfctype: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 576
    Top = 240
  end
  object qrywip: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 624
    Top = 240
  end
end