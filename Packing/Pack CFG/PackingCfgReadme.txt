5.3.0.12
2010/05/29
�T��L���X

5.3.0.12
2007/10/09
1. user �i�H��ʥ[�Jadditional data ��dll���C�]�D���i�H���h��additional dll ���^
==============================================================
5.3.0.11
2007/08/17
1.�W�[�O�_�i��J���}�N�X(Input Error Code)�ﶵ
===============================================================
5.3.0.10
2007/3/8
1.�W�[Additional Data���]�w:�]�w��JSN��O�_�ݰ���L��ƪ���J�Τ��  
  ��dll�W�r�T�w��"AdditionalDll.dll",���e�i�ھڦU�a�ݨD�ۭq
===============================================================
5.3.0.9
1.Configuation�e�����u�X,��P�D�{���ۦP�覡���
===============================================================
5.3.0.8
2006/11/15
1.Comport�s�WLPT1 (�w�q�bSYS_SQL), ����BaudRate�]�w
  insert into sajet.sys_sql
  values('Packing Print Port', 'COM1,COM2,LPT1', 'L');
===============================================================
5.3.0.7
2006/07/28
1.�s�WRule Function (�u���ʿ�J����, �۰ʲ����٬O�H��Ӫ��W�h����)
  Function�W�ٽХHPK_�}�Y
===============================================================
5.3.0.6
2006/07/25
1.�s�WCaps Lock
2.�S��bDetail.bmp�|�ܦ��Ǧ⩳
===============================================================
5.3.0.5
2006/06/14
1.���ϥ~��, �j�i��bDetail.bmp
===============================================================
5.3.0.4
2006/06/07
1.�ץ��S�w�qPacking Action��Save�|�����~
===============================================================
5.3.0.3
2006/05/17
1.�s�W����System Create��, Customer SN�O�_�n����SN
2.�s�W�w�qBox No
3.Packing Action�s�WCarton for QC(���ɷ|�NPallet No=Carton No), 
  Repallet(���ޤ��e�O�_��Pallet�@��OverWrite)
4.Packing Action���y�z�w�q�bSys_Base��, �зs�W�p�U���, �i����ܦW��
  alter table sajet.sys_base modify (param_value varchar2(100));
  insert into sajet.sys_base (param_name, param_value) 
  values ('Packing Action', '0Both,5Box,6Carton,2Pallet,1Box/Carton,3Box/Carton for QC,4Repallet');

5.3.0.2
2006/04/06
1.�]�w�����ɮ�, ����Comport, BaudRate(�ѯ����{���t�d, PackingDll�u�������G)

5.3.0.1
2006/03/06
1. �W�[�����]�w: �O�_����, Comport, BaudRate

5.3.0.0
1.�W�[Procedure�ˬd�v��:�קK�P�@�ϥΪ��ݩ���Role�ɷ|Ū���v�����~
  Grant Execute on SAJET.SJ_CHK_PRG_PRIVILEGE to sys_user
