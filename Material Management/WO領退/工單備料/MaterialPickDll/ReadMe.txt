5.3.0.47
2009/05/19
1. 修改g_wo_pick_info table ,記新加sequence and check /confirm 的時間和user
alter table g_wo_pick_info add add_time date

alter table g_wo_pick_info add add_userid number

alter table g_wo_pick_info add check_time date

alter table g_wo_pick_info add check_userid number

alter table g_wo_pick_info add confirm_time date

alter table g_wo_pick_info  add confirm_userid number

=======================================================
5.3.0.46
2008/06/26
1. 新加chkmaterialqty控件，依此判斷是否要查詢庫存
========================================

5.3.0.45
2008/05/19
1. 新加顯示org 欄位;
2. 倉庫只能發與ORG 相同的factory id 相同的物料。
========================================
5.3.0.44
2007/8/14
1. 新加seq for g_wo_pick_info
2. 沒有受fifo管控的物料提示‘Unlimit by Fifo’
========================================
5.3.0.43
2007/07/18
1.崝樓check emp 硐褫眕楷扢隅warehosue 腔蹋﹝
========================================
5.3.0.42
2007/07/04
1.党淏sql笢腔uppercase;
========================================
5.3.0.41
2007/06/26
1.Add FIFFO Code
========================================
5.3.0.38
2006/11/27
1.崝樓雄釬type;
2.絞ヶ袨怓 insert into sajet.g_ht_material;
===========================================
5.3.0.37
2006/09/28
1.流水號修改為4碼, 請自行將流水號為2碼的資料Update成4碼, 請注意欄位長度是否足夠
   sajet.g_wo_pick_info, sajet.g_pick_list, sajet.MES_ERP_WIP_ISSUE_RETURN
2.Complete no charge改成9
=========================================
5.3.0.36
2006/09/25
1.修正選取Unfinish Prepare數量錯誤的問題
=========================================
5.3.0.35
2006/09/21
1.不加欄位版
  注意: 最好工單都做一段落了, 不然Pick Qty會有問題
  將Sequence欄位型態改為Varchar2
  SAJET.G_HT_PICK_LIST 
  SAJET.G_PICK_LIST 
  SAJET.G_WO_PICK_INFO 
  SAJET.MES_TO_ERP_WIP_ISSUE_RETURN 
=========================================
5.3.0.34
2006/09/21
1.增加Abnormal Incoming (Ab.In), Abnormal Return (Ab.Out)及Locator (Sys_Part)
2.分Part Type備料及確認. (選ALL, 變色規則Pick Qty=Target Qty)
  新增爛位及修改的Procedure如下
   alter table sajet.g_wo_pick_info add part_type varchar2(25);
   alter table sajet.g_pick_list add part_type varchar2(25);
   alter table sajet.g_ht_pick_list add part_type varchar2(25);
   A. MES_ERP_WIP_ISSUE_RETURN增加TTYPE IN VARCHAR2;
      (請參考附件MES_ERP_WIP_ISSUE_RETURN.prc)
   B. MES_ERP_WIP_ISSUE的TPART改的值PART_NO改傳PART_TYPE
      TSEQ=-1的不用填PART_TYPE
      (請參考附件MES_ERP_WIP_ISSUE.prc)
=========================================
5.3.0.33
2006/09/19
1.Wo Status=7 (Complete no charge) 不可以再領料, 其他狀態皆可領
=========================================
5.3.0.30
2006/09/14
1. StrtoIntDef(Item.SubItems.Strings[1], 0) > StrToIntDef(Item.SubItems.Strings[2], 0) +  StrToIntDef(Item.SubItems.Strings[4], 0) 改成
    iQty := StrtoIntDef(Item.SubItems.Strings[1], 0) * (giPick + iQty) / StrToIntDef(lablQty.Caption, 1);
    iQty > StrToIntDef(Item.SubItems.Strings[2], 0) + StrtoIntDef(Item.SubItems.Strings[4], 0)
附註: 分次備料, 在下一次未開始備之前是前一次的狀態, 所以會都是綠色的, 直到Pick Qty欄位不是Enabled顏色才會變
=========================================
5.3.0.28
2006/09/14
1.ListView變色問題
=========================================
5.3.0.28
2006/09/13
1.增加Open, Prepare
=========================================
5.3.0.27
2006/09/12
1. 新增填入g_pick_list及g_materil的version
=========================================
5.3.0.26
2006/09/11
1.Oracle裡, A * B / A <> A * (B / A), 會造成Check時會有錯誤
=========================================
5.3.0.25
2006/09/05
1. 修正未有Locate_ID時, 會顯示not Instock (改成只檢查Warehouse是否有存在)
=========================================
5.3.0.20
2006/08/24
1.未有可用剩餘料時, 不可Mapping
2.Mapping後有多料, 刪除時未將多的料在G_Material_WM刪除
附註: 請查看G_Material_WM的Group_Wo是否為'N/A', 不可為空白, Select時會有問題
=========================================
5.3.0.19
2006/08/23
1.Unfinish未顯示Request = Issue
=========================================
5.3.0.18
2006/08/21
1.一次領完時, 判斷式有問題
=========================================
5.3.0.17
2006/08/21
1.新增轉大寫功能 (在sys_base新增一筆Param_Name = Material Caps Lock即可)
2.Check時, 改為先除再乘 (Oracle先乘再除會有問題)
3.領料時, 若一次領完, 則直接判斷是否有>Request, 若分次領, 先算出可領最大數, 不可超過可領最大數及Request數 
=========================================
5.3.0.16
2006/08/15
1.增加是否要Push Title
=========================================
5.3.0.15
2006/08/14
1. 傳到ERP時, 未將ITEMID傳入
=========================================
5.3.0.14
2006/08/04
1.新增MFGER_NAME, MFGER_PART_NO
=========================================
5.3.0.13
2006/07/20
1.修正WM QTY
2.工單完成, 不可再領料
3.未齊套不可被Group
4.未完成確認不可被Group
5.已被Group的不可再領料
=========================================
5.3.0.9
2006/07/14
1.為了退料, 修正G_WO_Group新增筆數為N筆 (之前為N-1), 新增Group Wo=Work Order
=========================================
5.3.0.8
2006/07/14
1.上傳Push Title
2.若Pick Qty=0, TPS類的可繼續領料 (5.3.0.7鎖定不可領)
=========================================
5.3.0.7
2006/07/10
Pick:
1.Material No改為ID No
2.Check OK也會顯示訊息
3.新增Check比對時, 比對不成功顯示不成功的Part No並在左方ListView第2欄顯示X
4.超過Request會變成綠色底 (Lime)
Confirm:
1.顯示的Issue為本次已領的數量
2.按下Confirm取消檢查是否大於Reqeust (此時只人為比較數量是不是與實際數相符)
=========================================
5.3.0.5
2006/07/04
1.解決Issue數量錯誤的問題
=========================================
YES      : 齊套, 可超發
NO       : 齊套, 不可超發
TPS-YES  : 不齊套, 可超發
TPS-NO   : 不齊套, 不可超發
No Check : 不檢查