object fCondition: TfCondition
  Left = 262
  Top = 180
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Filter'
  ClientHeight = 347
  ClientWidth = 547
  Color = 16775416
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageFilter: TPageControl
    Left = 0
    Top = 35
    Width = 547
    Height = 312
    ActivePage = TabSheet2
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnChange = PageFilterChange
    object TabSheet2: TTabSheet
      Caption = 'Filter'
      ImageIndex = 1
      object SpeedButton1: TSpeedButton
        Left = 498
        Top = 14
        Width = 24
        Height = 22
        AllowAllUp = True
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
        Spacing = 8
        OnClick = SpeedButton1Click
      end
      object Image4: TImage
        Left = 0
        Top = 263
        Width = 358
        Height = 16
        AutoSize = True
        Picture.Data = {
          0A544A504547496D616765B9240000FFD8FFE000104A46494600010100000100
          010000FFDB004300010101010101010101010101010101010101010101010101
          0101010101010101010101010101010101010101010101010101010101010101
          0101010101010101FFDB00430101010101010101010101010101010101010101
          0101010101010101010101010101010101010101010101010101010101010101
          01010101010101010101010101FFC00011080010016603012200021101031101
          FFC4001F0000010501010101010100000000000000000102030405060708090A
          0BFFC400B5100002010303020403050504040000017D01020300041105122131
          410613516107227114328191A1082342B1C11552D1F02433627282090A161718
          191A25262728292A3435363738393A434445464748494A535455565758595A63
          6465666768696A737475767778797A838485868788898A92939495969798999A
          A2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6
          D7D8D9DAE1E2E3E4E5E6E7E8E9EAF1F2F3F4F5F6F7F8F9FAFFC4001F01000301
          01010101010101010000000000000102030405060708090A0BFFC400B5110002
          0102040403040705040400010277000102031104052131061241510761711322
          328108144291A1B1C109233352F0156272D10A162434E125F11718191A262728
          292A35363738393A434445464748494A535455565758595A636465666768696A
          737475767778797A82838485868788898A92939495969798999AA2A3A4A5A6A7
          A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE2E3
          E4E5E6E7E8E9EAF2F3F4F5F6F7F8F9FAFFDA000C03010002110311003F00FED6
          7F6D6F8F9E2AFD953F647FDA37F69CF077C3DF0FFC56D5FF0067AF83FE38F8D7
          79F0F3C4DF10751F85BA778A7C2BF0C344BAF19F8EB4FB6F1C697F0F3E2A5CE9
          3E204F04E8DE21BBF09DACBE09BFD3B5FF00155B68DE1DD6355F0A691AB5F78B
          743FCC0FD887FE0B79E15FDA9FC69FB41DC7C5FF0086FF0007FF00642FD9F3F6
          6BFD983FE09E9F1F3E237C7CF8B7FB54E9D6FA75978ABFE0A27F00BE1D7C70F8
          6BF0F64D3BC51F07FE1E78274BF0FF00862E7C55E25F877A97C41D77E2BE97A8
          F883C55A6F80A3D03E1E4D27C43BFB2F02FE8FFF00C140FE0EFC53FDA2BF61DF
          DACFF678F8296BF0FEE3E26FED01FB3FFC51F817E199FE2978C3C47E04F0268D
          FF000B83C25A9FC3AD67C53AEF88BC27F0F7E28F8817FE110F0FF89355F14E99
          A269FE0BBDFF0084B358D1F4FF000A5D6AFE12B2D6EE7C5DA17E50785BFE09A1
          FB687C26FDABA3FDA57C0B1FECC1E3EB6F07FC60F8AFF1F3C1DE10F167C6AF8A
          DF0E67F15F8ABC63FB557FC16D3C47E1EF87BE26D6F47FD99FE26C7E0AF0FF00
          FC33E7FC1606CFC73ACFC41D2F4BF1E6A3A7FC65FD9FAE7E0BD8FC3CD63C13F1
          462F8FFF000F803F5FFE35FED75F00BE0E7C02D3FE3FEB1F1F7F660F0C7827C7
          FE1FB5B9F813F107E35FED15E0BF835F00BE2E78ABC55E0BD57C6BF0C346D3FE
          395D5B78B3485F0FF8F748D2E5D6ED7C4DE0EF0E7C43D457C176FAAF8BFC3DE1
          3F16DB696D6373E7FF00057F6F8F805E3DF805FB0DFC5DF8BBF123E0FF00ECE7
          E36FDBD3E0FF00C1DF88FF00067E0CFC47F8CDE0BD37C55E2CF157C58F05FC3C
          F13BFC31F862FE277F05EAFF00177C41E1DD5FE267857C2ACDE15F0AC3A8EA9A
          8EB5E1F27C3FA65CF8874ED39BE60F05FEC77FB53FC06BEF813F1C3E16E99FB3
          FF00C56F8DBE13FF008791FF00C2C5F83DE3FF008C1F117E0EFC2CD2BFE1E65F
          B64FC3FF00DB7FC5DFF0857C77F0EFECF9F1AFC5BE31FF00867BF16FC36D3FE0
          CF873FB77F67AF00FF00C2EFF0E788AF7E2DEA7FF0A4F53D020F84BAFF00C3FA
          6FFC11E7F68BD53E0D7C05F87DF1334AF83FE2DD5C7FC1383F667FF826D7C76D
          07C33FB7C7EDFBF057E0D7857C2BFB304FF1E7C2F65F17AE7C05FB37785FE05D
          CFEDEBE1FF008C7E09F8F171AD78B3F665F8DFAB7ECD5A77C3C9FC1FACFC2CF0
          87C7ED6748F8C5E26F89BE1800FD9FF83BFB42FC53F18FED4FFB4CFECD1F14BE
          127C3FF01FFC296F87FF00033E317C3AF1AF803E33788FE28FFC2CAF859F1FBE
          22FED4BE00F08DD78D7C39E22F821F08BFE155FC40D2FF00E198B50D5BC47E0F
          D0B5EF8B9E1CB5FF0084BECEC34CF885AB7F644F797FD07EDADF1F3C55FB2A7E
          C8FF00B46FED39E0EF87BE1FF8ADABFECF5F07FC71F1AEF3E1E789BE20EA3F0B
          74EF14F857E1868975E33F1D69F6DE38D2FE1E7C54B9D27C409E09D1BC4377E1
          3B597C137FA76BFE2AB6D1BC3BAC6ABE14D2356BEF16E87F3FFC36F86FFB6869
          3FF050BF8DBF1EFC63F0ABF660D37F67CF8B1F07FE0AFC03B3D6BC33FB507C56
          F12FC65D1BC2BFB35F8FBF6CAF883E05F88573F0B354FD8E7C23E09BBF107C52
          B9FDA67C3DA1F8B3E1F45F1B61D3BE15C1E1AD6757D1FE21FC5892E2C7497F60
          FF008281FC1DF8A7FB457EC3BFB59FECF1F052D7E1FDC7C4DFDA03F67FF8A3F0
          2FC333FC52F18788FC09E04D1BFE170784B53F875ACF8A75DF11784FE1EFC51F
          102FFC221E1FF126ABE29D3344D3FC177BFF000966B1A3E9FE14BAD5FC2565AD
          DCF8BB4200F903F673FF0082A8FF00C2CAD63C59E20FDA27C0FF00B3FF00EC8F
          F017E1FF00EC81FB2A7ED1FF00127E2BFC48FDACFCAD63E137C53FDA57C77F13
          BE096B9FB31FC5EF0AF8E7E057C2AF067C38F881F02FF68DFD9F7F682F815F13
          E4D7BE2DA788F4BF1DF85FE1FF0086AF3E1FE99E3AF1A78DBC0DF08BEBFF001F
          FF00C1427F605F851FF0857FC2D2FDB87F640F86BFF0B2BE1FF873E2C7C3AFF8
          4FFF00696F82FE0EFF0084FBE1678C7EDBFF00088FC4BF057FC245E35D3BFE12
          AF87FE2AFECED43FE11CF19685F6FF000E6B9F60BDFECCD4AEBECB3ECFCC0FF8
          7647ED4FE18F8A7FB51FC6CF036ADFB3FF00FC5F7FF865DF1D7807E08A7C45F8
          8BE06F11FC04F18FFC247FB7378FBF6F2F86DF06BF6E3B0F827E34F8B5F0BFFE
          1727C5AFDBA3E36F8E3C25FB5FF857E077FC2F68BE167C6EF8DDFB36FC28F017
          EC85FF001663E3B7C27F1FF863FF0004B4FDBA45DFECF9A0FC43D2FF00660F05
          7827F676F8C1F16FE27685AB68DFB5E7ED23FB4B7C42F1869DF1D3FE0B79FB0B
          FF00C15235FF000FF8B3C47F17FF00654F877E29D5FC41F0F3E14FECC3E38F86
          56DF11FC5BE3DF1CF8ABE357C4CD5BC33E28F19B7826DB5DF12EAFA3007EFF00
          7C47FDA17E017C1CF157C31F02FC5DF8E3F07FE15F8DBE367881BC27F067C1DF
          11FE25F82FC0FE2AF8B9E2A4D47C3FA3BF867E18F87BC4FAD697ABF8F7C40BAB
          F8B3C2BA5B68DE15B3D5B515D47C4BE1FB136C2E759D3A2B9F20FDBA7F68AF18
          FECBBFB38F8CFE2CFC36F871F103E307C4DD1FCA97E1EFC27F875F00FE3B7ED0
          1AC7C54F11E896B7DE329BE14CFA6FC01F0CF8A7C41F0A7FE16B787FC2DAE7C3
          4F0EFED01E36D36E3E167C18F1DF8B7C23E32F1CE8BE3BB2B2B7F869E35FC60D
          37FE08F3FB45EA9F06BE02FC3EF899A57C1FF16EAE3FE09C1FB33FFC136BE3B6
          83E19FDBE3F6FDF82BF06BC2BE15FD9827F8F3E17B2F8BD73E02FD9BBC2FF02E
          E7F6F5F0FF00C63F04FC78B8D6BC59FB32FC6FD5BF66AD3BE1E4FE0FD67E1678
          43E3F6B3A47C62F137C4DF0C7EFF007C6BD67E32E9BE15D3F4BF80FE13F0FEBB
          F113C61E20B5F0A58F8AFC737301F867F0774EBCD3B55D4754F8BDF127C3B67E
          26F0C78DBE21F87FC2B6DA59B3D0FE15FC36BEB3F157C4FF00885ACF827C0BAB
          78CFE0AFC3BD77C75FB41FC2400FCC1FD9BFFE0ABFF0A7C69F133F68B1F116F7
          F69FB3F853E2CFDB7FC07F007F647F1A78B3FE09F9FB68780BE19DAE9DAEFC3D
          FD983F677D4FE1EF89BE2AEA9FB30F873C21E0BF1041FF000510BAFDA1BE116B
          30FC75F15685E2AF0E7C425B9F0AEA771A5F85ACFC236D078FFF00C14C7FE0AA
          1FB427EC67FB5FFC3BF867F07BE077FC2D8F02F84BE1FF00ECEBAF7C60D2750B
          3FDA6358D1FC71FF000DC1FB407C4AFD9A3E14D86997FF00B36FEC11FB535EFC
          30F881F0A3E26FC1ED13C51A16ADE32F8A1A37FC2E9F0278EFE297C18F84FF00
          B347ED01F1EB50F85BAF7C29FA02FF00F60DF1DF832D7E19FECB7F0AEFFE206B
          5FB3C3FC40FD88FF00687F1E7C71F8B9F19B47F1F6B165F177F62EFDA3BC1DFB
          42FC5BF14EA9F0D24F00F87BC5BA87ED01FB7578B7E1CFC21D47E25F8AFC29E3
          CB7F827E32F1DEB9FB517ED5DE33F05FC28FDA1ECF52D17FE0A19F2FFF00C149
          3FE096DFB637ED4FE38BCF8C7E0BF8EFF07C78A751F8C1FB1BF866C342F871E0
          9FDB97E04F8AACBF678F82BFB6D68BF17FC3173F13B5FF00873FF0575F855F06
          FE2CF883F66BF0DF8F7E2AFC545F165B7C13F07FC5BF106A36BE2087F677D67E
          087C56D67E1AF897C0A01F407EC49FB707C5BF8D5FB17FED3BE23FDA86CFE307
          C38F8C9F007E306B9F00FC7BE3AFD9EBF67DFDA1FE21FC4C1E2AF895F0A7E097
          C65D07E217C0FF00D947E26FEC1BE01FDA0FC39E1FF86D27ED39A1F85BE1A7C3
          EF8C1FB297C63D4746F87BF0D345F1EFC5EF887FB44786EF3C51F17FC61F107C
          7AFF0082D5F8EFC21F1A3F630D3FE18FED2FFF0004C0D5BE0FF8FBFE145EA7E3
          FD43E377ED57A3FEC5FE31F8A56BF12FF605FDA1FF00690BCF8A5E2DF85DE23F
          0BFED7FF00137F658FD903E22DEF8B7F65FD57E0D6A1F14ED7C0DFB47786FE3B
          7821FE0A78B342F88DF07FF683F057C606FD1EFD98BF658FDABBF618F0AFC68B
          CD0BC5BF07FF006ABB9F8A3E2083C72DE05D37C3BFB55780FE2678D7E3EEBFA7
          7C1FF835A1FC49F8B7FB577EDA3FF0519FDBCBC536BF07FC01F0A7E1EE8163E3
          DD0FC35E05F14F8D345F87BE0E8F54F841E09F1F78DB43D33E107C4DF802E3F6
          43FDA47E1DFC33F85BF027C65FB2B7ED3FF1FF00C6DFB15FC1FF00D997E01FEC
          65FB407ECFD73FB0B58FC02D23C2BFB2D7C42FD947E3F786BE2178BBE1DFC77F
          DBEBF67AF8E3F11FC41FB43FC71FD8EFE01789BF6A1F87DE24B2F86FA77C3CF0
          5F8160FD9BBF660F8876573A678EFF006DCFDA7803F7FBE00FC61F0AFC7EF835
          F0F7E2EF83BC65F07FC7BA478CBC3F0DCDE7897E00FC58D3BE3A7C1A93C55A5C
          F71A178EB46F87BF17F4BD13C316DF10FC3FE15F1B697E21F0AC3E2697C2BE13
          D46FA7D16E0EB1E13F0BEAE97DA069DEC15F307EC6D71FB43DE7ECF1E0ED47F6
          AB9BC40FF1DB56F107C53D67C6167E26F87BF093E15EA3A169DACFC5BF1D6A9E
          04F09DB7817E07FC7EFDA97E1DE91E1FF06FC3BBBF09F853C277369FB41FC54F
          156BDE15D1B46F117C49F133FC49D5BC5B6367E7FA37C64FDA57C43FF050BF16
          7C19D23C03E1F7FD8BFC03FB305B6B3E33F895ACFC2FF8DFE0EF885A7FED71AC
          F8FBC337FE12F09F84FE2378E2CBC35F03BE33FC1FF13FC0ED6F5CD46E6E7E02
          27C54D6FE1A7C4CF01F89BC31F1B7C4DF0BF51D5BE1E785FC7201F6FD7E40FC1
          BFF82977C53BAFF842BC5DFB5AFC08FD9FFF00671F825E3EFDA03F6C3FD97B4D
          F8A5E0DFDB03C47F15FF00E10EF8A7FB147FC357EA7F163C59F1634FF897FB2A
          FECCFE12F027ECFF002F84BF627F8F3E22D37E29C1F117C47E23B0F33E1A41E2
          5F863A1E99E26F196BBF0D7F5FABF283F611FD8ABC55FB33782FF684F8C9E31F
          D94FF620D03F6F0F89FF00183F6CCF88F67F12FE13F8C351D5B51F8A7E15FDA2
          BE3EF8CBF697F02FC31F8C3FB516A9FB25FC3CF8C9A5F87FC31E24F15787BE13
          6B6D17C34F89FA75A7857E14F837E2368FE1FBFBF9EC7E17F84403EE0F0EFED6
          3FB2C78BF47F88BE22F09FED2DFB3FF8A3C3FF0007FE1FF847E2C7C5BD77C3BF
          193E1D6B7A3FC2EF859F103C093FC52F017C4BF88BA9E9BE23B9B2F04FC3FF00
          1B7C32B6B9F88BE11F19789A7D33C39E24F025BCFE2ED1B52BDF0FC526A0A7FC
          358FECB1FF000A27FE1A8FFE1A5BF67FFF008665FF00A38BFF0085C9F0EBFE14
          4FFC8E3FF0AEFF00E4AEFF00C247FF000AFF00FE4A07FC50DFF230FF00C8E3FF
          0014CFFC86BFD06BF383E007EC1FF1F7C09FF04AFF00809FB147887C0DFB307C
          2AF8ADFB2AF883F63AF167816D3E0DFC47F1A789BE0D7C6FF157EC6FF1A7E027
          ED3979E26F1F788AFBF673F847E24F841E20FDAA3E327C2AF18DB7C50D6747F8
          63F1B751F87B3F8FEF7E2F4B73F1BFC5336A9E09BEE83FE18EFF006A7FED4FF8
          69EFECCFD9FF00FE1A6BFE1BFF00FE1B9FFE19DFFE1707C45FF8513FF28E3FF8
          761FFC2AEFF86A8FF867CFF8581FF24FFF00E3243FE136FF008643FF0091C7FE
          31FF00FE111FEC5FF8C80A00FB7ED7F6DDFD8BEFB4EF829AC58FED77FB305E69
          1FB4A788355F09FECE9AA5AFC7DF85371A77C7EF15685E2AD3FC0BAE7867E0A5
          F43E2C7B6F8A9E20D1BC6DAB697E0ED5746F02CBAF6A3A778AB52D3FC3D796D0
          EAF796F672741E3FFDAC7F658F851F14FC15F02FE297ED2DFB3FFC35F8DBF12B
          FE11CFF8575F077C7FF193E1D783BE29F8FBFE131F11DEF83FC23FF0857C3DF1
          1788F4EF16F8ABFE12AF16E9DA8785BC39FD85A45FFF006E788EC2F744D33ED5
          A9DACF6A9F901F1E7FE095FF0018BE3678C7C4BE35D6FC1DFB3FBFFC34C7ECFF
          0007C0BFDA07E19FC34FDABFF6ECFD917E04FC22FED2F8EDFB5AFC67F16F8A75
          2F85FF00B2CEA3E09FF87987FC263FF0D93E29B3F8B3A27C74F11FEC73FF000B
          77C63F0EBC65E3FD2357F831FF000D71E34F0BFC13FA7FC65FB2A7ED2BE28FDB
          6B5BF89F63E00FD98341F813AC7C60F83DE38D63C5DFF0BA7E37EBFA8FC4BF05
          FC2EF03FC27D5625F8E7FB037887E116A1FB34F8E7F69FF0F7C69F869A5DD7C0
          CFDB7BC0BF1DBE127C7DF833E15F867FB2E2DE6A3F117E1B7C0FF18FECDFF1C8
          03EE0FF86B1FD963FE17B7FC32E7FC34B7ECFF00FF000D35FF0046E9FF000B93
          E1D7FC2F6FF913BFE1627FC922FF00848FFE1607FC93FF00F8AE7FE45EFF0091
          3BFE2A6FF902FF00A757CFFF00F0534FDB13E29FEC1BFB277887F697F849FB37
          FF00C3587883C2FF00103E11782AE7E08E99F10FC47F0FFC77E2EFF85CDF127C
          37F06BC2765F0B53C33F073E355EF8E7E205E7C4DF1EF80F49D3FC012683A0FF
          006D68FA9EBB7FA6F88E5F10691A3784BC57E3FF0003BF654FDA57C37FB5C6B5
          F13FC77E00FD983C0DF06ECFE307ED0BF1474DB6F00FC69F8DFF0018F4EF166A
          3E35D6FE25E8DF08FE22F807F657F8B5F08BC37F0EFF00614FDA7EE7E1DFC51F
          165D7ED2DF1D3F667F8EDAEF857F689F157C4AFDA597E2D7C13F88FE24F8E9E0
          3F8AFF00B37FD01FF0501F84DF1F7E357C10F067833F673F0E7C1FF1278DB43F
          DA7FF644F8D7AA5A7C6BF8ABE34F843E151E15FD98BF695F861FB4E5F69FA7F8
          8BC0BF047E3CEAF77E20F186AFF07B43F8796B6B71E12B0D3B46D3BC63AAF8E2
          6D5752B9F08D9F827C6001E7FF0004BFE0A15E15F1A41FB657C46F8DBAB7ECC1
          F03FF65CFD98BE307C36F871E07FDA7EDBF6B1D3BC5DF0CFE2EF857E2DFC1AF8
          2BF1F7E1E7C4ED67C49E2DF855F08BE1DFC38F0FF8BBE1DFED31F012C3C34BA4
          7C4AF8A3A7788BE217893C59E17D0FC417FA1E83E0CF197C4CF6083FE0A13FB0
          2DCF8EFC23F0B6DBF6E1FD902E3E26FC40FF008575FF000817C3A83F696F82F2
          F8EFC6DFF0B8347F0EF88BE127FC223E118FC6ADE20F127FC2D1F0FF008BFC27
          AEFC3AFEC6D3EF7FE136D1FC51E1DD4FC33FDA765ADE9B3DCFE707C34FF825FF
          00C7DFD9DFE067ED0BF0ABE1678BFE0FFC408F51FDB7F45F8C9FB31D96B3AFF8
          D3E04F8D3E1E7EC7BE1FFD8F7E07FEC69E09FD9DBC27FB4BF877E1FF00C6DF89
          3FB32FC60F86FF00027E1FEB5FB3BDCFED57F0FBC17F183E39FC4BF8056BE26B
          9D27C75F043F683F8FF77F1CFE00FC007FE0881FB74F8B3E1EFC69F0AF89755F
          D983C1573E2DF0FF00ED21E19F87D6EBFB50FED23FB43EA2FA77C74F867FF070
          5C7A4DCFC47F8AFF0014FF0066BF08FC44F11F883C31F113FE0B0BF083C2BE20
          F166BE3C73E2AF1EF857E12FC4EF8BBAEEB3FF0009B6BBA2FC3BD5003FA7DD67
          F685F805E1CF8CBE13FD9CFC43F1C7E0FE85FB41F8F7C3F73E2CF02FC09D67E2
          5F82F4BF8CBE34F0AD9C1E26BABCF13784FE185F6B5078DBC47E1FB5B6F05F8C
          6E2E759D1F43BCD3A083C27E269A5B958F41D51AD7D82BF10752FF0082727C62
          F197ED63ACFC74F1DF86BE1FDF787FE357ED01FB287ED75F13A283F6EDFDBB2C
          FC09F04BE29FECE1F0DBF660F0EB7C31F08FEC67F0E34DF839FB397ED7DF66F1
          9FECA9A078A7E1D7ED4BF1CB57F843E23D1758F1CF8775BF1BFECD9E3DF0FF00
          ECF7E1FF00865F157F4FFF006A3FF85ED3FC09F1CE8BFB347FA07C6DF18FFC23
          3F0EFC15E35FF8A3AEBFE14D7FC2CAF18F87BC01E24FDA2FFE11CF1FE3C25F10
          FF00E19A3C25E24D7BF680FF008545AB4B6BFF000B97FE15AFFC2A9B0BEB0D4F
          C63657B00073FF00B3CFC6BF157C78F157ED07E25B3D3FC3F63F027C01F183C4
          3F00FE0EEA96D6BA8C9E2AF88BE2AF81BA8EA7E05FDA4FE216B37D7DAAD9C9A0
          F87F41FDA0ECFC75FB38F867E1F5F78034AD462D47F674F167C6AD2FE21FC49F
          86DF1EBE1BD9F81BCFFF006BFF00DA3BE3EFC0BF1A7ECA5E05F813F02FE0FF00
          C67D5FF69FF8C1E36F82915C7C5BFDA33C69FB3FE9DE0AF15786BE017C5AFDA3
          347D4249BC1DFB31FED2173E21F0FEB5E09F811F13F4BD4AE96CF44D4742F157
          FC207636BA5788348F13F8875CF037D3FF0009FE16F813E077C2CF869F053E16
          E85FF08BFC32F83FF0FF00C1BF0B7E1D7867FB4F58D6FF00E11DF027C3FF000E
          69BE13F08E85FDB3E22D4357F106AFFD91E1FD234FD3FF00B4F5DD5753D62FFE
          CFF6AD4F50BDBD967B997E40FDB63E17FED4FE3BF88BFB1378FF00F668F01FEC
          FF00E3BFF866AFDA03C7DF1D3C6BA4FC74F8F7F117E067F6C7F6CFECB1F1FF00
          F668F0DF85BC2D7FE00FD997F68EFB57DABFE1A3B5EF1AEB7ADEAD67A3FF0063
          FF00C2BDD23C3961A46BFF00F09DDE6BDE0400F40F07FEDDFF00B2C7883C39F0
          7753F187C61F87FF0003FC5BF1CFE207C42F835F0F7E127C74F883F0EBE1EFC5
          3F107C76F83DF14EEBE057C62F823E16F0FDD78C2F74CF89BF103E197C6DB2BA
          F85BADBFC1DD77E23783BC41E237D2350F87BE2DF19F84BC55E0FF0012F883E5
          FF001B7FC153FE1EEA9FB68687FB127ECBB7FF00B307ED15F15BC3DE20F86DA7
          FC76F0BDF7EDA7F0CFE1A7C4CF0AE9DE2EF8ADE39F017C4FD2BE087C32B5F0C7
          C45B9F8E7F183F651F04FC22F8B1F1B3F6A6F829E24F117C11F157C3CF87BA7F
          C3983C3975E39F14FC4A5D07C31F207C54FF008233F8E354F1078B8E93AEF87F
          E35691FB497C1FF12FC30FDA365F137ED5BFB6D7EC65F0F7C2BE2AF89DFB507E
          D9DFB527C67F1FDB7ECE9FB22F8C5ADBF6C4F83FE32F1B7EDDDF12749F09FECA
          1F1E3E3C7C31D47E1E7C33F865A37C363FB5478B757F8D5F10BE297863F47FC3
          9F0BFF006A7F0FFF00C1473E327C77FF00840FF67FBBFD997E2DFECFFF00B34F
          C0BFF84A3FE17DFC45B7F8EDE1FF00F8677D53F6B1F899FF00094FFC298FF866
          59BE1FEABFF0987C40FDA83FE103FEC4FF008685D37FE11FF07781FF00E1647F
          6BEB7AD789BFE157F87C03E9FD1BF685F805E23F8CBE2CFD9CFC3DF1C7E0FEBB
          FB41F80BC3F6DE2CF1D7C09D1BE25F82F54F8CBE0BF0ADE41E19BAB3F1378B3E
          1858EB53F8DBC39E1FBAB6F1A783AE2DB59D6343B3D3A783C59E199A2B968F5E
          D2DAEBE40F8A1FF0574FF826DFC34F805F193F68CB3FDB47F660F8A9E09F827E
          1FBDD4BC43A5FC1EFDA33E0378E3C55E21F153F82FC7DE3AF077C24F06D8C5F1
          2AC348D5BE307C56D23E1878EADFE13F80AFB5CD2751F1CEA3E1AD6E1D2E436D
          A36B179A7FC01E34FF008233F8E3E24EA3FB46FC35F10EBBE1FD37E1DFC52F10
          7FC147BC7DE05FDA0359FDAB7F6DAF8A9A8F85BC55FF00050CF0AFED5BE1BBCB
          2F09FF00C1356FBC63F0F3F62FF839E20F847A77ED87E31F0BDCFC64D1FE237C
          4DD47E2BF857C0BE26BF97E17FC37F889FB496A9E39F813F7FF8D7F671F8FBFB
          57FC02FDB63E1CFED19E10FD983F66FF001B7ED5BFB307893F64ED2FC4BF00F5
          7F1A7ED25E2AD17C2BAD782FE3368563E35F885F17FC75F0D7F655D5FC7FE1FF
          000CEAFF001BF5CBFF0087DF002DFE1AF87B4EF87FA8DA7C43F1443F19FC4D73
          F1DEF340F85401F6FF00C2DF8B1F0B3E38F81342F8A5F053E25FC3FF008C1F0C
          BC51FDA7FF0008CFC45F85BE32F0E7C40F02788BFB1358D43C3BACFF006178BB
          C27A96AFE1FD5FFB23C41A46ABA16A7FD9FA85C7D8358D3350D32EBCABDB2B98
          22F903E32FED4FFB474BE23F8DDE13FD89FF0065FF0087FF00B517883F668D9E
          1FF8CBA7FC50FDA52EBF65EFB7FC5DD67E16784BE35F84BE057C18BA7F813F1A
          ACBC73F102F3E1978F7E1DF89BC51E25F88D73F053E09F877FE16CFC33D1B47F
          8B7E30F105AFC6ED2BE077D7FF000B752F8A7ABF81342D43E35F837E1FFC3FF8
          9B71FDA7FF000937847E16FC4BF11FC60F02691E56B1A841A37F617C45F167C2
          7F81DE20F117DBFC3F1695A9EA7FDA1F0B7C2FFD91AC5EEA1A15AFF6DD96996D
          E22D5FE40F107C1DFDA9FE10FC5DF8EBE2EFD94ED7F67FF14787FF006BBF881E
          1AF8A1F13B58FDA13C61F117C3BAC7ECF7F14FC3BF04FE127ECDEDE3CF01F823
          E1C7C3DF10D97ED2FF000FF50F865F067E1978897E027883E22FECB3E23B1F1D
          F83FC7701FDA6AFBC3FF001C3C3F1FECE001F4FEB3FB42FC02F0E7C65F09FECE
          7E21F8E3F07F42FDA0FC7BE1FB9F167817E04EB3F12FC17A5FC65F1A7856CE0F
          135D5E789BC27F0C2FB5A83C6DE23F0FDADB782FC637173ACE8FA1DE69D041E1
          3F134D2DCAC7A0EA8D6BF307C54FF8280FC2CF027EDA7FB30FEC53E13F17FECF
          FF00113E26FC6AF881F103C01F16FE1FE9FF00B467872CFF0068EFD9FF00FB07
          F662F889FB4E780BC6BA9FECE1A6F85BC4BE20F107C3FF0019F87FE1BDCE81AE
          F88FC4DE2BF861FF000895D78E7E16EABA35978F6CBC65247A3F8FFC4BFD8CBE
          3EF89BE32FC61D0FC3D37C1F93F67CFDA37F6DFF00D8D3F6F0F1D7C4FD67C75E
          34D33E32FC2FF157EC7907EC54D67F057C27F026C7E146B5E09F8A5E1FF89573
          FB09783A1B9F8B9AC7ED19F0A351F03C1F1B7C4D7117C25F1949F07B4BB5F8C3
          C059FEC89FB687823E32FECD3A1F83BC27FB3078B7F67CF803FF00051FFDAA3F
          6DEBCF89FE26FDA17E2B7823E32F89BC2BFB6641FB70B78EBC0F6DF0274BFD94
          3C7BE09D2FC41F066E7F6EAF10C3E13D465FDA32F74EF8C307C1CD1AE3585F83
          727C53BEB5F85E01FA7DF0E3F685F805F18FC55F13BC0BF08BE38FC1FF008A9E
          36F827E205F09FC66F077C38F897E0BF1C78ABE11F8A9F51F1068E9E19F89DE1
          EF0C6B5AA6AFE02F1036AFE13F15696BA378AACF49D45B51F0D7882C45B1B9D1
          B518ADBF287FE0A63FF0526F893FB2FF00FC348FC31F869E03FDA025F105E7EC
          81F12B4CF80DF17BC15FB0C7ED63E3DF0E781FFE0A09E22FF8437C29FB257C2D
          B3F8A907C17F889FB397C71FF869EF19FC71F06F87FC01A7E9AD61E18F84BF14
          FE0AF893E1C7C58D77C73E20F8E3E1AF067C32E83FE09B5FF04DBF1C7EC6FE2A
          F8752F8EECFC3FAADB7ECEDFB305C7EC9DF0DBE27DCFED91FB6D7ED2DE2AF8AB
          E15BED47E0BB6ADE35D1BE04FC78D6B43FD9F3F609F0FF0088E3FD9FBC1FE21F
          137C00F81FA3FC7AD3A6D4756F09F83BC25F19FC13E09F81A2D7E36FD7FF001A
          FE0478ABF6B2F899A7F82BE2B697E20F02FECB9F063C416BE2CB0B1F0FF8FF00
          51F0FF008E3F69AF8B77BF0F755B3F0BF899754F873E29B5D5FE177C1FFD9BB5
          7F1B5BFC41F863ACC97DE1FF00DA1EEFF6DAF865F0E3E397C3BB9F80BA1FECB1
          F0D7C75FB5400741F0BFF6DBF845F1C7FE173E8DF077C2BFB4078A3E26FC0FF8
          7FE17F88BE22F829E3FF00D9C3E367ECB3F14FC45A3FC40FF85996BF0CA0F056
          95FB667827F673F0FEB5FF000B1FC41F083E21784FC39E22BAF13699E04B0F11
          F876F6DBC61E2EF0BD9452EA117E507C49FDB7FF006F3D57F6B8F1B7ECFBF02B
          E35FECC1A0FED2DE34F83FE06F167C2FFF008275F8DBF66D7FDA7751F80D059E
          B7AE4DAD789BF6B9FDA7BF676FDB93C0173FB3A78823F04FC49F82DF12BF68BD
          67E27FC33BCF83563E15F11FC3BF847FF04E6B9FDBCFE34E83E32D5BE397DBFF
          00077E057C5DB9FF008699F8E5FB54FC24FF00859FE20F897FB207C0CFD91BC4
          9FB375EF883E09FC5FF11FED0DA3FECB3FF0D49AB78D7C5FE23F125E786BF676
          FD9CB54FF86B5F19FED31E3AD03C15E02D73C11F07BC08DF0B348F0078EFE2D6
          91F00FC41F15FC7FFB35FECDFF009C1F093FE097FE26F8B7A747F077C6DFB2CF
          87FE1E7C09F02F87F4DD2FC0BE23FF00828DFEC95FF04B9F8D5F10BE0C69DE27
          F1578F75BF8A5E16FD83BE007EC25E3DD43F60FF0084DE20F8837FE2B83E2478
          A3E3BFC51FD9B34BF1568FF133C1BE0EB1F8D1E00FF8286FC36F157827C21FB1
          2807E9FF00ED01FB5BE9DFB3078D3E03E8BF193E31F882D7C6D6BF07FE2CF89B
          E21F85F43FD987C55E0BFD9ABF693D47C17F00BE26FC65F125B781BF699F8A9A
          FD87ECF9FB2B7C60F0AC7FB38F8FFE217827C27F1CFF006DA9FC2BA0FC109FE2
          4E91F18746F11DCF88FE14FED0BF0A7F383FE09E3FF057EF1DFC5EFDA03E24FC
          1AFDA67F699FF8240788FED5FB407C3DF85BE13D57E03FFC146747BFD635CD63
          5FFD903F668D42DB42FD8FFE0A6B3FB39E8DAD7ED09F0FFE22FED35E27F18456
          5A9F8C7E3B47E3BF0478EFC63F12BE07E9DA87C4AFF8511E19BAF1E7DBFF00B4
          57ECEBF197C19E1FFD917C01FB127C19F0FE95E09FF8270F87EDBE25FC13B7F1
          BF8BE0F1269DE35D46C7F65FF8FBFB13FC3FFD9EBC09E19D7FE237877C53E34F
          107C33F853F177C45F1875FD6BE367C64F80BE15F1FF008ABC29F03BE0641F1C
          748B6F8E5F1B7F691FD8FBE40F85DF097F6B4F867F1CFE1D6B9FB36FECC1FB6F
          FECEBA47C4EF107C0BF0B7ED89F11FF683F0C7FC130FE3C6A3F117C2BE11FDB0
          BE367ED5FF00147C7FA66A5F0BBFE0A77E15B6F827E20F8EDE36FDAE3F6A99BF
          686D53C07FB39FC6ED3B47F0AF8F7C3D6FFB267C08F833ABFC35F0EE8DAF807F
          43D45145007FFFD9}
      end
      object Label1: TLabel
        Left = 150
        Top = 16
        Width = 9
        Height = 19
        Caption = '='
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object EditSN: TEdit
        Left = 168
        Top = 14
        Width = 323
        Height = 22
        Ctl3D = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ImeName = #20013#25991' ('#31777#39636') - '#24494#36575#25340#38899#36664#20837#27861' 3.0'
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 0
        OnDblClick = EditSNDblClick
        OnKeyPress = EditSNKeyPress
      end
      object CombType: TComboBox
        Left = 0
        Top = 14
        Width = 145
        Height = 24
        Style = csDropDownList
        Ctl3D = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ImeName = #20013#25991' ('#31777#39636') - '#24494#36575#25340#38899#36664#20837#27861' 3.0'
        ItemHeight = 16
        ItemIndex = 0
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 1
        Text = 'Model Name'
        OnChange = CombTypeChange
        Items.Strings = (
          'Model Name'
          'Process Name'
          'Defect Code')
      end
      object Memo1: TMemo
        Left = 0
        Top = 40
        Width = 523
        Height = 221
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ImeName = #20013#25991' ('#31777#39636') - '#24494#36575#25340#38899#36664#20837#27861' 3.0'
        ParentFont = False
        ReadOnly = True
        TabOrder = 2
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 547
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    Color = 16775416
    TabOrder = 1
    object Image3: TImage
      Left = 424
      Top = 15
      Width = 75
      Height = 20
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
    object Button3: TSpeedButton
      Left = 424
      Top = 15
      Width = 75
      Height = 20
      Caption = 'Exit'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = Button3Click
    end
  end
  object ConditionDataSet: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 408
    Top = 24
  end
end
