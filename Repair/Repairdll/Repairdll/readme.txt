5.3.0.27
by key 2009/01/03
1. add sajet.sj_repair_transation_count proc.

=============================================
5.3.0.26
BY KEY 2008/12/23
1.　REPLACE KP 時，KP的物料料號的情況可為：
多個foxlink 的物料料號可以對應一個客戶料號。

=================================
5.3.0.25
BY key 2008/11/05
1.　新加labrecid 控件，用於記錄生產線scan　defect code站別產生的recid,用於g_sn_repair_point 中的first_recid字段;
2.  delete 按鈕功能新中可delete g_sn_repair_location and g_sn_repair_point table 中的數據。


======================================================================
5.3.0.24 
by key 2008/07/08
1.　禁用sbtnFailSN 控件，不能查詢符合當前站別的所有待修的sn

============================================================================
5.3.0.23
by key 2008/06/11
更新內容
　1.　同一SN的相同location 最多能使用兩次（即同一SN,同一location 只能repair兩次）;
  2.  QUERY DUTY AND QUERY REASON_CODE 可進行模湖查詢;
　3.　QUERY REPAIR HISTORY REOCRD 加入可查詢location and item_no;
  4.  修改item_no的check 規則，使用g_wo_pick_list 的物料料號進行查詢。
＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
5.3.0.22
by key 2008/04/18
更新內容：
　　1.只有Enabled='Y'的 DEFECT_CODE/REASON_CODE/DUTY_CODE，才能加入repair程式中 
＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
5.3.0.21
by key 2008/03/28
更新內容：
　　1.　defect point 新加到g_sn_repair_point table中。

＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
5.3.0.20
by key 2007/9/24
更新內容：
　　1.　replace kp 時，g_sn_keyparts table中的item_group 值不做修改。

原因如下：

因 5.3.0.19之前的ver的程式，replace kp以後，g_sn_keyparts table中的item_group 值　is null --------程式bug.
又因入庫等程式要check　kp　count的個數,其中
　　  a. 需要設定kp bom 的kp ,其item_group 值not is null.
      b. 不需要設定kp bom的　kp,其item_group 值is null.
　    c. ATE INPUT程式 ，BDA(EDA) SN MAPPING PCBA  SN後，其item_group 值is null.
       並且部份pcba 是外包的，沒有pcba sn　label.
因此：check kp　count 的個數只要check item_group 值為not is null的kp 值即可。
 
===========================================================================
5.3.0.19
by key 2007/9/15
更新內容：
1. repace kp 窗口，new kp欄位不能input 任意的part_no,cust_part_no,vendor_part_no,
必須input 與old kpsn(主料or 備用料) 相同的part_no,cust_part_no,vendor_part_no才可以replace kp
2. 如果new kp 欄位input part_no or cust_partno,vendor_part_no,並且old kpsn＝'N/A'
才會做replace.
3. 如果old kpsn ='N/A' ，則input 此kpno 的part_no or cust_part_no or vendor_part_no
可以replace kp
4. Repair,Replace,Remove,scrap的權限一一分開
5. repalce kp ,將會check kp 補replace前後的個數是否相同。
6. 新加new kpno欄位，chekc kpno(主料or 備用料)。
7. remove and remove all的kp資料記錄在g_sn_repair_repalce_kp table中.
===============================================================================
5.3.0.18  
by key 2007/9/13
更新內容如下：
1.　keypars relpace history 資料－－－－新加query 按鈕，執行此按鈕才進行查詢。
2.　sn repaired history 資料-------新加query按鈕，執行此按鈕才進行查詢。
3.　reason history 資料－－－－新加query按釫，執行此按鈕才進行查詢。