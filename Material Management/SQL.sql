Insert into sajet.SYS_PROGRAM_FUN
   (PROGRAM, FUNCTION, UPDATE_USERID, UPDATE_TIME, AUTH_SEQ, AUTHORITYS, FUN_TYPE, FUN_TYPE_IDX, FUN_IDX, DLL_FILENAME)
 Values
   ('Material Management', 'Label Replace', 0, TO_DATE('10/05/2006 15:35:33', 'MM/DD/YYYY HH24:MI:SS'), 1, 'Allow To Execute', 'Mapping', '8', '1', 'RTlabelReplaceDLL.dll');

Insert into sajet.SYS_PROGRAM_FUN
   (PROGRAM, FUNCTION, UPDATE_USERID, UPDATE_TIME, AUTH_SEQ, AUTHORITYS, FUN_TYPE, FUN_TYPE_IDX, FUN_IDX, DLL_FILENAME)
 Values
   ('Material Management', 'Check Reel', 0, TO_DATE('10/05/2006 15:35:33', 'MM/DD/YYYY HH24:MI:SS'), 1, 'Allow To Execute', 'Mapping', '8', '2', 'CheckReelDLL.dll');
