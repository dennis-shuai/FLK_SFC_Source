object fRepair: TfRepair
  Left = 72
  Top = 125
  BorderStyle = bsNone
  ClientHeight = 688
  ClientWidth = 1367
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1367
    Height = 688
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    object ImageAll: TImage
      Left = -3
      Top = -3
      Width = 1372
      Height = 692
    end
    object LabelPacking: TLabel
      Left = 8
      Top = 7
      Width = 124
      Height = 16
      Caption = 'QC Repair Check '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label1: TLabel
      Left = 9
      Top = 6
      Width = 124
      Height = 16
      Caption = 'QC Repair Check '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object sbtnRepairer: TSpeedButton
      Left = 218
      Top = 30
      Width = 28
      Height = 24
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
    end
    object labRPName: TLabel
      Left = 253
      Top = 33
      Width = 77
      Height = 18
      Caption = 'Emp Name'
      Color = clTeal
      Font.Charset = ANSI_CHARSET
      Font.Color = clMaroon
      Font.Height = -13
      Font.Name = 'Arial Black'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = True
    end
    object Label12: TLabel
      Left = 10
      Top = 33
      Width = 90
      Height = 18
      Caption = 'Repairer No.'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Arial Black'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object Label11: TLabel
      Left = 9
      Top = 32
      Width = 90
      Height = 18
      Caption = 'Repairer No.'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial Black'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label14: TLabel
      Left = 9
      Top = 94
      Width = 102
      Height = 18
      Caption = 'Serial Number'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Arial Black'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object lblInputProcess: TLabel
      Left = 581
      Top = 63
      Width = 4
      Height = 18
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial Black'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblStatus: TLabel
      Left = 46
      Top = 539
      Width = 660
      Height = 28
      AutoSize = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clNavy
      Font.Height = -24
      Font.Name = 'Bookman Old Style'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object lblPrompt: TLabel
      Left = 43
      Top = 485
      Width = 660
      Height = 28
      AutoSize = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clNavy
      Font.Height = -24
      Font.Name = 'Bookman Old Style'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object editRepairer: TEdit
      Left = 120
      Top = 30
      Width = 97
      Height = 24
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Bookman Old Style'
      Font.Style = [fsBold]
      ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
      ParentFont = False
      TabOrder = 0
      Text = 'editRepairer'
    end
    object pgc1: TPageControl
      Left = 8
      Top = 64
      Width = 633
      Height = 569
      ActivePage = ts1
      Style = tsButtons
      TabOrder = 1
      OnChange = pgc1Change
      object ts1: TTabSheet
        Caption = 'CM Repair QC Check In'
        object tbc1: TTabControl
          Left = 0
          Top = 0
          Width = 625
          Height = 538
          Align = alClient
          TabOrder = 0
          object Label2: TLabel
            Left = 10
            Top = 118
            Width = 102
            Height = 18
            Caption = 'Serial Number'
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label8: TLabel
            Left = 506
            Top = 78
            Width = 74
            Height = 18
            Caption = 'Check WO'
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label9: TLabel
            Left = 506
            Top = 102
            Width = 58
            Height = 18
            Caption = 'New Wo'
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object lblErrorProcess: TLabel
            Left = 37
            Top = 170
            Width = 423
            Height = 95
            Alignment = taCenter
            AutoSize = False
            Color = 14347742
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -96
            Font.Name = 'Baskerville Old Face'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            Layout = tlCenter
          end
          object Label5: TLabel
            Left = 25
            Top = 147
            Width = 64
            Height = 18
            Caption = #19981#33391#31449#40670
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label7: TLabel
            Left = 28
            Top = 273
            Width = 64
            Height = 18
            Caption = #19981#33391#20195#30908
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object lblErrorCode: TLabel
            Left = 38
            Top = 293
            Width = 420
            Height = 100
            Alignment = taCenter
            AutoSize = False
            Color = 14347742
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -96
            Font.Name = 'Baskerville Old Face'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            Layout = tlCenter
          end
          object Label10: TLabel
            Left = 28
            Top = 401
            Width = 64
            Height = 18
            Caption = #36820#22238#20449#24687
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label6: TLabel
            Left = 482
            Top = 150
            Width = 33
            Height = 18
            Caption = 'Qty: '
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object LabQty: TLabel
            Left = 482
            Top = 177
            Width = 103
            Height = 64
            Alignment = taCenter
            AutoSize = False
            Caption = '0'
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            Layout = tlCenter
          end
          object Label3: TLabel
            Left = 11
            Top = 66
            Width = 79
            Height = 18
            Caption = 'Repair WO.'
            Font.Charset = ANSI_CHARSET
            Font.Color = clWhite
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object Label4: TLabel
            Left = 10
            Top = 81
            Width = 79
            Height = 18
            Caption = 'Repair WO.'
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object LabTerminalIn: TLabel
            Left = 37
            Top = 48
            Width = 436
            Height = 18
            AutoSize = False
            Caption = 'Emp Name'
            Color = clTeal
            Font.Charset = ANSI_CHARSET
            Font.Color = clMaroon
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            Transparent = True
          end
          object Label17: TLabel
            Left = 394
            Top = 17
            Width = 63
            Height = 18
            Caption = 'Terminal'
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label16: TLabel
            Left = 194
            Top = 17
            Width = 58
            Height = 18
            Caption = 'Process'
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label20: TLabel
            Left = 10
            Top = 17
            Width = 31
            Height = 18
            Caption = 'Line'
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object edtWO: TEdit
            Left = 119
            Top = 78
            Width = 294
            Height = 24
            Color = clYellow
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Bookman Old Style'
            Font.Style = [fsBold]
            ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
            ParentFont = False
            TabOrder = 0
            OnChange = edtWOChange
            OnKeyPress = edtWOKeyPress
          end
          object cmbSN: TComboBox
            Left = 119
            Top = 115
            Width = 298
            Height = 24
            Color = clYellow
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Bookman Old Style'
            Font.Style = [fsBold]
            ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
            ItemHeight = 16
            ParentFont = False
            TabOrder = 1
            OnKeyPress = cmbSNKeyPress
          end
          object chkNewWo: TCheckBox
            Left = 480
            Top = 104
            Width = 17
            Height = 17
            Enabled = False
            TabOrder = 2
          end
          object chkWO: TCheckBox
            Left = 480
            Top = 80
            Width = 17
            Height = 17
            Enabled = False
            TabOrder = 3
          end
          object MsgPanel: TPanel
            Left = 40
            Top = 425
            Width = 417
            Height = 89
            Color = 14347742
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 4
          end
          object cmbProcessIn: TComboBox
            Left = 256
            Top = 16
            Width = 129
            Height = 25
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = '@Microsoft MHei'
            Font.Style = [fsBold]
            ItemHeight = 17
            ParentFont = False
            TabOrder = 5
            OnSelect = cmbProcessInSelect
          end
          object cmbTerminalIn: TComboBox
            Left = 464
            Top = 16
            Width = 145
            Height = 25
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = '@Microsoft MHei'
            Font.Style = [fsBold]
            ItemHeight = 17
            ParentFont = False
            TabOrder = 6
            OnSelect = cmbTerminalInSelect
          end
          object cmbLineIn: TComboBox
            Left = 48
            Top = 16
            Width = 129
            Height = 25
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = '@Microsoft MHei'
            Font.Style = [fsBold]
            ItemHeight = 17
            ParentFont = False
            TabOrder = 7
            OnSelect = cmbLineInSelect
          end
        end
      end
      object ts2: TTabSheet
        Caption = 'CM Repair QC Check Out'
        ImageIndex = 1
        object tbc2: TTabControl
          Left = 0
          Top = 0
          Width = 625
          Height = 538
          Align = alClient
          TabOrder = 0
          object Label13: TLabel
            Left = 48
            Top = 86
            Width = 57
            Height = 19
            AutoSize = False
            Caption = #26781#30908#65306
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label15: TLabel
            Left = 50
            Top = 270
            Width = 33
            Height = 18
            Caption = 'Qty: '
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object LabQtyOut: TLabel
            Left = 122
            Top = 249
            Width = 103
            Height = 64
            Alignment = taCenter
            AutoSize = False
            Caption = '0'
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            Layout = tlCenter
          end
          object LabTerminalOut: TLabel
            Left = 37
            Top = 48
            Width = 460
            Height = 18
            Caption = 'Emp Name'
            Color = clTeal
            Font.Charset = ANSI_CHARSET
            Font.Color = clMaroon
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            Transparent = True
          end
          object Label18: TLabel
            Left = 186
            Top = 17
            Width = 58
            Height = 18
            Caption = 'Process'
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label19: TLabel
            Left = 394
            Top = 17
            Width = 63
            Height = 18
            Caption = 'Terminal'
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object Label21: TLabel
            Left = 10
            Top = 17
            Width = 31
            Height = 18
            Caption = 'Line'
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Arial Black'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
          end
          object edtSN: TEdit
            Left = 129
            Top = 82
            Width = 256
            Height = 25
            Color = 8454143
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = '@Microsoft MHei'
            Font.Style = [fsBold]
            ImeName = #20013#25991' (?'#20307') - '#25628#29399#25340#38899'?'#20837#27861
            ParentFont = False
            TabOrder = 0
            OnKeyPress = edtSNKeyPress
          end
          object MsgPanelOut: TPanel
            Left = 40
            Top = 129
            Width = 417
            Height = 89
            Color = 14347742
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 1
          end
          object cmbProcessOut: TComboBox
            Left = 248
            Top = 16
            Width = 129
            Height = 25
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = '@Microsoft MHei'
            Font.Style = [fsBold]
            ItemHeight = 17
            ParentFont = False
            TabOrder = 2
            OnSelect = cmbProcessOutSelect
          end
          object cmbTerminalOut: TComboBox
            Left = 464
            Top = 16
            Width = 145
            Height = 25
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = '@Microsoft MHei'
            Font.Style = [fsBold]
            ItemHeight = 17
            ParentFont = False
            TabOrder = 3
            OnSelect = cmbTerminalOutSelect
          end
          object cmbLineOut: TComboBox
            Left = 48
            Top = 16
            Width = 129
            Height = 25
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = '@Microsoft MHei'
            Font.Style = [fsBold]
            ItemHeight = 17
            ParentFont = False
            TabOrder = 4
            OnSelect = cmbLineOutSelect
          end
        end
      end
    end
  end
  object QryData: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryData'
    Left = 746
    Top = 10
  end
  object QryTemp: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 812
    Top = 3
  end
  object SProc: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 713
    Top = 10
  end
  object ImageList1: TImageList
    Left = 592
    Top = 15
    Bitmap = {
      494C010102000400040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001001000000000000008
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000BE7F00000000
      0000000000000000BF7F00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F657F44BF75B
      FB6F000000000000000000000000000000000000000000000000D97E5C7F7D7F
      000000009D7F5C7FD97EF37D0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F653D137D13B
      F54FF65700000000000000000000000000000000000000000000147E977E1A7F
      3B7F3B7F1A7F977E147E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FB67F753D137CC1B
      CB17CC1BCD1F00000000000000000000000000000000000000000000707DD27D
      147E147ED27D707DB17D00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000F853FF7FD54700000000
      CC07CC07CC07CC0700000000000000000000000000000000000000000000CB7C
      EC7CEB7CCB7C6F79000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF7F000000000000
      0000CD13CD07CD07CD070000000000000000000000000000000000008A7C897C
      A97CA97C897CA97C000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000F547D33BD12700000000000000000000000000000000B07DF17DF27D
      F17DD17DCA7C677C677C00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FA63F857D6470000000000000000000000000000D77EF87EF87E
      00000000B77E547EF17D00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FD7700000000000000000000000000003A7FBD7F9C7F0000
      0000000000003A7FF87E337E0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFF00000000FFFFFFFF00000000
      FFFFF7EF00000000F9FFE3C700000000F07FE00300000000E03FF00700000000
      C01FF00F00000000800FF80F00000000C60FF00F00000000EF07F00F00000000
      FF83E00700000000FFC7C18300000000FFFFF7E700000000FFFFFFFF00000000
      FFFFFFFF00000000FFFFFFFF0000000000000000000000000000000000000000
      000000000000}
  end
  object PopupMenu1: TPopupMenu
    Left = 779
    Top = 10
    object AddDefect1: TMenuItem
      Caption = 'Add Defect'
    end
    object DeleteDfect1: TMenuItem
      Caption = 'Delete Dfect'
    end
    object RepairRecord1: TMenuItem
      Caption = 'Repair Record'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Scrap1: TMenuItem
      Caption = 'Scrap'
    end
    object Finish1: TMenuItem
      Caption = 'Finish'
    end
  end
  object QryReplace: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 845
    Top = 3
  end
  object QryRepair: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    Left = 623
    Top = 2
  end
end
