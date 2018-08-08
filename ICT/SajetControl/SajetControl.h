// SajetControl.h: interface for the CSajetControl class.
//
//////////////////////////////////////////////////////////////////////
#if !defined(__SAJETCONTROL_H__)
#define __SAJETCONTROL_H__

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000



//typedef BOOL (*DLL_SajetTransStart)(void);
//typedef BOOL (*DLL_SajetTransClose)(void);
//typedef BOOL (*DLL_SajetTransData)(int,char*,int*);
//typedef BOOL (*DLL_SajetTransData2)(int,void*,void*);



class CSajetControl  
{
public:
	BOOL SendData(int iCommand,CString &szData);
	BOOL Init();
	BOOL SajetTransData(int iCommandNo,char *pData,int *pLen);
	BOOL SajetTransClose();
	BOOL SajetTransStart();
	CSajetControl();
	virtual ~CSajetControl();


private:
	HINSTANCE				m_hLib;


//	DLL_SajetTransStart		m_pFSajetTransStart;
//	DLL_SajetTransClose		m_pFSajetTransClose;
//	DLL_SajetTransData		m_pFSajetTransData;
//	DLL_SajetTransData2		m_pFSajetTransData2;

	BOOL (__stdcall *m_pFSajetTransStart_2)(void);
	BOOL (__stdcall *m_pFSajetTransClose_2)(void);
	BOOL (__stdcall *m_pFSajetTransData_2)(int iAddress,char* strData,int* iLen);


};

#endif // !defined(__SAJETCONTROL_H__)
