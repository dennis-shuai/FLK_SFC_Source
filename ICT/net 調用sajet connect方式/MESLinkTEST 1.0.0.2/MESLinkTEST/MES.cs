﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace MESLinkTEST
{
    class MES
    {
        [DllImport("SajetConnect_Old.dll", EntryPoint = "SajetTransStart")]
        public static extern bool SajetTransStart();

        [DllImport("SajetConnect_Old.dll", EntryPoint = "SajetTransClose")]
        public static extern bool SajetTransClose();

        [DllImport("SajetConnect_Old.dll", EntryPoint = "SajetTransData")]
        public static extern bool SajetTransData(short f_iCommandNo, ref byte f_pData, ref int f_pLen);

        [DllImport("SajetConnect_Old.dll", EntryPoint = "SajetTransData")]
        public static extern bool SajetTransData(short f_iCommandNo, ref string f_pData, ref int f_pLen);

    }
}
