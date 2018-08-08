MAINTAINDLL

5.7.0.3
==============================
2007/12/27
納入庫存管控的tooling sn,要納入部門管控。

5.7.0.2
===========================
1.tooling制工具進行維護中，如果是'C:校正評估',則update g_tooling_machine table 中的
校正評估時間revise_time=sysdate;
如果制工俱tooling_sn存在於g_tooling_material table中，並且此制工具在產線(machine_status in('O','TL'))，其machine_used='Y',
則update 此制工具machine_used='N';

5.7.0.1
=====================
tooling制工具進行維護