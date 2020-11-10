using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using TinyBankDataAccess;


namespace TinyBankingAPI.Models
{
    public class AccountViewModel
    {
        public int AccountNumber { get; set; }
        public decimal CurrentAccountBalance { get; set; }
        public string AccountType { get; set; }

    }
}