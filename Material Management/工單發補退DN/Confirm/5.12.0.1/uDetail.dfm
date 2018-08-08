object fDetail: TfDetail
  Left = 193
  Top = 129
  BorderStyle = bsNone
  ClientHeight = 536
  ClientWidth = 823
  Color = clSilver
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
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
    Width = 823
    Height = 536
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    object GroupBox1: TGroupBox
      Left = 0
      Top = 368
      Width = 823
      Height = 168
      Align = alBottom
      TabOrder = 0
      object DBGrid1: TDBGrid
        Left = 2
        Top = 15
        Width = 819
        Height = 151
        Align = alClient
        DataSource = DataSource1
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Options = [dgTitles, dgIndicator, dgColumnResize, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'MS Sans Serif'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'WIP_ENTITY_NAME'
            Title.Caption = 'WORK_ORDER'
            Width = 97
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'PART_NO'
            Width = 138
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'MATERIAL_NO'
            Width = 121
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'QTY'
            Width = 45
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'SUBINV'
            Width = 66
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'LOCATOR'
            Width = 61
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'SEQ_NUMBER'
            Width = 89
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'CREATE_TIME'
            Width = 160
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'CREATE_USER'
            Width = 122
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ISSUE_HEADER_ID'
            Width = 118
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ISSUE_LINE_ID'
            Width = 104
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ISSUE_TYPE'
            Width = 99
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ISSUE_TYPE_NAME'
            Width = 115
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ORG_ID'
            Width = 60
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ISSUE_USER'
            Width = 79
            Visible = True
          end>
      end
    end
    object GroupBox2: TGroupBox
      Left = 0
      Top = 197
      Width = 823
      Height = 171
      Align = alBottom
      TabOrder = 1
      object PageControl1: TPageControl
        Left = 2
        Top = 15
        Width = 819
        Height = 154
        ActivePage = TabShtWI
        Align = alClient
        TabOrder = 0
        object TabShtWI: TTabSheet
          Caption = #30332#35036#26009
          object Label4: TLabel
            Left = 10
            Top = 9
            Width = 79
            Height = 16
            Alignment = taRightJustify
            Caption = 'Issue User:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label8: TLabel
            Left = 10
            Top = 41
            Width = 87
            Height = 16
            Alignment = taRightJustify
            Caption = 'Material NO:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object labWIlocate: TLabel
            Left = 96
            Top = 75
            Width = 88
            Height = 16
            Caption = 'LabWIlocate'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clGreen
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            Visible = False
          end
          object edtWIISSUEUSER: TEdit
            Left = 104
            Top = 12
            Width = 169
            Height = 21
            Color = clWhite
            MaxLength = 25
            TabOrder = 0
          end
          object edtWImaterial: TEdit
            Left = 104
            Top = 44
            Width = 169
            Height = 21
            Color = clYellow
            TabOrder = 1
            OnChange = edtWImaterialChange
            OnKeyPress = edtWImaterialKeyPress
          end
        end
        object TabShtWIR: TTabSheet
          Caption = #27425#26009#36864#26009
          ImageIndex = 1
          object Label12: TLabel
            Left = 3
            Top = 3
            Width = 57
            Height = 16
            Caption = 'Part No:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label6: TLabel
            Left = 3
            Top = 27
            Width = 54
            Height = 16
            Caption = 'Version'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label2: TLabel
            Left = 3
            Top = 51
            Width = 75
            Height = 16
            Caption = 'Date Code'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label3: TLabel
            Left = 211
            Top = 27
            Width = 75
            Height = 16
            Caption = 'FIFO Code'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label5: TLabel
            Left = 211
            Top = 3
            Width = 101
            Height = 16
            Caption = 'Request/Issue'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object lablLocate: TLabel
            Left = 491
            Top = 3
            Width = 53
            Height = 16
            Caption = 'Locator'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label9: TLabel
            Left = 491
            Top = 35
            Width = 32
            Height = 16
            Caption = 'QTY'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object LablWIRMqty: TLabel
            Left = 656
            Top = 38
            Width = 5
            Height = 13
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clRed
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object lablWIRType: TLabel
            Left = 490
            Top = 64
            Width = 5
            Height = 16
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clGreen
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            Visible = False
          end
          object lablWIRMsg: TLabel
            Left = 5
            Top = 83
            Width = 5
            Height = 16
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clNavy
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Image3: TImage
            Left = 670
            Top = 65
            Width = 75
            Height = 18
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
          object sbtnWIRprint: TSpeedButton
            Left = 670
            Top = 65
            Width = 75
            Height = 18
            Cursor = crHandPoint
            Caption = 'Print'
            Flat = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            OnClick = sbtnWIRprintClick
          end
          object Label11: TLabel
            Left = 210
            Top = 57
            Width = 79
            Height = 16
            Alignment = taRightJustify
            Caption = 'Issue User:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object editWIRPart: TEdit
            Left = 80
            Top = 6
            Width = 121
            Height = 21
            Color = clYellow
            TabOrder = 0
            OnChange = editWIRPartChange
            OnKeyDown = editWIRPartKeyDown
          end
          object edtWIRVersion: TEdit
            Left = 80
            Top = 30
            Width = 121
            Height = 21
            Enabled = False
            TabOrder = 1
          end
          object edtWIRDateCode: TEdit
            Left = 80
            Top = 54
            Width = 121
            Height = 21
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            TabOrder = 2
          end
          object edtWIRFIFO: TEdit
            Left = 312
            Top = 30
            Width = 73
            Height = 21
            Enabled = False
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            TabOrder = 3
          end
          object DateTimePickerWIR: TDateTimePicker
            Left = 392
            Top = 30
            Width = 89
            Height = 21
            Date = 39441.394537754620000000
            Time = 39441.394537754620000000
            TabOrder = 4
            OnChange = DateTimePickerWIRChange
          end
          object edtWIRRequest: TEdit
            Left = 312
            Top = 6
            Width = 81
            Height = 21
            Enabled = False
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            TabOrder = 5
          end
          object edtWIRIssue: TEdit
            Left = 392
            Top = 6
            Width = 89
            Height = 21
            Enabled = False
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            TabOrder = 6
          end
          object cmbWIRStock: TComboBox
            Left = 552
            Top = 6
            Width = 97
            Height = 21
            Style = csDropDownList
            Color = 8454143
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            ItemHeight = 0
            TabOrder = 7
            OnChange = cmbWIRStockChange
          end
          object cmbWIRLocate: TComboBox
            Left = 648
            Top = 6
            Width = 97
            Height = 21
            Style = csDropDownList
            Color = 8454143
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            ItemHeight = 0
            TabOrder = 8
          end
          object sedtWIRQty: TSpinEdit
            Left = 552
            Top = 37
            Width = 97
            Height = 22
            Color = 8454143
            MaxValue = 0
            MinValue = 0
            TabOrder = 9
            Value = 0
          end
          object edtWIRItem: TEdit
            Left = 800
            Top = 30
            Width = 193
            Height = 21
            Enabled = False
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            TabOrder = 10
            Visible = False
          end
          object EdtWIRpartid: TEdit
            Left = 800
            Top = 6
            Width = 193
            Height = 21
            Enabled = False
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            TabOrder = 11
            Visible = False
          end
          object edtWIRissueuser: TEdit
            Left = 312
            Top = 60
            Width = 169
            Height = 21
            Color = clWhite
            MaxLength = 25
            TabOrder = 12
          end
        end
        object TabShtWR: TTabSheet
          Caption = #36864#26009
          ImageIndex = 2
          object Label14: TLabel
            Left = 3
            Top = 10
            Width = 81
            Height = 16
            Caption = 'Material No'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label15: TLabel
            Left = 88
            Top = 35
            Width = 119
            Height = 16
            Caption = '(Max:                   )'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label16: TLabel
            Left = 3
            Top = 50
            Width = 80
            Height = 16
            Caption = 'Work Order'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label18: TLabel
            Left = 3
            Top = 76
            Width = 53
            Height = 16
            Caption = 'Part No'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label19: TLabel
            Left = 219
            Top = 4
            Width = 54
            Height = 16
            Caption = 'Version'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label17: TLabel
            Left = 219
            Top = 28
            Width = 75
            Height = 16
            Caption = 'Date Code'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label20: TLabel
            Left = 219
            Top = 52
            Width = 75
            Height = 16
            Caption = 'FIFO Code'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label21: TLabel
            Left = 459
            Top = 28
            Width = 85
            Height = 16
            Caption = 'WH+Locate:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label23: TLabel
            Left = 459
            Top = 76
            Width = 32
            Height = 16
            Caption = 'QTY'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object lablWRMQty: TLabel
            Left = 196
            Top = 37
            Width = 5
            Height = 16
            Alignment = taRightJustify
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlue
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object lablWRMsg: TLabel
            Left = 3
            Top = 108
            Width = 5
            Height = 16
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clNavy
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label24: TLabel
            Left = 219
            Top = 76
            Width = 101
            Height = 16
            Caption = 'Request/Issue'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object lablWRType: TLabel
            Left = 458
            Top = 104
            Width = 5
            Height = 16
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clGreen
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            Visible = False
          end
          object LblWRwh: TLabel
            Left = 547
            Top = 28
            Width = 5
            Height = 16
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object lblWRlocate: TLabel
            Left = 611
            Top = 28
            Width = 5
            Height = 16
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Image2: TImage
            Left = 614
            Top = 106
            Width = 75
            Height = 18
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
          object sbtnWRprint: TSpeedButton
            Left = 614
            Top = 104
            Width = 75
            Height = 20
            Cursor = crHandPoint
            Caption = 'Print'
            Flat = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            OnClick = sbtnWRprintClick
          end
          object Label22: TLabel
            Left = 459
            Top = 52
            Width = 48
            Height = 16
            Caption = 'Locate'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label25: TLabel
            Left = 458
            Top = 1
            Width = 79
            Height = 16
            Alignment = taRightJustify
            Caption = 'Issue User:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object editWRMaterial: TEdit
            Left = 88
            Top = 8
            Width = 121
            Height = 21
            Color = 8454143
            TabOrder = 0
            OnChange = editWRMaterialChange
            OnKeyPress = editWRMaterialKeyPress
          end
          object editWRWo: TEdit
            Left = 88
            Top = 55
            Width = 121
            Height = 21
            Enabled = False
            TabOrder = 1
          end
          object edtWRVersion: TEdit
            Left = 320
            Top = 7
            Width = 129
            Height = 21
            Enabled = False
            TabOrder = 2
          end
          object edtWRDateCode: TEdit
            Left = 320
            Top = 31
            Width = 129
            Height = 21
            Enabled = False
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            TabOrder = 3
          end
          object edtWRFIFO: TEdit
            Left = 320
            Top = 55
            Width = 129
            Height = 21
            Enabled = False
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            TabOrder = 4
          end
          object cmbWRStock: TComboBox
            Left = 512
            Top = 55
            Width = 89
            Height = 21
            Style = csDropDownList
            Color = 8454143
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            ItemHeight = 0
            TabOrder = 5
            OnChange = cmbWRStockChange
          end
          object sedtWRQty: TSpinEdit
            Left = 512
            Top = 78
            Width = 89
            Height = 22
            Color = 8454143
            MaxValue = 0
            MinValue = 0
            TabOrder = 6
            Value = 0
          end
          object cmbWRLocate: TComboBox
            Left = 600
            Top = 55
            Width = 89
            Height = 21
            Style = csDropDownList
            Color = 8454143
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            ItemHeight = 0
            TabOrder = 7
          end
          object EditWRSource: TEdit
            Left = 936
            Top = 39
            Width = 73
            Height = 21
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            TabOrder = 8
            Visible = False
          end
          object edtWRRequest: TEdit
            Left = 320
            Top = 79
            Width = 65
            Height = 21
            Enabled = False
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            TabOrder = 9
          end
          object edtWRIssue: TEdit
            Left = 384
            Top = 79
            Width = 65
            Height = 21
            Enabled = False
            ImeName = 'Chinese (Simplified) - Microsoft Pinyin'
            TabOrder = 10
          end
          object editWRPart: TEdit
            Left = 88
            Top = 80
            Width = 121
            Height = 21
            Enabled = False
            TabOrder = 11
          end
          object edtWRissueuser: TEdit
            Left = 536
            Top = 4
            Width = 145
            Height = 21
            Color = clWhite
            MaxLength = 25
            TabOrder = 12
          end
        end
      end
    end
    object GroupBox3: TGroupBox
      Left = 0
      Top = 65
      Width = 823
      Height = 132
      Align = alClient
      TabOrder = 2
      object DBGrid2: TDBGrid
        Left = 2
        Top = 15
        Width = 819
        Height = 115
        Align = alClient
        DataSource = DataSource2
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Options = [dgTitles, dgIndicator, dgColumnResize, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'MS Sans Serif'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'WIP_ENTITY_NAME'
            Title.Caption = 'WORK_ORDER'
            Title.Font.Charset = DEFAULT_CHARSET
            Title.Font.Color = clWindowText
            Title.Font.Height = -11
            Title.Font.Name = 'MS Sans Serif'
            Title.Font.Style = [fsBold]
            Width = 104
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'PART_NO'
            Title.Caption = 'Part No'
            Title.Font.Charset = DEFAULT_CHARSET
            Title.Font.Color = clWindowText
            Title.Font.Height = -11
            Title.Font.Name = 'MS Sans Serif'
            Title.Font.Style = [fsBold]
            Width = 150
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'APPLY_QTY'
            Title.Font.Charset = DEFAULT_CHARSET
            Title.Font.Color = clWindowText
            Title.Font.Height = -11
            Title.Font.Name = 'MS Sans Serif'
            Title.Font.Style = [fsBold]
            Width = 92
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'PRINT_QTY'
            Title.Font.Charset = DEFAULT_CHARSET
            Title.Font.Color = clWindowText
            Title.Font.Height = -11
            Title.Font.Name = 'MS Sans Serif'
            Title.Font.Style = [fsBold]
            Width = 104
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'SEQ_NUMBER'
            Title.Font.Charset = DEFAULT_CHARSET
            Title.Font.Color = clWindowText
            Title.Font.Height = -11
            Title.Font.Name = 'MS Sans Serif'
            Title.Font.Style = [fsBold]
            Width = 101
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ISSUE_HEADER_ID'
            Title.Font.Charset = DEFAULT_CHARSET
            Title.Font.Color = clWindowText
            Title.Font.Height = -11
            Title.Font.Name = 'MS Sans Serif'
            Title.Font.Style = [fsBold]
            Width = 128
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ISSUE_LINE_ID'
            Title.Font.Charset = DEFAULT_CHARSET
            Title.Font.Color = clWindowText
            Title.Font.Height = -11
            Title.Font.Name = 'MS Sans Serif'
            Title.Font.Style = [fsBold]
            Width = 129
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ISSUE_TYPE'
            Title.Font.Charset = DEFAULT_CHARSET
            Title.Font.Color = clWindowText
            Title.Font.Height = -11
            Title.Font.Name = 'MS Sans Serif'
            Title.Font.Style = [fsBold]
            Width = 113
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ISSUE_TYPE_NAME'
            Title.Font.Charset = DEFAULT_CHARSET
            Title.Font.Color = clWindowText
            Title.Font.Height = -11
            Title.Font.Name = 'MS Sans Serif'
            Title.Font.Style = [fsBold]
            Width = 138
            Visible = True
          end>
      end
    end
    object GroupBox4: TGroupBox
      Left = 0
      Top = 0
      Width = 823
      Height = 65
      Align = alTop
      TabOrder = 3
      object Image1: TImage
        Left = 510
        Top = 35
        Width = 75
        Height = 18
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
      object Label7: TLabel
        Left = 11
        Top = 33
        Width = 52
        Height = 16
        Caption = 'Wip No'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object sbtnMISC: TSpeedButton
        Left = 226
        Top = 36
        Width = 21
        Height = 21
        Flat = True
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000000000000000000000000000000000000000FF0000FF
          63494A5A595A8C8E8C0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000
          FF0000FF0000FF0000FF0000FF63494A7B719CAD86845A595A8C8E8C0000FF00
          00FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF63BEF7
          428EDE7B79A5AD86845A595A8C8E8C0000FF0000FF0000FF0000FF0000FF0000
          FF0000FF0000FF0000FF0000FF8496FF52B6FF428EDE7B79A5AD86845A595A8C
          8E8C0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF
          8496FF52B6FF428EDE7B79A5B586845A595A8C8E8C0000FF0000FF0000FF0000
          FF0000FF0000FF0000FF0000FF0000FF0000FF8496FF52BEFF4279D67B79A5AD
          86846B616B6B616B6B616B6B616B6B616B8C8E8C0000FF0000FF0000FF0000FF
          0000FF0000FF8496FF52B6FF428EDE8C8E8C7B797BC69E84D6AE94E7CFB5D6B6
          A57371736B616B0000FF0000FF0000FF0000FF0000FF0000FF8496FF8496FFB5
          8684F7D7ADFFF7C6FFFFD6FFFFDEFFFFDEFFF7E7AD86846B616B0000FF0000FF
          0000FF0000FF0000FF0000FFD6AE94EFCFADFFF7BDFFF7C6FFFFDEFFFFEFFFFF
          FFFFFFFFF7EFCE7361630000FF0000FF0000FF0000FF0000FF0000FFD6B6A5FF
          F7C6FFE7B5FFFFC6FFFFDEFFFFEFFFFFFFFFFFF7FFFFDEC69E8C0000FF0000FF
          0000FF0000FF0000FF0000FFD6AE94FFF7CEFFDFADFFF7C6FFFFD6FFFFE7FFFF
          EFFFFFE7FFFFDED6AE940000FF0000FF0000FF0000FF0000FF0000FFD6B6A5FF
          F7C6FFE7BDFFEFBDFFFFCEFFFFD6FFFFDEFFFFDEFFFFD6D6AE940000FF0000FF
          0000FF0000FF0000FF0000FFD6B6A5FFF7CEFFF7D6FFE7B5FFF7BDFFF7C6FFFF
          C6FFF7C6FFFFC6B58E840000FF0000FF0000FF0000FF0000FF0000FFDEB69CEF
          E7C6FFFFFFFFFFEFFFEFBDFFDFADFFE7B5FFF7BDF7D7AD9C71730000FF0000FF
          0000FF0000FF0000FF0000FF0000FFD6B6A5F7EFCEFFFFEFFFF7CEFFEFBDFFF7
          C6FFD7A5BD968C0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00
          00FFD6B6A5D6B6A5CEA68CE7BEA5DEB69C8C8E8C0000FF0000FF}
        OnClick = sbtnMISCClick
      end
      object Label13: TLabel
        Left = 264
        Top = 36
        Width = 28
        Height = 13
        Caption = 'ORG'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object sbtncheck: TSpeedButton
        Left = 506
        Top = 31
        Width = 75
        Height = 26
        Cursor = crHandPoint
        Caption = 'Check'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = sbtncheckClick
      end
      object LabTitle1: TLabel
        Left = 7
        Top = 13
        Width = 79
        Height = 16
        Caption = 'Label Print'
        Font.Charset = CHINESEBIG5_CHARSET
        Font.Color = clYellow
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object LabTitle2: TLabel
        Left = 8
        Top = 14
        Width = 79
        Height = 16
        Caption = 'Label Print'
        Font.Charset = CHINESEBIG5_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object edtWipscNO: TEdit
        Left = 72
        Top = 36
        Width = 153
        Height = 21
        TabOrder = 0
        OnChange = edtWipscNOChange
        OnKeyPress = edtWipscNOKeyPress
      end
      object EditORG: TEdit
        Left = 296
        Top = 36
        Width = 105
        Height = 21
        ReadOnly = True
        TabOrder = 1
      end
      object chkPush: TRzCheckBox
        Left = 408
        Top = 32
        Width = 97
        Height = 17
        Caption = 'Push Title'
        Checked = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        ReadOnly = True
        State = cbChecked
        TabOrder = 2
        Transparent = True
        Visible = False
        OnMouseDown = chkPushMouseDown
      end
    end
  end
  object QryMaterial: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 104
    Top = 400
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 72
    Top = 128
  end
  object SaveDialog1: TSaveDialog
    Left = 32
    Top = 128
  end
  object QryDetail: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 224
    Top = 136
  end
  object DataSource2: TDataSource
    AutoEdit = False
    DataSet = QryDetail
    OnDataChange = DataSource2DataChange
    Left = 264
    Top = 136
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 112
    Top = 128
  end
  object DataSource1: TDataSource
    AutoEdit = False
    DataSet = QryMaterial
    Left = 152
    Top = 400
  end
  object QryWRReel: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 600
    Top = 136
  end
  object QryWRDetail: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 560
    Top = 136
  end
end
