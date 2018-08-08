program ProjectKEY;

uses
  Forms,
  UnitMain in 'UnitMain.pas' {FormMain},
  UnitdataModule in 'UnitdataModule.pas' {DataModule1: TDataModule},
  UnitQueryCheckMaterialByWO in 'UnitQueryCheckMaterialByWO.pas' {FormQueryCheckMaterialByWO},
  UnitQueryConfirmMaterialByWO in 'UnitQueryConfirmMaterialByWO.pas' {FormQueryConfirmMaterialByWO},
  UnitQUERYWOBOMERPTOSFC in 'UnitQUERYWOBOMERPTOSFC.pas' {FormQUERYWOBOMERPTOSFC},
  UnitQueryReturnMaterialByWO in 'UnitQueryReturnMaterialByWO.pas' {FormReturnMaterialByWO},
  UnitEDIIN856Query in 'UnitEDIIN856Query.pas' {FormEDIIN856Query},
  UnitWIPVerQuery in 'UnitWIPVerQuery.pas' {FormWIPverQuery},
  UnitEDIIN861Query in 'UnitEDIIN861Query.pas' {FormEDIIN861Query},
  UnitEDIPT867Query in 'UnitEDIPT867Query.pas' {FormEDIPT867},
  UnitEDIOUT856Query in 'UnitEDIOUT856Query.pas' {FormOut856},
  UnitMaterialYDQuerybyIDNO in 'UnitMaterialYDQuerybyIDNO.pas' {FormYDQueryByIDNO},
  UnitMaterialYDQuerybyPartNO in 'UnitMaterialYDQuerybyPartNO.pas' {FormYDQueryBYPartNO},
  UnitWIPqcquery in 'UnitWIPqcquery.pas' {FormWIPQCQuery},
  UnitToolingFeederquery in 'UnitToolingFeederquery.pas' {FormToolingFeeder},
  Unittoolingfeederbaoyangquery in 'Unittoolingfeederbaoyangquery.pas' {Formfeederbaoyangquery},
  Unittoolingfeederrepairquery in 'Unittoolingfeederrepairquery.pas' {Formfeederrepairquery},
  UnitwipRepairresultquery in 'UnitwipRepairresultquery.pas' {FormRepairResultQuery},
  UnitWIPQCDIRQuery in 'UnitWIPQCDIRQuery.pas' {FormWIPQCDIRquery},
  UnitWIPRepairresultQueryForQC in 'UnitWIPRepairresultQueryForQC.pas' {FormWipRepairresultforQC},
  UnitEDITQueryHDDSNBYDNNO in 'UnitEDITQueryHDDSNBYDNNO.pas' {FormEdiqueryhddsnbyDNNO};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TFormQueryCheckMaterialByWO, FormQueryCheckMaterialByWO);
  Application.CreateForm(TFormQueryConfirmMaterialByWO, FormQueryConfirmMaterialByWO);
  Application.CreateForm(TFormQUERYWOBOMERPTOSFC, FormQUERYWOBOMERPTOSFC);
  Application.CreateForm(TFormReturnMaterialByWO, FormReturnMaterialByWO);
  Application.CreateForm(TFormEDIIN856Query, FormEDIIN856Query);
  Application.CreateForm(TFormWIPverQuery, FormWIPverQuery);
  Application.CreateForm(TFormEDIIN861Query, FormEDIIN861Query);
  Application.CreateForm(TFormEDIPT867, FormEDIPT867);
  Application.CreateForm(TFormOut856, FormOut856);
  Application.CreateForm(TFormYDQueryByIDNO, FormYDQueryByIDNO);
  Application.CreateForm(TFormYDQueryBYPartNO, FormYDQueryBYPartNO);
  Application.CreateForm(TFormWIPQCQuery, FormWIPQCQuery);
  Application.CreateForm(TFormToolingFeeder, FormToolingFeeder);
  Application.CreateForm(TFormfeederbaoyangquery, Formfeederbaoyangquery);
  Application.CreateForm(TFormfeederrepairquery, Formfeederrepairquery);
  Application.CreateForm(TFormRepairResultQuery, FormRepairResultQuery);
  Application.CreateForm(TFormWIPQCDIRquery, FormWIPQCDIRquery);
  Application.CreateForm(TFormWipRepairresultforQC, FormWipRepairresultforQC);
  Application.CreateForm(TFormEdiqueryhddsnbyDNNO, FormEdiqueryhddsnbyDNNO);
  Application.Run;
end.
