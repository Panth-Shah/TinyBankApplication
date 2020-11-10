using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using TinyBankDataAccess;
using System.Data.Entity;
using TinyBankingAPI.Models;

namespace TinyBankingAPI.Controllers
{
    public class CustomerController : ApiController
    {
        public IHttpActionResult GetAllCustomers()
        {
            IEnumerable<CustomerViewModel> customers = null;

            using (BankingDatabaseEntities entities = new BankingDatabaseEntities())
            {
                //return entities.CustomerAccounts.ToList();
                customers = entities.Customers
                            .Join(entities.CustomerAccounts, c => c.CustomerId, ca => ca.CustomerId, (c, ca) => new { c, ca })
                            .Join(entities.Accounts, caa => caa.ca.AccountId, a => a.AccountId, (caa, a) => new { caa, a })
                            .Select(x => new CustomerViewModel
                            {
                                FirstName = x.caa.c.CustomerFirstName,
                                MiddleName = x.caa.c.CustomerMiddleName,
                                LastName = x.caa.c.CustomerLastName,
                                PhoneNumber = x.caa.c.PhoneNumber,
                                FaxNumber = x.caa.c.FaxNumber,
                                EmailAddress = x.caa.c.EmailAddress,
                                customerAddress = (
                                    entities.Addresses.Where(y => y.CustomerId == x.caa.c.CustomerId)
                                    .Select(s => new AddressViewModel
                                    {
                                        Address1 = s.Address1,
                                        Address2 = s.Address2,
                                        Address3 = s.Address3,
                                        City = s.City,
                                        ZipCode = s.ZipCode,
                                        State = entities.States.Where(a => a.StateId == s.StateId).Select(b => b.Abbreviation).FirstOrDefault()
                                        //State = entities.States.Where(a => a.StateId == s.StateId).Select(b => new State { Abbreviation = b.Abbreviation}).FirstOrDefault(),
                                    })).ToList(),
                                AccountInformation = (entities.Accounts.Where(c => c.AccountId == x.a.AccountId)
                                    .Select(s => new AccountViewModel
                                    {
                                        AccountNumber = s.AccountNumber,
                                        CurrentAccountBalance = s.CurrentAccountBalance,
                                        AccountType = entities.AccountTypes.Where(c => c.AccountTypeId == s.AccountTypeId).Select(b => b.Name).FirstOrDefault()
                                        //AccountType = entities.AccountTypes.Where(z => z.AccountTypeId == s.AccountTypeId).Select(a => new AccountType { Name = a.Name}).FirstOrDefault()
                                    })).ToList()
                            }).ToList().Cast<CustomerViewModel>();

            }

            return Ok(customers);
        }

        [HttpGet]
        public HttpResponseMessage LoadCustomerById(int id)
        {
            using (BankingDatabaseEntities entities = new BankingDatabaseEntities())
            {
                var entity =  entities.Customers.FirstOrDefault(x => x.CustomerId == id);

                if (entity != null)
                {
                    return Request.CreateResponse(HttpStatusCode.OK, entity);
                }
                else
                {
                    return Request.CreateErrorResponse(HttpStatusCode.NotFound, "Customer with ID = " + id + " not found!"); 
                }
            }
        }

        public HttpResponseMessage Post([FromBody] Customer customer)
        {
            try
            {
                using (BankingDatabaseEntities entities = new BankingDatabaseEntities())
                {
                    entities.Customers.Add(customer);
                    entities.SaveChanges();

                    var message = Request.CreateResponse(HttpStatusCode.Created, customer);
                    message.Headers.Location = new Uri(Request.RequestUri + customer.CustomerId.ToString());
                    return message;
                }
            }
            catch (Exception ex)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, ex);
            }

        }
    }
}
