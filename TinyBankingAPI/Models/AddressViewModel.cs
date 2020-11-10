using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using TinyBankDataAccess;


namespace TinyBankingAPI.Models
{
    public class AddressViewModel
    {
        public string Address1 { get; set; }
        public string Address2 { get; set; }
        public string Address3 { get; set; }
        public string City { get; set; }
        public string ZipCode { get; set; }
        public string State { get; set; }
    }
}