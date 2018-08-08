
DELETE FROM sajet.SYS_PROGRAM_name WHERE PROGRAM='Foxlink Report';
Insert into sajet.SYS_PROGRAM_name
   (PROGRAM, EXE_FILENAME, TITLE_NAME, UPDATE_USERID, UPDATE_TIME, FUN_TYPE, FUN_TYPE_IDX, MDI_FLAG, PROGRAM_TYPE, SHOW_MAIN)
 Values
   ('Foxlink Report', 'FoxlinkReport', 'Sajet MES / [FoxlinkReport]', 0, TO_DATE('10/05/2006 16:21:05', 'MM/DD/YYYY HH24:MI:SS'), 'Report', 3, 0, '0', 0);

DELETE FROM sajet.SYS_PROGRAM_FUN WHERE FUNCTION='Daily Quality Report';
DELETE FROM sajet.SYS_PROGRAM_FUN WHERE FUNCTION='Weekly Quality Report';
DELETE FROM sajet.SYS_PROGRAM_FUN WHERE FUNCTION='Monthly Quality Report';

Insert into sajet.SYS_PROGRAM_FUN
   (PROGRAM, FUNCTION, UPDATE_USERID, UPDATE_TIME, AUTH_SEQ, AUTHORITYS, FUN_TYPE, FUN_TYPE_IDX, FUN_IDX, DLL_FILENAME)
 Values
   ('Foxlink Report', 'Daily Quality Report', 0, TO_DATE('10/05/2006 14:20:15', 'MM/DD/YYYY HH24:MI:SS'), 1, 'Allow To Execute','Quality Report', '2', '1', 'DQAReportDll.dll');

Insert into sajet.SYS_PROGRAM_FUN
   (PROGRAM, FUNCTION, UPDATE_USERID, UPDATE_TIME, AUTH_SEQ, AUTHORITYS, FUN_TYPE, FUN_TYPE_IDX, FUN_IDX, DLL_FILENAME)
 Values
   ('Foxlink Report', 'Weekly Quality Report', 0, TO_DATE('10/05/2006 14:20:15', 'MM/DD/YYYY HH24:MI:SS'), 1, 'Allow To Execute','Quality Report', '2', '2', 'DQAReportDll.dll');

Insert into sajet.SYS_PROGRAM_FUN
   (PROGRAM, FUNCTION, UPDATE_USERID, UPDATE_TIME, AUTH_SEQ, AUTHORITYS, FUN_TYPE, FUN_TYPE_IDX, FUN_IDX, DLL_FILENAME)
 Values
   ('Foxlink Report', 'Monthly Quality Report', 0, TO_DATE('10/05/2006 14:20:15', 'MM/DD/YYYY HH24:MI:SS'), 1, 'Allow To Execute','Quality Report', '2', '3', 'DQAReportDll.dll');
   
Insert into sajet.SYS_PROGRAM_FUN
   (PROGRAM, FUNCTION, UPDATE_USERID, UPDATE_TIME, AUTH_SEQ, AUTHORITYS, FUN_TYPE, FUN_TYPE_IDX, FUN_IDX, DLL_FILENAME)
 Values
   ('Foxlink Report', 'QA Report', 0, TO_DATE('10/05/2006 14:20:15', 'MM/DD/YYYY HH24:MI:SS'), 1, 'Allow To Execute','Quality Report', '2', '4', 'DQAReportDll.dll');


Insert into sajet.SYS_PROGRAM_FUN
   (PROGRAM, FUNCTION, UPDATE_USERID, UPDATE_TIME, AUTH_SEQ, AUTHORITYS, FUN_TYPE, FUN_TYPE_IDX, FUN_IDX, DLL_FILENAME)
 Values
   ('Foxlink Report', 'FPY Report', 0, SYSDATE, 1, 'Allow To Execute','Quality Report', '2', '5', 'QAFPYReportDll.dll');

Insert into sajet.SYS_PROGRAM_FUN
   (PROGRAM, FUNCTION, UPDATE_USERID, UPDATE_TIME, AUTH_SEQ, AUTHORITYS, FUN_TYPE, FUN_TYPE_IDX, FUN_IDX, DLL_FILENAME)
 Values
   ('Foxlink Report', 'Process Quality Report', 0, SYSDATE, 1, 'Allow To Execute','Quality Report', '2', '6', 'QProcessReportDll.dll');
