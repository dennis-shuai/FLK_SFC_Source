tooling:

作業：對制工具的庫存及維護進行系統管控
功能模塊：
一.data center:
  1. tooling define -----tooling 基本資料設定
  2. tooling sn define----tooling sn基本資料設定
二。tooling:
  1. input -----tooling sn 使用次數input
    a.carry input;
    b.stencil input;
  2. maintain:
    a. scan defect ---inpute tooling sn 進行維護的不良代碼;
    b. matain   ---input tooling sn 進行各種維護的原因代碼;
    c. return to y -----把報廢的tooling sn改成正常狀態;
  3.query
    a.matain query  ----維護報表查詢
    b.material query -----庫存報表查詢
    c.travelcard     ------單一tooling sn 相關記錄資料查詢
  4. stock
   a.first in stock  ---first 入庫
   b.out stock  ---出庫
   c.IN  stokc  ---入庫
   d.transfer stock  ---轉倉
   e.transfer line   ---換線
   f.change used status ---更改制工具的使用狀態(Y-使用中，N-非使用);
   g.update material  ---更改制工具庫存的相關資料，如更改保管人 。

 
注意事項：
一。 庫存部份：
1.制工具使用狀態分為：Y-使用中，N-非使用;
2.制工具出入庫入線上遷移狀態分為：FI-First 入庫,I-入庫,O-出庫,TS-轉倉,TL-換線
2. 車間名稱當成warehouse_name(倉位),車間線別當成locate_name(儲位);
3. First入庫，校正時間為入厂時間，制工具為非使用狀態,
4. 入庫，制工具為非使用狀態;
5. 出庫，制工具為使用中狀態;
6. 出庫了的制工具可以換線，沒有出庫的制工具可以轉倉

二。維護部份：
1. 制工具維護狀態分為：Y-正常,R-維修,S-報廢,C-校正評估,M-保養;

三。結合部份：
1. 如果制工具在產線，則
  a.  當制工具狀態變成(R,S,C,M)時，制工具使用狀態自動更改成(N-非使用);
  b.  當制工具狀態變成(Y)時，制工具使用狀態自動更改成(Y-使用中);
2. 校正時間
   制工具在校正評估時(C-校正評估)時，會自動更改庫存部份的校正時間

三。基本資料：
  1. tooling sn 要唯一;
  2. machine no 機身編號要唯一;
  3. asset no   資產編號要唯一;

