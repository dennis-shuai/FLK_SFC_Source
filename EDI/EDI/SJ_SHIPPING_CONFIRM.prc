CREATE or replace PROCEDURE
sajet.SJ_SHIPPING_CONFIRM(tterminalid in number,TREV IN VARCHAR2,TTYPE IN VARCHAR2,
    TSHIPPINGID IN number,TCONTAINER IN VARCHAR2,TVEHICLE IN VARCHAR2, 
    TWARRANTY IN DATE,TSHIPTO IN VARCHAR2,TEMPID IN number,TNOW date,
    TDNNO in VARCHAR2,TDNITEM in VARCHAR2,TITEMID IN VARCHAR2,TQTY IN NUMBER, 
    TSUBINV IN VARCHAR2, TLOCATOR IN VARCHAR2, TRES OUT VARCHAR2) IS
cnextprocess number;
crouteid number; cShippingID_Tmp number;
clineid number; cstageid number; cprocessid number;
C_ID 	VARCHAR2(25);
C_EDID  VARCHAR2(25);
CCOUNT	NUMBER;
C_DNID	NUMBER;
C_SO	VARCHAR2(25);
C_SOSEQ	VARCHAR2(25);
C_CUST	VARCHAR2(50);
C_CUSTPO VARCHAR2(25);
C_UOM	VARCHAR2(25);
C_HUB	VARCHAR2(25);
C_EDI	VARCHAR2(25);
C_SUBINV VARCHAR2(10);
C_DOC 	VARCHAR2(25);
C_CTN	VARCHAR2(25);
C_KPSN  VARCHAR2(25);
C_TEMP  VARCHAR2(25);
C_SQTY  NUMBER;
C_QTY	NUMBER;

cursor ctn0_cursor is
   select CARTON_NO from sajet.G_SN_STATUS 
    where PALLET_NO = TREV group by CARTON_NO;

ctn0_record ctn0_cursor%rowtype;

cursor ctn_cursor is
   select CARTON_NO, count(*) QTY from sajet.G_SN_STATUS
    where PALLET_NO = TREV group by CARTON_NO order by CARTON_NO;

ctn_record ctn_cursor%rowtype;

cursor sn_cursor is
   select SERIAL_NUMBER, CARTON_NO from sajet.G_SN_STATUS where PALLET_NO = TREV;

