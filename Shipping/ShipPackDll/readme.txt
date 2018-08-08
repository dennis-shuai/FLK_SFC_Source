ShipPackDLL

5.3.0.16
2009/01/15
1. 界面新中locate的Tedit控件.
2. 修改proc SJ_SHIPPING_PACK_CHECK_INPUT,親加DN_no參數
======================================================
5.3.0.15
2008/08/02
1. DN NO 每次只能回車一次;
2. DN NO 每次回車時，清除所做shippig pack 的資料,以確保seagate  edi 資料正確無誤
(因為seagate edi資料以pallet 出貨，所以shipping pack的type 一定要為pallet ，不能為其它類型,如carton)
===================================================================
5.3.0.14
2008/06/20
1. input date 新加PROC　SAJET.SJ_SHIPPING_PACK_CHECK_INPUT 進行check
2. Delete command 新加proc sajet.sj_shipping_delete_check_dn 進行check
3. qc_result='4'可以出貨
4. 禁用以sn / box 為單為出貨(因為導入fifo and 卡org)
======================================================


5.3.0.13
1. check fifo code
=======================================================