PGI入庫：
1. check kpsn
2. 納入流程管控


===================================
update 2007/12/06 by key
========================
1. check 流程部份---------pallet中每pcs check 流程改成	
 pallet 中只有一pcs check流程，pallet再check wip_process(實現的結果一樣)	
2.  check kpsn -----------所有工令都check kpsn 改成 只有	
 設定了要組裝kpsn的工令才check kpsn(減少check  kpsn 的范圍)	
3. 過站-------------------pallet 中每pcs 一一過站，改成整	
 個pallet一次性過站(減少相關query的次數)。
注：新加proc:
a.key_pallet_go;
b.key_pallet_transation_count;
c.key_pallet_update_sn;
d.key_pallet_wo_input;
e.key_pallet_wo_output.


===============================
2007/10 -- add by key
=====================
1. check kpsn 是不為N/A or NULL
2. seagate 機種check 每pcs EDA SN要有HDD SN 並且HDD SN 要有送IN 856
3. 非seagate  機種check kpsn個數是SN個數的倍數
4.  check 流程
5.  過PGI 站別
