unit uSetting;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,IniFiles, Menus, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect;

type
  TuSettings = class(TForm)
    Label1: TLabel;
    lblPDLINE: TLabel;
    Label2: TLabel;
    edtHour: TEdit;
    Label3: TLabel;
    edtUPH: TEdit;
    Label4: TLabel;
    edtQty: TEdit;
    Image1: TImage;
    btnCopyLine: TSpeedButton;
    Image2: TImage;
    btnCopyToLine: TSpeedButton;
    ImageAll: TImage;
    btnSave: TSpeedButton;
    Image3: TImage;
    cmbPdline: TComboBox;
    SpeedButton3: TSpeedButton;
    Image4: TImage;
    chkIsRepair: TCheckBox;
    pnlStatus: TPanel;
    SpeedButton1: TSpeedButton;
    Image5: TImage;
    Label5: TLabel;
    cmbModel: TComboBox;
    Label6: TLabel;
    ListView1: TListView;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    pnlTime: TPanel;
    pnlTime7: TPanel;
    pnlTime1: TPanel;
    pnlTime2: TPanel;
    pnlTime3: TPanel;
    pnlTime8: TPanel;
    pnlTime9: TPanel;
    pnlTime4: TPanel;
    pnlTime10: TPanel;
    pnlTime5: TPanel;
    pnlTime6: TPanel;
    pnlTime11: TPanel;
    pnlTime12: TPanel;
    edtTime1: TEdit;
    edtTime2: TEdit;
    edtTime3: TEdit;
    edtTime4: TEdit;
    edtTime5: TEdit;
    edtTime6: TEdit;
    edtTime7: TEdit;
    edtTime8: TEdit;
    edtTime9: TEdit;
    edtTime10: TEdit;
    edtTime11: TEdit;
    edtTime12: TEdit;
    procedure FormShow(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCopyLineClick(Sender: TObject);
    procedure btnCopyToLineClick(Sender: TObject);
    procedure pnlStatusDblClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure chkIsRepairClick(Sender: TObject);
    procedure pnlTime1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure cmbModelSelect(Sender: TObject);
    procedure edtTime1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
      sPd_Status,sWorkHour,IsRepair:string;
      procedure LoadImage;
      function SaveLine(pdlineName:string):string;
  end;

var
  uSettings: TuSettings;

implementation

uses uDetail;

{$R *.dfm}

procedure TuSettings.LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create(ExtractFilePath(Application.ExeName)+'BackGround.Ini');
  sImage := pIni.ReadString('WOManager', 'BackGround', ExtractFilePath(Application.ExeName)+'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    ImageAll.Picture.LoadFromFile(sImage);
end;


procedure TuSettings.FormShow(Sender: TObject);
var i:integer;
begin
   LoadImage;
   with fDetail.QryTemp do begin
       close;
       params.Clear;
       commandtext:= 'select * from sajet.sys_model where enabled=''Y'' order by Model_name';
       open;
      // cmbModel.Text:='';
       cmbModel.Items.Clear;
       first;
       for i:=0 to recordcount-1 do begin
          cmbModel.Items.Add(fieldbyname('Model_Name').AsString) ;
          next;
       end;
   end;
   Listview1.ViewStyle:=vsreport;
   Listview1.GridLines:=true;

 

end;

procedure TuSettings.SpeedButton3Click(Sender: TObject);
begin
    edtQty.Text := IntToStr(Round(StrToFloat(edtHour.Text)*StrToFloat(edtUPH.Text)));
end;

procedure TuSettings.btnSaveClick(Sender: TObject);
var i,J:integer;
    k,iHour :double;
    irowid:string;
begin
      if fDetail.iPrivilege <=0 then exit;

      if pnlstatus.Color  = cl3DDKshadow  then begin
           MessageDlg('請安排線體顏色',mterror,[mbok],0);
           exit;
      end;


      if cmbModel.Text ='' then begin
          MessageDlg('機種名沒有選擇',mterror,[mbok],0);
          exit;
      end;
     iHour :=0;

     for i:=0 to  Listview1.Items.Count-1 do begin
         if  Listview1.Items.Item[i].Caption = cmbModel.Text then begin
              Listview1.Items.Delete(i);
              break;
         end;
     end;
    {
    For i:=0 to Listview1.Items.Count Do
     If ListView1.Items[i].Selected then //i=ListView1.Selected.index
     begin
         if ListView1.Items[i].SubItems[6] <>'' then
              with fDetail.QryTemp do begin
                    Close;
                    Params.Clear;
                    Params.CreateParam(ftstring,'srowid',ptInput);
                    CommandText := 'Delete FROM SAJET.G_PDLINE_MANAGE WHERE rowid=:srowid ';
                    Params.ParamByName('srowid').AsString := ListView1.Items[i].SubItems[6];
                    Execute;
              end;

         ListView1.Items.Delete(i);
         break;
     end;
     }
     J:=Listview1.Items.Count;
     for i:=0 to  j-1 do  begin
      k := StrToFloat(Listview1.Items.Item[i].SubItems[0]);
      iHour:= iHour + k;
     end;

     iHour := iHour +StrToIntDef(edtHour.Text,0);

     if iHour >=12 then begin
         MessageDlg('排班不能超過12小時',mterror,[mbok],0);
         exit;
     end;

     if pnlStatus.Color = clGreen then
         sPd_Status :='1';
     if pnlStatus.Color = clYellow then
         sPd_Status :='1';
     if pnlStatus.Color =cl3DDKShadow then
         sPd_Status :='0';
     if chkIsRepair.Checked then
       IsRepair := 'Y'
     else
       IsRepair :='N';

    iRowid :=SaveLine(lblPdLine.Caption);

    with ListView1.Items.Add do begin
          Caption:= cmbModel.Text;
          subItems.Add(edthour.Text);
          subItems.Add(edtUPH.Text);
          subItems.Add(edtQty.Text);
          if chkIsrepair.Checked then
             subItems.Add('Y')
          else
             subItems.Add('N');
           subItems.Add(sPd_Status);
           subItems.Add(sWorkHour);
           subItems.Add(iRowid);
    end;

    fDetail.btnquery.Click;
end;


function TuSettings.SaveLine(pdlineName:string):string;
var sRes:string;
begin

     with fDetail.Sproc do begin
        close;
        datarequest('SAJET.CCM_UPDATE_PDLINE_MANAGE2');
        fetchparams;
        params.ParamByName('TModel').AsString := cmbModel.Text;
        params.ParamByName('TWORK_DATE').AsString := fDetail.sWorkDate ;
        params.ParamByName('TSHIFT').AsString := fDetail.cmbShift.Text;
        params.ParamByName('TPDLINE_NAME').AsString := pdlineName;
        params.ParamByName('TPD_STATUS').AsString := sPd_Status ;
        params.ParamByName('TWORK_HOUR').AsString := edtHour.Text;
        params.ParamByName('TUPH').AsString := edtUPH.Text;
        params.ParamByName('TPRODUCE_QTY').AsString := edtQty.Text;
        params.ParamByName('TREPAIR_FLAG').AsString := IsRepair;
        params.ParamByName('TEMPID').AsString := fDetail.UpdateUserID;
        params.ParamByName('TAllHours').AsString := sWorkHour;
        execute;
        sRes := params.ParamByName('TRes').AsString ;

        if  sRes <>'OK' then begin
             MessageDlg(sRes,mterror,[MBOK],0);
             exit;
        end;
        result := params.ParamByName('iRowID').AsString
     end;
     
end;

procedure TuSettings.btnCopyLineClick(Sender: TObject);
var cParent :TPanel;
    i,j:integer;
    IsRepair,sRes:string;
begin
   if fDetail.iPrivilege <=0 then exit;
   cParent := TPanel(TPanel(fDetail.FindComponent(lblPdline.Caption)).Parent);
   if Copy(cParent.Name,1,8) <> 'TabSheet' then
   begin

       if pnlStatus.Color = clGreen then
             sPd_Status :='1';
       if pnlStatus.Color = clYellow then
             sPd_Status :='1';
       if pnlStatus.Color =cl3DDKShadow then
             sPd_Status :='0';
       if chkIsRepair.Checked then
           IsRepair := 'Y'
       else
           IsRepair :='N';
        for i:=0 to cParent.ControlCount -1 do
        begin
            if cParent.Controls[i].Visible then
            begin
                with fDetail.qrytemp do
                begin
                     close;
                     Params.Clear;
                     Params.CreateParam(ftstring,'WORKDATE',ptInput);
                     Params.CreateParam(ftstring,'sSHIFT',ptInput);
                     Params.CreateParam(ftstring,'PDLINE',ptInput);
                     CommandText :='DELETE FROM SAJET.G_PDLINE_MANAGE WHERE WORK_DATE =:WORKDATE AND SHIFT_ID =:sSHIFT AND PDLINE_ID = '+
                                   ' (SELECT PDLINE_ID FROM SAJET.SYS_PDLINE WHERE PDLINE_NAME =:PDLINE )';
                     params.ParamByName('WORKDATE').AsString :=  fDetail.sWorkDate  ;
                     params.ParamByName('sSHIFT').AsString := fDetail.sSHIFT_ID;
                     params.ParamByName('PDLINE').AsString := cParent.Controls[i].Name ;
                     execute;

                end;

                for j:=0 to listview1.Items.Count-1 do
                begin
                    with fDetail.Sproc do
                    begin
                        close;
                        datarequest('SAJET.CCM_UPDATE_PDLINE_MANAGE2');
                        fetchparams;
                        params.ParamByName('TMODEL').AsString := ListView1.Items[j].Caption ;
                        params.ParamByName('TWORK_DATE').AsString :=  fDetail.sWorkDate ; ;
                        params.ParamByName('TSHIFT').AsString := fDetail.cmbShift.Text;
                        params.ParamByName('TPDLINE_NAME').AsString := cParent.Controls[i].Name ;
                        params.ParamByName('TPD_STATUS').AsString := ListView1.Items[j].SubItems[4];
                        params.ParamByName('TWORK_HOUR').AsString := ListView1.Items[j].SubItems[0];
                        params.ParamByName('TUPH').AsString :=ListView1.Items[j].SubItems.Strings[1];
                        params.ParamByName('TPRODUCE_QTY').AsString := ListView1.Items[j].SubItems[2];
                        params.ParamByName('TREPAIR_FLAG').AsString := ListView1.Items[j].SubItems[3];
                       // params.ParamByName('TINROWID').AsString := ListView1.Items[j].SubItems[6];
                        params.ParamByName('TEMPID').AsString := fDetail.UpdateUserID;
                        params.ParamByName('TAllHours').AsString := ListView1.Items[j].SubItems[5];
                        execute;
                        sRes := params.ParamByName('TRes').AsString ;

                        if  sRes <>'OK' then
                        begin
                             MessageDlg(sRes,mterror,[MBOK],0);
                             exit;
                        end;
                    end;
                end;
            end;
        end;
   end;
   fDetail.btnquery.Click;
end;

procedure TuSettings.btnCopyToLineClick(Sender: TObject);
begin
     if fDetail.iPrivilege <=0 then exit;
     SaveLine(cmbPdLine.Text);
     fDetail.btnquery.Click;
end;

procedure TuSettings.pnlStatusDblClick(Sender: TObject);
begin
   if pnlStatus.Color =clGreen then
      pnlStatus.Color := cl3DDKShadow
   else if pnlStatus.Color = cl3DDKShadow then
      pnlStatus.Color := clGreen;
end;

procedure TuSettings.SpeedButton1Click(Sender: TObject);
begin
    uSettings.Close;
end;

procedure TuSettings.chkIsRepairClick(Sender: TObject);
begin
   if  not chkIsRepair.Checked then begin
     if pnlStatus.Color =clYellow then begin
         pnlStatus.Color := clGreen;
      end;
   end else
        if pnlStatus.Color =clGreen then
         pnlStatus.Color := clYellow;
      if   chkIsRepair.Checked then
          sPd_Status :='1';

end;

procedure TuSettings.pnlTime1Click(Sender: TObject);
var i : integer;
    j : double;
    sIndex :string;
begin
  if   TPanel(Sender).Color =cl3DDkShadow then
    TPanel(Sender).Color :=clGreen
  else if  TPanel(Sender).Color =clGreen then
     TPanel(Sender).Color :=cl3DDkShadow;
  sWorkHour :='';


  if sWorkHour <> '' then  sWorkhour := Copy(sWOrkHour,1,Length(sWorkHour)-1);
 //
  sIndex:= Copy(TPanel(Sender).Name ,8, length(TPanel(Sender).Name)-7);
  if  strtofloatdef(TEdit(FindComponent( 'edtTime' +sIndex)).Text,0) =0 then
     TEdit(FindComponent( 'edtTime' +sIndex)).Text :='1';

  j:=0;
  for i:=1 to 12 do begin
      if TPANEL(FindComponent('pnlTime'+IntToStr(i))).Color = clGreen then begin
          sWorkHour := sWorkHour+ TPANEL(FindComponent('pnlTime'+IntToStr(i))).Caption+':'
                        +TEdit(FindComponent('edtTime'+IntToStr(i))).Text+',';
          j:= J+ StrToFloat(TEdit(FindComponent('edtTime'+IntToStr(i))).Text) ;
      end;

  end;
  edtHour.Text :=FloatToStr(j);

end;

procedure TuSettings.Delete1Click(Sender: TObject);
var i,j:integer;
begin
  //
    j:= ListView1.Items.Count;
    For i:=0 to J-1 Do
       If ListView1.Items[i].Selected then //i=ListView1.Selected.index
       begin
           if ListView1.Items[i].SubItems[6] <>'' then
                with fDetail.QryTemp do begin
                      Close;
                      Params.Clear;
                      Params.CreateParam(ftstring,'srowid',ptInput);
                      CommandText := 'Delete FROM SAJET.G_PDLINE_MANAGE WHERE rowid=:srowid ';
                      Params.ParamByName('srowid').AsString := ListView1.Items[i].SubItems[6];
                      Execute;
                end;

           ListView1.Items.Delete(i);
           exit;
       end;
end;

procedure TuSettings.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
  var i,j,iPos,iPos1:integer;
      stemp,sTime,shour:string;
begin
  if  Selected then begin
    cmbModel.Text :=Item.Caption ;
    edtHour.Text :=Item.SubItems[0] ;
    edtUPH.Text :=Item.SubItems[1] ;
    edtQty.Text :=Item.SubItems[2] ;
    if Item.SubItems[3]='Y' then
      chkIsRepair.Checked := true
    else
      chkIsRepair.Checked := false;

    if Item.SubItems[4] ='1' then
    begin
     if Item.SubItems[3] ='Y' then
       pnlStatus.Color := clYellow
     else
        pnlStatus.Color := clGreen;
    end
    else   if Item.SubItems[4] ='0' then
        pnlStatus.Color :=   cl3DDkShadow ;
    for i :=0 to 11 do begin
         TPANEL(FindComponent('pnlTime'+IntToStr(i+1))).Color :=cl3DDkShadow;
    end;

    sTemp := Item.SubItems[5] ;
    if sTemp <> '' then begin
        //sTimeList :=TStringList.Create;

        for i :=0 to 11 do begin
           ipos :=pos(',',sTemp);
           if ipos >0 then begin
              sTime := Copy(sTemp,1,ipos-1);
              ipos1 := pos(':',sTime);
              shour :=  Copy(sTime,iPos1+1,length(sTime)-iPos1);
              sTime :=  Copy(sTime,1,iPos1-1);
           end
           else begin
              sTime :=sTemp;
              ipos1 := pos(':',sTime);
              shour :=  Copy(sTime,iPos1+1,length(sTime)-iPos1);
              sTime :=  Copy(sTime,1,iPos1-1);
           end;
           for j:=0 to 11 do begin
              if  TPANEL(FindComponent('pnlTime'+IntToStr(j+1))).caption = sTime then
              begin
                  TPANEL(FindComponent('pnlTime'+IntToStr(j+1))).Color := clGreen;
                  TEdit(FindComponent('edtTime'+IntToStr(j+1))).Text := shour;
              end;
           end;
           stemp:= Copy(sTemp,iPos+1,length(sTemp)-iPos);
        end;
    end ;

  end;
end;

procedure TuSettings.cmbModelSelect(Sender: TObject);
begin
    if (edtUPH.Text ='') or (edtUPH.Text ='0') then begin
       with fDetail.qrytemp do begin
           Close;
           Params.Clear;
           Params.CreateParam(ftstring,'Pdline',ptInput);
           Params.CreateParam(ftstring,'ModelName',ptInput);
           CommandText := ' SELECT UPH FROM SAJET.SYS_PDLINE A,'+
                          ' SAJET.SYS_PDLINE_PROCESS_RATE B ,SAJET.sys_model C '+
                          ' WHERE A.PDLINE_ID =B.PDLINE_ID AND A.PDLINE_NAME =:Pdline and '+
                          ' B.Model_ID=C.Model_ID and c.Model_Name =:modelName ';
           Params.ParamByName('Pdline').AsString :=  lblPDLINE.Caption;
           Params.ParamByName('ModelName').AsString := cmbModel.Text;
           Open;
           if not Isempty then
               edtUPH.Text := fieldByName('UPH').AsString;

       end;

    end;
end;

procedure TuSettings.edtTime1Change(Sender: TObject);
var i:integer;
    j:double;
begin
    j:=0;
    sWorkHour :='';
    for i:=1 to 12 do begin
        if TPANEL(FindComponent('pnlTime'+IntToStr(i))).Color = clGreen then begin
            sWorkHour := sWorkHour+ TPANEL(FindComponent('pnlTime'+IntToStr(i))).Caption+':'
                        +TEdit(FindComponent('edtTime'+IntToStr(i))).Text+',';
            j:= J+ StrToFloatDef(TEdit(FindComponent('edtTime'+IntToStr(i))).Text,0) ;
        end;

    end;
    edtHour.Text :=FloatToStr(j);

end;

end.
