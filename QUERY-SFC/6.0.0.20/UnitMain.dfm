object FormMain: TFormMain
  Left = 223
  Top = 174
  Width = 696
  Height = 480
  BorderIcons = [biSystemMenu]
  Caption = 'FormMain'
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object MainMenu1: TMainMenu
    Left = 16
    Top = 8
    object MATERIAL1: TMenuItem
      Caption = 'MATERIAL'
      object byWO1: TMenuItem
        Caption = #30332#26009'(CHECK)'#26597#35426'by WO'
        OnClick = byWO1Click
      end
      object CONFIRMbyWO1: TMenuItem
        Caption = #30332#26009'[CONFIRM]'#26597#35426'by WO'
        OnClick = CONFIRMbyWO1Click
      end
      object byWO2: TMenuItem
        Caption = #36864#26009#26597#35426'by WO'
        OnClick = byWO2Click
      end
      object N2: TMenuItem
        Caption = #30064#21205#26597#35426
        object ByIDNO1: TMenuItem
          Caption = 'By ID_NO'
          OnClick = ByIDNO1Click
        end
        object ByPartNO1: TMenuItem
          Caption = 'By Part_NO'
          OnClick = ByPartNO1Click
        end
      end
    end
    object INTERFACE1: TMenuItem
      Caption = 'INTERFACE'
      object WOERPSFC1: TMenuItem
        Caption = 'WO-BOM(ERP->SFC)'
        OnClick = WOERPSFC1Click
      end
    end
    object WIP1: TMenuItem
      Caption = 'WIP'
      object N1: TMenuItem
        Caption = #23792#20301#26597#35426
        OnClick = N1Click
      end
    end
    object EDI1: TMenuItem
      Caption = 'EDI'
      object IN8561: TMenuItem
        Caption = 'IN-856'
        OnClick = IN8561Click
      end
      object IN8611: TMenuItem
        Caption = '861-OUT'
        OnClick = IN8611Click
      end
      object PT8671: TMenuItem
        Caption = 'PT-867'
        OnClick = PT8671Click
      end
      object OUT8561: TMenuItem
        Caption = 'OUT-856'
        OnClick = OUT8561Click
      end
      object QueryHDDSNBYDN1: TMenuItem
        Caption = 'Query HDD SN BY DN'
        OnClick = QueryHDDSNBYDN1Click
      end
    end
    object OOLING1: TMenuItem
      Caption = 'Tooling'
      object Feefer1: TMenuItem
        Caption = 'Feefer'
        OnClick = Feefer1Click
      end
      object Feeder1: TMenuItem
        Caption = 'Feeder'#20445#39178#21295#32317#22577#34920
        OnClick = Feeder1Click
      end
      object Feeder2: TMenuItem
        Caption = 'Feeder'#32173#20462#21295#32317#22577#34920
        OnClick = Feeder2Click
      end
    end
    object Repair2: TMenuItem
      Caption = 'Repair'
      object RepairresultforRepair1: TMenuItem
        Caption = 'Repair result for Repair'
        OnClick = RepairresultforRepair1Click
      end
      object Repairresultforqc1: TMenuItem
        Caption = 'Repair result for qc'
        OnClick = Repairresultforqc1Click
      end
    end
    object QC2: TMenuItem
      Caption = 'QC'
      object QCQuerybyWO2: TMenuItem
        Caption = 'QC Query by WO'
        OnClick = QCQuerybyWO2Click
      end
      object QCDIRQuery2: TMenuItem
        Caption = 'QC DIR Query'
        OnClick = QCDIRQuery2Click
      end
    end
    object Close1: TMenuItem
      Caption = 'Close'
      OnClick = Close1Click
    end
  end
  object SocketConnection1: TSocketConnection
    ServerGUID = '{AF550BF4-3BA4-415D-B1F3-E2F7C8ADE30C}'
    ServerName = 'SajetApserver.RMDB'
    ObjectBroker = SimpleObjectBroker1
    Left = 16
    Top = 40
  end
  object SimpleObjectBroker1: TSimpleObjectBroker
    LoadBalanced = True
    Left = 56
    Top = 40
  end
  object Clientdataset1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DspQryFTemp'
    RemoteServer = SocketConnection1
    Left = 104
    Top = 40
  end
end
