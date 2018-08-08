object FormMain: TFormMain
  Left = 392
  Top = 252
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Blob File Upload Oracle Design:Xiaobo_Yuan'
  ClientHeight = 288
  ClientWidth = 433
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 433
    Height = 201
    Align = alTop
    Caption = 'LabelView Upload'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    object Label1: TLabel
      Left = 48
      Top = 21
      Width = 46
      Height = 13
      Caption = 'SKU_No:'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      OnClick = Label1Click
    end
    object Label3: TLabel
      Left = 32
      Top = 133
      Width = 59
      Height = 13
      Caption = 'PassWord:'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 8
      Top = 173
      Width = 85
      Height = 13
      Caption = 'LabelFile_Path:'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label8: TLabel
      Left = 28
      Top = 56
      Width = 64
      Height = 13
      Alignment = taRightJustify
      Caption = 'W/O Type:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label5: TLabel
      Left = 32
      Top = 93
      Width = 57
      Height = 13
      Caption = 'File_Type:'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Edit1: TEdit
      Left = 104
      Top = 16
      Width = 177
      Height = 24
      CharCase = ecUpperCase
      Color = clYellow
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnChange = Edit1Change
      OnKeyPress = Edit1KeyPress
    end
    object EditPassWord: TEdit
      Left = 104
      Top = 128
      Width = 177
      Height = 24
      Color = clYellow
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      PasswordChar = '*'
      TabOrder = 1
    end
    object edtFile: TEdit
      Left = 104
      Top = 168
      Width = 265
      Height = 24
      Color = clYellow
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ReadOnly = True
      TabOrder = 2
    end
    object Button7: TButton
      Left = 376
      Top = 168
      Width = 49
      Height = 25
      Caption = #28687#35261
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = Button7Click
    end
    object ButtonUpload: TButton
      Left = 288
      Top = 128
      Width = 75
      Height = 25
      Caption = 'Uploading'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      OnClick = ButtonUploadClick
    end
    object ButtonDel: TButton
      Left = 288
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Delete'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      OnClick = ButtonDelClick
    end
    object cmbType: TComboBox
      Left = 104
      Top = 50
      Width = 177
      Height = 24
      Color = clYellow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ItemHeight = 16
      ParentFont = False
      TabOrder = 6
    end
    object ComboFileType: TComboBox
      Left = 104
      Top = 90
      Width = 177
      Height = 24
      Style = csDropDownList
      Color = clYellow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ItemHeight = 16
      ParentFont = False
      TabOrder = 7
      OnChange = ComboFileTypeChange
      Items.Strings = (
        '.lbl'
        '.lab')
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 201
    Width = 433
    Height = 87
    Align = alClient
    Caption = 'Picture Upload'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    object Label4: TLabel
      Left = 15
      Top = 21
      Width = 71
      Height = 13
      Alignment = taRightJustify
      Caption = 'Color_Name:'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label6: TLabel
      Left = 9
      Top = 61
      Width = 76
      Height = 13
      Alignment = taRightJustify
      Caption = 'Picture_Path:'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object edtCorlorN: TEdit
      Left = 88
      Top = 16
      Width = 177
      Height = 24
      Color = clYellow
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
    end
    object edtColorPath: TEdit
      Left = 88
      Top = 56
      Width = 273
      Height = 24
      Color = clYellow
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
    end
    object btnBrowse: TButton
      Left = 368
      Top = 56
      Width = 57
      Height = 25
      Caption = #28687#35261
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = btnBrowseClick
    end
    object btnColorUpload: TButton
      Left = 352
      Top = 16
      Width = 73
      Height = 25
      Caption = 'Uploading'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = btnColorUploadClick
    end
    object btnColorDel: TButton
      Left = 272
      Top = 16
      Width = 73
      Height = 25
      Caption = 'Delete'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      OnClick = btnColorDelClick
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 
      'LabelFile(*.lbl)|*.lbl|CodSoft File(*.lab)|*.lab|JPG(*.jpg)|*.jp' +
      'g'
    Left = 32
    Top = 24
  end
end
