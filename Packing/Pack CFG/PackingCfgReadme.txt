5.3.0.12
2010/05/29
禁止打印條碼

5.3.0.12
2007/10/09
1. user 可以手動加入additional data 的dll文件。（厂內可以有多個additional dll 文件）
==============================================================
5.3.0.11
2007/08/17
1.增加是否可輸入不良代碼(Input Error Code)選項
===============================================================
5.3.0.10
2007/3/8
1.增加Additional Data的設定:設定刷入SN後是否需做其他資料的輸入或比對  
  此dll名字固定為"AdditionalDll.dll",內容可根據各家需求自訂
===============================================================
5.3.0.9
1.Configuation畫面不彈出,改與主程式相同方式顯示
===============================================================
5.3.0.8
2006/11/15
1.Comport新增LPT1 (定義在SYS_SQL), 取消BaudRate設定
  insert into sajet.sys_sql
  values('Packing Print Port', 'COM1,COM2,LPT1', 'L');
===============================================================
5.3.0.7
2006/07/28
1.新增Rule Function (只對手動輸入有效, 自動產生還是以原來的規則產生)
  Function名稱請以PK_開頭
===============================================================
5.3.0.6
2006/07/25
1.新增Caps Lock
2.沒有bDetail.bmp會變成灰色底
===============================================================
5.3.0.5
2006/06/14
1.底圖外掛, 大張的bDetail.bmp
===============================================================
5.3.0.4
2006/06/07
1.修正沒定義Packing Action按Save會有錯誤
===============================================================
5.3.0.3
2006/05/17
1.新增不由System Create時, Customer SN是否要等於SN
2.新增定義Box No
3.Packing Action新增Carton for QC(此時會將Pallet No=Carton No), 
  Repallet(不管之前是否有Pallet一律OverWrite)
4.Packing Action的描述定義在Sys_Base裡, 請新增如下資料, 可改顯示名稱
  alter table sajet.sys_base modify (param_value varchar2(100));
  insert into sajet.sys_base (param_name, param_value) 
  values ('Packing Action', '0Both,5Box,6Carton,2Pallet,1Box/Carton,3Box/Carton for QC,4Repallet');

5.3.0.2
2006/04/06
1.設定秤重檔案, 取消Comport, BaudRate(由秤重程式負責, PackingDll只接收結果)

5.3.0.1
2006/03/06
1. 增加秤重設定: 是否秤重, Comport, BaudRate

5.3.0.0
1.增加Procedure檢查權限:避免同一使用者屬於兩個Role時會讀取權限錯誤
  Grant Execute on SAJET.SJ_CHK_PRG_PRIVILEGE to sys_user
