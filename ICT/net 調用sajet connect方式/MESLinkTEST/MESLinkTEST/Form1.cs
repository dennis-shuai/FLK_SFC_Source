using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Threading;

namespace MESLinkTEST
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }
        private void btn_OK_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Stopwatch timer = new System.Diagnostics.Stopwatch();
            timer.Start();
            string mystr=textSend .Text ;
            short op=(short)com_opcode.SelectedIndex ; 
            ConnMES(op,ref mystr);
            textrecdata .Text =mystr ;
            timer.Stop();
            texttime .Text =timer.ElapsedMilliseconds.ToString(); 
           // MessageBox.Show(System.DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss").Replace ("-","/")); 

        }
        private void ConnMES(short cmd, ref string value)
        { 
            byte[] str = new byte[800];
            char[] mychar = value.ToCharArray();
            int mylen; 
            for (int i = 0; i < mychar.Length; i++)
            {
                str[i] = Convert.ToByte(Convert.ToInt32(mychar[i]));
            }
            try
            {
                if (MES.SajetTransStart())
                {
                    Thread.Sleep(500);
                    mylen = str.Length;
                    if (MES.SajetTransData(cmd, ref str[0], ref mylen))
                    {
                        value = ValueChar_MES( str, mylen); 
                    }
                    else
                    {
                        value = "连接失败"; 
                    }
                    value = ValueChar_MES(str, mylen); 
                }
            }
            catch (Exception ex)
            {
                value = "连接错误";                
            }
            finally
            {
             MES.SajetTransClose();
            } 
        }
        private string ValueChar_MES(byte[] rbuff, int len)
        {
            string mystr1 = null, mystr = null; 
            try
            {
                for (int i = 0; i < len; i++)
                {
                    if (rbuff[i] > 30)
                    {
                        mystr1 = new string((char)rbuff[i], 1); //Convert.ToChar(rbuff[index +i+ 1]) + Convert.ToChar(rbuff[index + i]);
                    }                   
                    mystr += mystr1; 
                }
                if (mystr == null)
                {
                    mystr = "NA";
                }
            }
            catch (Exception ex)
            {
                mystr = "NA";  
            }
            return mystr;
        }
        private void Form1_Load(object sender, EventArgs e)
        {
            com_opcode.SelectedIndex = 1;
        }

        private void btnStart_Click(object sender, EventArgs e)
        {
             MES.SajetTransStart();
        }
    }
}
