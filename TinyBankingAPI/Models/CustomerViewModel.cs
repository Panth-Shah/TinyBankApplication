using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace TinyBankingAPI.Models
{
    public class CustomerViewModel
    {
        public string FirstName { get; set; }
        public string MiddleName { get; set; }
        public string LastName { get; set; }
        public string PhoneNumber { get; set; }
        public string FaxNumber { get; set; }
        public string EmailAddress { get; set; }
        public List<AddressViewModel> customerAddress { get; set; }
        public List<AccountViewModel> AccountInformation { get; set; }

    }
}