sn_record sn_cursor%rowtype;
BEGIN 
   sajet.sj_get_place(tterminalid, clineid, cstageid, cprocessid);
   --¥[¤J G_SHIPPING_SN 
   IF TTYPE = 'Serial Number' THEN
     UPDATE SAJET.G_SHIPPING_SN 
       SET CONTAINER = TCONTAINER, VEHICLE_NO = TVEHICLE, WARRANTY = TWARRANTY,
           CONFIRM_USERID = TEMPID, CONFIRM_TIME = TNOW
           WHERE SERIAL_NUMBER = TREV;          
   ELSIF TTYPE = 'Box' THEN
     UPDATE SAJET.G_SHIPPING_SN 
       SET CONTAINER = TCONTAINER, VEHICLE_NO = TVEHICLE, WARRANTY = TWARRANTY,
           CONFIRM_USERID = TEMPID, CONFIRM_TIME = TNOW
           WHERE BOX_NO = TREV AND SHIPPING_ID = TSHIPPINGID;
   ELSIF TTYPE = 'Carton' THEN
     UPDATE SAJET.G_SHIPPING_SN 
       SET CONTAINER = TCONTAINER, VEHICLE_NO = TVEHICLE, WARRANTY = TWARRANTY,
           CONFIRM_USERID = TEMPID, CONFIRM_TIME = TNOW
           WHERE CARTON_NO = TREV AND SHIPPING_ID = TSHIPPINGID;

     insert into sajet.G_HT_MATERIAL
     select * from sajet.G_MATERIAL where MATERIAL_NO = TREV;

     delete from sajet.G_MATERIAL where MATERIAL_NO = TREV;
   ELSE
     UPDATE SAJET.G_SHIPPING_SN 
       SET CONTAINER = TCONTAINER, VEHICLE_NO = TVEHICLE, WARRANTY = TWARRANTY,
           CONFIRM_USERID = TEMPID, CONFIRM_TIME = TNOW
           WHERE PALLET_NO = TREV AND SHIPPING_ID = TSHIPPINGID;

     BEGIN
        select MATERIAL_NO into C_CTN from sajet.G_MATERIAL where MATERIAL_NO = TREV;

        insert into sajet.G_HT_MATERIAL
        select * from sajet.G_MATERIAL where MATERIAL_NO = TREV;

        delete from sajet.G_MATERIAL where MATERIAL_NO = TREV;
     EXCEPTION
        WHEN OTHERS THEN
           for ctn0_record in ctn0_cursor loop
              C_CTN := ctn0_record.CARTON_NO;

              insert into sajet.G_HT_MATERIAL
              select * from sajet.G_MATERIAL where MATERIAL_NO = C_CTN;

              delete from sajet.G_MATERIAL where MATERIAL_NO = C_CTN;
           end loop;
     END;    
   END IF;	              
   TRES:='OK';
   commit;

-- ***** check Set Qty *****
   C_QTY := TQTY;

   select count(*) into CCOUNT from SAJET.SYS_BASE where PARAM_NAME = 'Set Qty Field';

   IF CCOUNT > 0 THEN
   BEGIN
      select DN_ID into C_DNID from SAJET.G_DN_BASE
       where DN_NO = TDNNO and ROWNUM = 1;

      select to_number(nvl(b.OPTION10, '0')) into C_SQTY from SAJET.G_DN_DETAIL a, SAJET.SYS_PART b
       where a.DN_ID = C_DNID and a.DN_ITEM = TDNITEM and a.PART_ID = b.PART_ID and ROWNUM = 1;

      IF C_SQTY > 1 THEN
         C_QTY := C_QTY / C_SQTY;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         C_QTY := TQTY;
   END;
   END IF;
-- *************************

   select count(*) into CCOUNT from SAJET.MES_TO_ERP_DN_DETAIL
    where DN_NO = TDNNO and DN_SEQ = TDNITEM and ITEM_NO = TITEMID
      and STATUS = 'N' and ROWNUM = 1;

   if CCOUNT = 0 then
      select DN_ID into C_DNID from SAJET.G_DN_BASE
       where DN_NO = TDNNO and ROWNUM = 1;

      select SO_NO, SO_ITEM, CUSTOMER, CUST_PO, UOM, HUB_FLAG, EDI_FLAG, TRANSFER_SUBINV
        into C_SO, C_SOSEQ, C_CUST, C_CUSTPO, C_UOM, C_HUB, C_EDI, C_SUBINV
        from SAJET.G_DN_DETAIL
       where DN_ID = C_DNID and DN_ITEM = TDNITEM and ROWNUM = 1;

      SAJET.MES_PUSH_TITLE_GET_ID('F1', C_ID);

      insert into SAJET.MES_TO_ERP_DN_DETAIL
             (DN_NO, DN_SEQ, SO_NO, SO_SEQ, CUSTOMER, CUST_PO, ITEM_NO, UOM,
              QUANTITY, HUB_FLAG, EDI_FLAG, CHECK_CODE, USER_ID, SEQ_ID, TRANSFER_SUBINV)
      values (TDNNO, TDNITEM, C_SO, C_SOSEQ, C_CUST, C_CUSTPO, TITEMID, C_UOM,
              C_QTY, C_HUB, C_EDI, C_ID, TEMPID, C_ID, C_SUBINV);
   else
      IF SUBSTR(TREV, 1, 4) = 'FXLP' THEN
         SAJET.MES_PUSH_TITLE_GET_ID('F1', C_ID);
      END IF;

      update SAJET.MES_TO_ERP_DN_DETAIL set QUANTITY = QUANTITY + C_QTY
       where DN_NO = TDNNO and DN_SEQ = TDNITEM and ITEM_NO = TITEMID and STATUS = 'N' and ROWNUM = 1;

   end if;

   TRES:='OK';
   COMMIT;

   IF SUBSTR(TREV, 1, 4) = 'FXLP' THEN
      C_DOC := 'STXSH'||TDNNO;

      C_EDID := SUBSTR(C_ID,5,9);

      BEGIN
         select DOC_ID into C_TEMP from b2b.ASN_OUT_PALLET where DOC_ID = C_DOC and ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS THEN
            insert into b2b.ENVELOPE
                   (DOC_ID, SENDER_ID, RECEIVER_ID, DIRECTION, B2B_MSG_TYPE, DATASOURCE, DOC_DATETIME, TRANS_FLAG, SEQ_ID)
            values (C_DOC, '657200226', '098533326', 'OUT', '856', 'EDI', TNOW, 'N', C_EDID);

            insert into b2b.ASN_OUT_HEADER
                   (DOC_ID, SENDER_ID, RECEIVER_ID, SHIPPER_NUMBER, SHIP_CREATE_DATE, ACTUAL_SHIP_DATE, SEQ_ID)
            values (C_DOC, '657200226', '098533326', TDNNO, TNOW, TNOW, C_EDID);
      END;

      insert into b2b.ASN_OUT_PALLET
             (DOC_ID, PALLET_ID, SEQ_ID)
      values (C_DOC, TREV, C_EDID);

      for ctn_record in ctn_cursor loop
         C_CTN := ctn_record.CARTON_NO;

         insert into b2b.ASN_OUT_CARTON
                (DOC_ID, PALLET_ID, CARTON_ID, SEQ_ID)
         values (C_DOC, TREV, C_CTN, C_EDID);

         insert into b2b.ASN_OUT_ITEMS
                (DOC_ID, CARTON_ID, QUANTITY, SEQ_ID)
         values (C_DOC, C_CTN, ctn_record.QTY, C_EDID);
      end loop;

      for sn_record in sn_cursor loop
      BEGIN
         select ITEM_PART_SN into C_KPSN from sajet.g_sn_keyparts
          where SERIAL_NUMBER = sn_record.SERIAL_NUMBER and ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS THEN
            C_KPSN := sn_record.SERIAL_NUMBER;
      END;

         insert into b2b.ASN_OUT_SERIAL
                (DOC_ID, CARTON_ID, SERIAL_NUMBER, MFR_DATE, SEQ_ID)
         values (C_DOC, sn_record.CARTON_NO, C_KPSN, TNOW, C_EDID);
      end loop;
      
      COMMIT;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    TRES:='SJ_SHIPPING_PACK ERROR'; 
	ROLLBACK;
END;

