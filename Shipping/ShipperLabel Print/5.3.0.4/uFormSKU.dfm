object FormSKU: TFormSKU
  Left = 507
  Top = 418
  BorderStyle = bsDialog
  Caption = 'Enter Lot_No&Work_Order'
  ClientHeight = 258
  ClientWidth = 425
  Color = clInfoBk
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
    Left = 0
    Top = 8
    Width = 425
    Height = 34
    Alignment = taCenter
    AutoSize = False
    Caption = 'Enter SKU Number'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -29
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    Layout = tlCenter
  end
  object LabNotNo: TLabel
    Left = 82
    Top = 98
    Width = 62
    Height = 19
    Alignment = taRightJustify
    Caption = 'Lot_No:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label2: TLabel
    Left = 98
    Top = 58
    Width = 46
    Height = 19
    Alignment = taRightJustify
    Caption = 'W/O#:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label3: TLabel
    Left = 105
    Top = 138
    Width = 39
    Height = 19
    Alignment = taRightJustify
    Caption = 'Line:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label4: TLabel
    Left = 103
    Top = 178
    Width = 41
    Height = 19
    Alignment = taRightJustify
    Caption = 'Date:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label5: TLabel
    Left = 100
    Top = 218
    Width = 44
    Height = 19
    Alignment = taRightJustify
    Caption = 'EIPN:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object TBarcode: TEdit
    Left = 152
    Top = 96
    Width = 185
    Height = 27
    AutoSize = False
    CharCase = ecUpperCase
    Color = clYellow
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnKeyPress = TBarcodeKeyPress
  end
  object EditWO: TEdit
    Left = 152
    Top = 56
    Width = 185
    Height = 27
    AutoSize = False
    CharCase = ecUpperCase
    Color = clYellow
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnKeyPress = EditWOKeyPress
  end
  object Button1: TButton
    Left = 344
    Top = 216
    Width = 65
    Height = 27
    Caption = 'OK'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Calibri'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnClick = Button1Click
  end
  object edtLine: TEdit
    Left = 152
    Top = 136
    Width = 185
    Height = 27
    AutoSize = False
    CharCase = ecUpperCase
    Color = clYellow
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
  end
  object edtDate: TEdit
    Left = 152
    Top = 176
    Width = 185
    Height = 27
    AutoSize = False
    CharCase = ecUpperCase
    Color = clYellow
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
  end
  object edtEIPN: TEdit
    Left = 152
    Top = 216
    Width = 185
    Height = 27
    AutoSize = False
    CharCase = ecUpperCase
    Color = clYellow
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
  end
end
