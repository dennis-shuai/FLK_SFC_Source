Insert into sajet.SYS_PROGRAM_FUN
   (PROGRAM, FUNCTION, UPDATE_USERID, UPDATE_TIME, AUTH_SEQ, AUTHORITYS, FUN_TYPE, FUN_TYPE_IDX, FUN_IDX, DLL_FILENAME)
 Values
   ('Foxlink Report', 'Travel ', 0, sysdate, 1, 'Allow To Execute', 'Travel Report', '5', '1', 'TravelReportDll.dll');

Insert into sajet.SYS_PROGRAM_FUN
   (PROGRAM, FUNCTION, UPDATE_USERID, UPDATE_TIME, AUTH_SEQ, AUTHORITYS, FUN_TYPE, FUN_TYPE_IDX, FUN_IDX, DLL_FILENAME)
 Values
   ('Foxlink Report', 'Alarm Mail ', 0, sysdate, 1, 'Allow To Execute', 'Travel Report', '5', '2', 'QueryAlarmMail.dll');