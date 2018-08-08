CREATE OR REPLACE PROCEDURE
      SAJET.MES_ERP_WIP_DELIVER(TTYPE IN VARCHAR2, TWO IN VARCHAR2, TQTY IN NUMBER,
  TSUBINV IN VARCHAR2, TLOCATOR IN VARCHAR2, TPUSH IN VARCHAR2, TPALLET IN VARCHAR2, TEMPID IN VARCHAR2, TRES OUT VARCHAR2) AS
C_ID 	VARCHAR2(25);
C_EDID  VARCHAR2(25);
C_ERP	VARCHAR2(1);
CCOUNT	NUMBER;
C_SQTY  NUMBER;
C_QTY	NUMBER;
C_DOC 	VARCHAR2(25);
C_ITEM  VARCHAR2(25);
C_KPSN  VARCHAR2(25);

cursor sn_cursor is
   select SERIAL_NUMBER from sajet.G_SN_STATUS where PALLET_NO = TPALLET;

sn_record sn_cursor%rowtype;

BEGIN
-- ***** check Set Qty *****
   C_QTY := TQTY;

   select count(*) into CCOUNT from SAJET.SYS_BASE where PARAM_NAME = 'Set Qty Field';

   IF CCOUNT > 0 THEN
   BEGIN
      select to_number(nvl(b.OPTION10, '0')) into C_SQTY from SAJET.G_WO_BASE a, SAJET.SYS_PART b
       where a.WORK_ORDER = TWO and a.MODEL_ID = b.PART_ID and ROWNUM = 1;

      IF C_SQTY > 1 THEN
         C_QTY := C_QTY / C_SQTY;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         C_QTY := TQTY;
   END;
   END IF;
-- *************************

  C_ID := 'XX';

  IF TTYPE = 'Semifinished' THEN
     SAJET.MES_PUSH_TITLE_GET_ID('B1', C_ID);
  ELSIF TTYPE = 'Goods' THEN
     SAJET.MES_PUSH_TITLE_GET_ID('C1', C_ID);
  END IF;

  IF C_ID = 'XX' THEN
     TRES := 'TTYPE ERROR ('||TTYPE||')';
  ELSE
     IF TPUSH = 'Y' THEN C_ERP := 'Y';
     ELSE C_ERP := 'N';
     END IF;

     insert into sajet.MES_TO_ERP_WIP_DELIVER
            (work_order, qty, subinv, locator, pallet_no, check_code, to_erp, user_id, seq_id)
     values (TWO, C_QTY, tsubinv, tlocator, TPALLET, C_ID, C_ERP, TEMPID, C_ID);

     update sajet.g_wo_base
        set erp_qty = erp_qty + TQTY
      where work_order = TWO and rownum = 1;

     COMMIT;

     IF SUBSTR(TPALLET, 1, 4) = 'FXLP' THEN 
        SAJET.MES_EDI_GET_ID('PT', C_DOC);

        C_EDID := SUBSTR(C_ID,5,9);

        select a.OPTION7 into C_ITEM from sajet.G_WO_BASE b, sajet.SYS_PART a
         where b.WORK_ORDER = TWO and b.MODEL_ID = a.PART_ID and ROWNUM = 1;

        insert into b2b.ENVELOPE
               (DOC_ID, SENDER_ID, RECEIVER_ID, DIRECTION, B2B_MSG_TYPE, DATASOURCE, DOC_DATETIME, TRANS_FLAG, SEQ_ID)
        values (C_DOC, '657200226', '098533326', 'OUT', '867', 'EDI', SYSDATE, 'N', C_EDID);

        insert into b2b.PT_HEADER
               (DOC_ID, SENDER_ID, RECEIVER_ID, INVENTORY_BATCH_ID, FINISH_DATE, SYSTEM_DATE, SEQ_ID)
        values (C_DOC, '657200226', '098533326', TPALLET, SYSDATE, SYSDATE, C_EDID);

        insert into b2b.PT_ITEMS
               (DOC_ID, WORK_ORDER_NUMBER, TRANSFER_QUANTITY, FG_ITEM_NUMBER, SEQ_ID)
        values (C_DOC, TWO, TQTY, C_ITEM, C_EDID);

        for sn_record in sn_cursor loop
        BEGIN
           select ITEM_PART_SN into C_KPSN from sajet.g_sn_keyparts
            where SERIAL_NUMBER = sn_record.SERIAL_NUMBER and WORK_ORDER = TWO and ROWNUM = 1;
        EXCEPTION
           WHEN OTHERS THEN
              C_KPSN := sn_record.SERIAL_NUMBER;
        END;

           insert into b2b.PT_SERIAL
                  (DOC_ID, SERIAL_NUMBER, WORK_ORDER_NUMBER, SEQ_ID)
           values (C_DOC, C_KPSN, TWO, C_EDID);

        end loop;

        COMMIT;
     END IF;

     TRES := 'OK';
  END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      TRES := 'MES_TO_ERP_WIP_DELIVER ERROR';
END;