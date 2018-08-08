Select SerialCode,MODEL,StationName,TestDate,UserID Machine,
substring(item1,charindex(':',item1)+1, len(item1)-charindex(':',item1)) as TestResult ,
substring(item4,charindex(':',item4)+1, len(item4)-charindex(':',item4)) as [Version] ,
substring(item8,charindex(':',item8)+1, len(item8)-charindex(':',item8)) as MIC ,
substring(item9,charindex(':',item9)+1, len(item9)-charindex(':',item9)) as L_FREQ ,
substring(item10,charindex(':',item10)+1, len(item10)-charindex(':',item10)) as R_FREQ ,
substring(item11,charindex(':',item11)+1, len(item11)-charindex(':',item11)) as L_dB ,
substring(item12,charindex(':',item12)+1, len(item12)-charindex(':',item12)) as R_dB ,
substring(item13,charindex(':',item13)+1, len(item13)-charindex(':',item13)) as L_Noise,
substring(item14,charindex(':',item14)+1, len(item14)-charindex(':',item14)) as R_Noise 
FROM R_HISTORYLOGFILE where StationName ='MIC´ú¸Õ'