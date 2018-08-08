unit uModelDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DB, DBClient,DateUtils, TeeProcs, TeEngine, Chart,Series,
  DbChart;

type
  TModelDetail = class(TForm)
    Chart1: TDBChart;
    Chart2: TDBChart;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    stemp,sProcess:string;
    sDefectCode1,sDefectCode2,sDefectCode3,sQTY1,sQTY2,sQTY3,sDateTime1,sDateTime2,sDateTime3: TStringList;
    procedure QueryTop3DEFECT(QryTemp:TClientDataSet);
    procedure QuerySPY(QryTemp:TClientDataSet);
  end;

var
  ModelDetail: TModelDetail;


implementation

uses MainForm;

{$R *.dfm}

procedure TModelDetail.QuerySPY(QryTemp:TClientDataSet);
begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp.Params.CreateParam(ftstring,'Pdline',ptInput);
    QryTemp.CommandText := ' SELECT  '+sTemp+' DATETIME,WORK_TIME '+
                            ' from ( '+
                            ' SELECT PROCESS_NAME,PROCESS_CODE,DATETIME ,WORK_TIME, '+
                            ' decode (NVL(SUM(PASS_QTY)+SUM(FAIL_QTY),0),0,1,NVL(SUM(PASS_QTY)+SUM(NTF_QTY),0)/NVL(SUM(PASS_QTY)+SUM(FAIL_QTY),0))*100 as "SPY" '+
                            ' from (  '+
                            ' select C.PDLINE_NAME ,b.PROCESS_NAME,b.PROCESS_CODE,to_char(WORK_DATE)||TRIM(to_CHAR(WORK_TIME,''00'')) as "DATETIME", '+
                            '  A.WORK_TIME,   A.PASS_QTY,A.FAIL_QTY,A.NTF_QTY  from SAJET.G_SN_COUNT a,'+
                            ' SAJET.SYS_PROCESS b,SAJET.SYS_PDLINE c ,  SAJET.SYS_PDLINE_MONITOR_BASE d   ,sajet.SYS_Process e '+
                            ' where A.PDLINE_ID =C.PDLINE_ID and A.PROCESS_ID =b.PROCESS_ID   and d.Process_ID = e.Process_ID '+
                            ' and b.PROCESS_COde <=e.PROCESS_Code  and a.PDLINE_ID =d.PDLINE_ID ) '+
                            ' where  DATETIME >= :StartTime  and DATETIME <=:EndTime  '+
                            ' AND PROCESS_NAME IN ('+ sProcess+')'+
                            ' group by  PROCESS_NAME,PROCESS_CODE,DATETIME, WORK_TIME '+
                            ' ORDER BY WORK_TIME,PROCESS_CODE) group by DATETIME,WORK_TIME order by DATETIME ' ;
    QryTemp.Params.ParamByName('StartTime').AsString :=uMainForm.sStartTime;
    QryTemp.Params.ParamByName('EndTime').AsString :=uMainForm.sEndTime;
    QryTemp.Open;

end;

procedure TModelDetail.QueryTop3DEFECT(QryTemp:TClientDataSet);
begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp.Params.CreateParam(ftstring,'Pdline',ptInput);
    QryTemp.CommandText := ' select * from (select DATETIME,DEFECT_CODE ,SUM(DEFECT_QTY) QTY , row_number()'+
                           ' over(partition by DATETIME order by SUM(DEFECT_QTY) desc)  RAN  from  '+
                           ' ( select PDLINE_NAME,SERIAL_NUMBER, decode(substr(DEFECT_CODE,1,3) ,''SFR'' ,''SFR'',defect_CODE) as "DEFECT_CODE"  '+
                           ' ,DEfect_QTY,DAteTIme,TIME from ( '+
                           ' select c.pdline_NAME, a.Serial_number  ,B.DEFECT_CODE , a.RP_STATUS,a.NTF_TIME, to_CHAR(a.REC_TIME,''YYYYMMDDHH24'' ) as "DATETIME", ' +
                           ' to_NUMBER(to_char(a.REC_TIME,''YYYY'')) as "DATE",  '  +
                           ' to_Number(to_CHAR(a.REC_TIME,''HH24'')) AS "TIME", a.defect_QTY'   +
                           ' FROM sajet.g_SN_defect_first a,SAJET.SYS_DEFECT B,SAJET.SYS_PDLINE C  '   +
                           ' where a.PDLINE_ID =c.PDLINE_ID and a.defect_ID =B.DEFECT_ID  and NTF_TIME is  null and a.rec_TIME >=to_date(:StartTime, ' +
                           ' ''yyyymmddhh24miss'') '+
                           ' and a.rec_TIME <to_date(:EndTime,''yyyymmddhh24miss'' ) '+
                           ' order by datetime,c.pdline_NAME,a.Serial_number  ) ) ' +
                           ' group by    DATETIME  ,DEFECT_CODE )where ran<=3 ';
    QryTemp.Params.ParamByName('StartTime').AsString :=uMainForm.sStartTime+'0000';
    QryTemp.Params.ParamByName('EndTime').AsString :=uMainForm.sEndDateTime+'0000';
    QryTemp.Open;
