object fMain: TfMain
  Left = 287
  Top = 121
  Width = 565
  Height = 493
  Caption = 'Check'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Imagemain: TImage
    Left = 0
    Top = 0
    Width = 557
    Height = 460
    Visible = False
  end
  object Label5: TLabel
    Left = 104
    Top = 60
    Width = 100
    Height = 16
    Caption = 'Serial Number'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object LabSN: TLabel
    Left = 216
    Top = 60
    Width = 100
    Height = 16
    Caption = 'Serial Number'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object LabPart: TLabel
    Left = 216
    Top = 84
    Width = 29
    Height = 16
    Caption = 'Part'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label6: TLabel
    Left = 104
    Top = 84
    Width = 53
    Height = 16
    Caption = 'Part No'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label2: TLabel
    Left = 104
    Top = 138
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
  object Label3: TLabel
    Left = 104
    Top = 275
    Width = 91
    Height = 16
    Caption = 'Cust Part No '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label7: TLabel
    Left = 104
    Top = 228
    Width = 100
    Height = 16
    Caption = 'Serial Number'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label8: TLabel
    Left = 208
    Top = 28
    Width = 162
    Height = 24
    Caption = 'Check CSN+CPN'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Labcustpart: TLabel
    Left = 216
    Top = 108
    Width = 63
    Height = 16
    Caption = 'Cust Part'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label10: TLabel
    Left = 104
    Top = 108
    Width = 87
    Height = 16
    Caption = 'Cust Part No'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object editCSN: TEdit
    Left = 232
    Top = 132
    Width = 265
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
  end
  object editCustPart: TEdit
    Left = 232
    Top = 270
    Width = 265
    Height = 24
    Color = clYellow
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnKeyPress = editCustPartKeyPress
  end
  object sbtnOK: TBitBtn
    Left = 141
    Top = 390
    Width = 75
    Height = 25
    Caption = 'OK'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    Visible = False
    OnClick = sbtnOKClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
  end
  object sbtnCancel: TBitBtn
    Left = 261
    Top = 390
    Width = 75
    Height = 25
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnClick = sbtnCancelClick
    Kind = bkCancel
  end
  object EditSN: TEdit
    Left = 232
    Top = 224
    Width = 265
    Height = 24
    Color = clYellow
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnKeyPress = EditSNKeyPress
  end
  object lstcheckcsnField: TListBox
    Left = 380
    Top = 8
    Width = 113
    Height = 41
    ItemHeight = 13
    TabOrder = 5
    Visible = False
  end
  object lstcheckcsnValue: TListBox
    Left = 380
    Top = 56
    Width = 113
    Height = 41
    ItemHeight = 13
    TabOrder = 6
    Visible = False
  end
  object SProc1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspStoreproc'
    Left = 8
    Top = 72
  end
  object QryTemp1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 8
    Top = 40
  end
  object QryData1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryTemp1'
    Left = 8
    Top = 8
  end
end