end;
procedure TModelDetail.FormCreate(Sender: TObject);
begin
     if (Screen.Width =1360) or (Screen.Width =1366) then begin
         width :=1070;
         height :=680;
     end;

     if (Screen.Width =1440) or (Screen.Width =1400) then begin
         width :=1141;
         height :=780;
     end;

     if Screen.Width =1600 then begin
         width :=1284;
         height :=770;
     end;
end;

procedure TModelDetail.FormShow(Sender: TObject);
var i,j,SeriesCount,Count,row:integer;
    xValue,yValue : double;
    stempProcess,stempTime:string;
    datetime:TDateTime;
begin

    with uMainForm.QryData do begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'PDLINE_NAME',ptInput);
        CommandText := ' select distinct d.PRocess_Name,d.PROCESS_ID,E.PARAM_VALUE '
                     + ' from sajet.sys_Pdline_shift_Base a,SAJET.SYS_PDLINE_SHIFT_PARAM  b,'
                     + ' SAJET.SYS_PDLINE c,sajet.sys_process d,SAJET.SYS_PDLINE_SHIFT_PARAM  E '
                     + ' where  A.REC_ID =B.REC_ID and E.REC_ID = A.REC_ID AND B.PARAM_TYPE=''PROCESS'' '
                     + ' and A.PDLINE_ID=C.PDLINE_ID and B.PARAM_NAME =D.PROCESS_ID '
                     + ' AND   B.PARAM_NAME = E.PARAM_NAME(+) AND   E.PARAM_TYPE=''SEQ'' '
                     + ' and C.PDLINE_Name =:PDLINE_NAME and D.ENABLED =''Y''  '
                     + ' and  A.ACTIVE_FLAG=''Y'' ORDER BY E.PARAM_VALUE ';
        Params.ParamByName('PDLINE_NAME').AsString := uMainForm.sCurrentPDline;
        Open;
    end;

    SeriesCount:=0;
    if uMainForm.QryData.IsEmpty then  begin
        sTemp:='' ;
        exit;
    end;

     uMainForm.QryData.First;
     SeriesCount:= uMainForm.QryData.RecordCount-1;


     Chart1.Title.Font.Size :=16;
     Chart1.Title.Font.Style:=  [fsBold];
     Chart1.Title.Text.Strings[0] := uMainForm.sCurrentModel +' Yield Detail';
     Chart2.Title.Font.Size :=16;
     Chart2.Title.Font.Style:=  [fsBold];
     Chart2.Title.Text.Strings[0] := uMainForm.sCurrentModel +' Top 3 Defect Detail';
   for i:=0 to 2 do   Chart2.AddSeries(TBarSeries.Create(Self));
   Chart2.Legend.Visible :=false;
   

   for i:=0 to SeriesCount do begin
        stempProcess:= uMainForm.QryData.fieldbyname('PROCESS_NAME').AsString;
        sTemp := sTemp +'NVL(MAX(decode(PROCESS_NAME,'''+stempProcess +
              ''' ,SPY,NULL)),100) as "'+stempProcess+'",';
        sProcess :=sProcess+ ''''+stempProcess+''',' ;
        Chart1.AddSeries(TBarSeries.Create(Self));
        Chart1.Series[i].Title :=  stempProcess;
        uMainForm.QryData.Next;
   end;
   sProcess :=Copy(sProcess,1, length(sProcess)-1);

    QuerySPY(uMainForm.QryData);
    Count :=  uMainForm.QryData.RecordCount;
    Chart1.Series[0].XValues.DateTime:=true;
    Chart2.Series[0].XValues.DateTime:=true;
    if Count > 0 then begin
        for i:=0 to SeriesCount do begin

                uMainForm.QryData.First;
                for j:=0 to Count-1 do begin
                   stempTime := uMainForm.QryData.Fields.Fields[SeriesCount+1].AsString;
                   xValue :=encodeDateTime( StrToInt(copy(stempTime,1,4)),StrToInt(copy(stempTime,5,2)),StrToInt(copy(stempTime,7,2)),StrToInt(copy(stempTime,9,2)),00,00,00);
                   yValue := uMainForm.QryData.Fields.Fields[i].AsFloat;

                   Chart1.Series[i].AddXY(xValue,yValue);
                   uMainForm.QryData.Next;
                end;

        end;
    end;


      QueryTop3DEFECT( uMainForm.QryData);


      if   uMainForm.QryData.isempty then exit;
      sDefectCode1 := TStringList.Create;
      sQty1:= TStringList.Create;
      sDateTime1 := TStringList.Create;
      sDefectCode2 := TStringList.Create;
      sQty2:= TStringList.Create;
      sDateTime2 := TStringList.Create;
      sDefectCode3 := TStringList.Create;
      sQty3:= TStringList.Create;
      sDateTime3 := TStringList.Create;
      uMainForm.QryData.First;

      for i:=0 to uMainForm.QryData.RecordCount-1 do begin
          row :=  uMainForm.QryData.fieldbyname('RAN').AsInteger;
          if  row =1 then  begin
               sDefectCode1.Add(uMainForm.QryData.fieldbyname('DEFECT_CODE').AsString) ;
               sQty1.Add(uMainForm.QryData.fieldbyname('QTY').AsString) ;
               sDateTime1.Add(uMainForm.QryData.fieldbyname('DATETIME').AsString) ;
          end else  if  row =2 then begin
                sDefectCode2.Add(uMainForm.QryData.fieldbyname('DEFECT_CODE').AsString) ;
                sQty2.Add(uMainForm.QryData.fieldbyname('QTY').AsString) ;
                sDateTime2.Add(uMainForm.QryData.fieldbyname('DATETIME').AsString) ;
          end  else  if  row =3 then begin
                sDefectCode3.Add(uMainForm.QryData.fieldbyname('DEFECT_CODE').AsString) ;
                sQty3.Add(uMainForm.QryData.fieldbyname('QTY').AsString) ;
                sDateTime3.Add(uMainForm.QryData.fieldbyname('DATETIME').AsString) ;
          end;
          uMainForm.QryData.Next;
      end;


      for i:=0 to  sDefectCode1.Count -1 do begin
            xValue :=encodeDateTime( StrToInt(copy(sDateTime1.Strings[i],1,4)),StrToInt(copy(sDateTime1.Strings[i],5,2)),StrToInt(copy(sDateTime1.Strings[i],7,2)),
                          StrToInt(copy(sDateTime1.Strings[i],9,2)),00,00,00);
            Chart2.Series[0].AddXY(xValue,StrToInt(sQty1.Strings[i]) , sDefectCode1.Strings[i]+'/'+sQty1.Strings[i]+'pcs' );
      end;

      for i:=0 to  sDefectCode2.Count -1 do begin
           xValue :=encodeDateTime( StrToInt(copy(sDateTime2.Strings[i],1,4)),StrToInt(copy(sDateTime2.Strings[i],5,2)),StrToInt(copy(sDateTime2.Strings[i],7,2)),
                          StrToInt(copy(sDateTime2.Strings[i],9,2)),00,00,00);
           Chart2.Series[1].AddXY(xValue ,StrToInt(sQty2.Strings[i]), sDefectCode2.Strings[i]+'/'+sQty2.Strings[i]+'pcs' );
      end;

      for i:=0 to  sDefectCode3.Count -1 do begin
          xValue :=encodeDateTime( StrToInt(copy(sDateTime3.Strings[i],1,4)),StrToInt(copy(sDateTime3.Strings[i],5,2)),StrToInt(copy(sDateTime3.Strings[i],7,2)),
                          StrToInt(copy(sDateTime3.Strings[i],9,2)),00,00,00);
          Chart2.Series[2].AddXY(xValue ,StrToInt(sQty3.Strings[i]), sDefectCode3.Strings[i] +'/'+sQty3.Strings[i]+'pcs' );
      end;

      Chart1.LeftAxis.Title.Caption :='Yield(%)';
      Chart1.LeftAxis.Title.Font.Size :=12;
      Chart1.LeftAxis.Title.Font.Style :=[fsBold];
      Chart2.LeftAxis.Title.Caption :='Defect Qty(PCS)';
      Chart2.LeftAxis.Title.Font.Size :=12;
      Chart2.LeftAxis.Title.Font.Style :=[fsBold];

      sDefectCode1.Free;
      sQty1.Free;
      sDateTime1.Free;
      sDefectCode2.Free;
      sQty2.Free;
      sDateTime2.Free;
      sDefectCode3.Free;
      sQty3.Free;
      sDateTime3.Free;

end;

procedure TModelDetail.FormKeyPress(Sender: TObject; var Key: Char);
begin
    if Key=#27 then ModelDetail.Close;
end;

end.
