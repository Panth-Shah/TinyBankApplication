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
        //private readonly PopulateDataEntity _populateDataEntity = null;

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

        public HttpResponseMessage Post([FromBody] CustomerViewModel customer)
        {
            List<AddressViewModel> customerAddress = null;
            List<AccountViewModel> customerAccount = null;
            try
            {
                using (BankingDatabaseEntities entities = new BankingDatabaseEntities())
                {
                    Customer _customer = new Customer();
                    _customer.CustomerFirstName = customer.FirstName;
                    _customer.CustomerMiddleName = customer.MiddleName;
                    _customer.CustomerLastName = customer.LastName;
                    _customer.EmailAddress = customer.EmailAddress;
                    _customer.FaxNumber = customer.FaxNumber;
                    _customer.PhoneNumber = customer.PhoneNumber;
                    _customer.CreateDate = DateTime.Now;
                    _customer.LastUpdate = DateTime.Now;

                    entities.Customers.Add(_customer);
                    entities.SaveChanges();

                    customerAddress = customer.customerAddress;
                    List<Address> _customerAddress = new List<Address>();

                    foreach (var address in customerAddress)
                    {
                        _customerAddress.Add(new Address
                        {
                            CustomerId = _customer.CustomerId,
                            Address1 = address.Address1,
                            Address2 = address.Address2,
                            Address3 = address.Address3,
                            City = address.City,
                            ZipCode = address.ZipCode,
                            StateId = entities.States.FirstOrDefault(x => Equals(x.Abbreviation, address.State)).StateId,
                            CreateDate = DateTime.Now,
                            LastUpdate = DateTime.Now
                        });
                    }

                    entities.Addresses.AddRange(_customerAddress);
                    entities.SaveChanges();

                    customerAccount = customer.AccountInformation;
                    List<Account> _customerAccount = new List<Account>();
                    foreach (var account in customerAccount)
                    {
                        _customerAccount.Add(new Account
                        {
                            
                            AccountNumber = account.AccountNumber,
                            CurrentAccountBalance = account.CurrentAccountBalance,
                            AccountStatusId = entities.AccountStatus.FirstOrDefault(x => x.Name == "Active").AccountStatusId,
                            AccountTypeId = entities.AccountTypes.FirstOrDefault(x => x.Name == account.AccountType).AccountTypeId,
                            Active = account.CurrentAccountBalance > 0 ? true : false,
                            CreateDate = DateTime.Now,
                            LastUpdate = DateTime.Now
                        });
                    }

                    entities.Accounts.AddRange(_customerAccount);
                    entities.SaveChanges();

                    List<CustomerAccount> _customerAccountMatch = new List<CustomerAccount>();
                    foreach (var account in _customerAccount)
                    {
                        _customerAccountMatch.Add(new CustomerAccount
                        {
                            CustomerId = _customer.CustomerId,
                            AccountId = account.AccountId
                        });
                    }

                    entities.CustomerAccounts.AddRange(_customerAccountMatch);
                    entities.SaveChanges();

                    var message = Request.CreateResponse(HttpStatusCode.Created, customer);
                    message.Headers.Location = new Uri(Request.RequestUri + _customer.CustomerId.ToString());
                    return message;
                }
            }
            catch (Exception ex)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, ex);
            }

        }

        public HttpResponseMessage Put(int id, [FromBody] CustomerViewModel customer)
        {
            try
            {

                using (BankingDatabaseEntities entities = new BankingDatabaseEntities())
                {
                    var existingCustomers = entities.CustomerAccounts.Where(x => x.CustomerId == id).ToList();
                    var customers = entities.Customers.FirstOrDefault(x => x.CustomerId == id);
                    List<Account> customerAccounts = new List<Account>();

                    if (existingCustomers != null || existingCustomers.Count > 0)
                    {
                        foreach (var _customer in existingCustomers)
                        {
                            customerAccounts.Add(entities.Accounts.FirstOrDefault(x => x.AccountId == _customer.AccountId));
                        }

                        customers.CustomerFirstName = customer.FirstName;
                        customers.CustomerLastName = customer.LastName;
                        customers.CustomerMiddleName = customer.MiddleName;
                        customers.EmailAddress = customer.EmailAddress;
                        customers.FaxNumber = customer.FaxNumber;
                        customers.PhoneNumber = customer.PhoneNumber;
                        customers.LastUpdate = DateTime.Now;

                        entities.SaveChanges();

                        var message = Request.CreateResponse(HttpStatusCode.Created, customer);
                        message.Headers.Location = new Uri(Request.RequestUri + customers.CustomerId.ToString());
                        return message;
                    }
                    else
                    {
                        return Request.CreateErrorResponse(HttpStatusCode.NotFound, "Customer with Id " + id.ToString() + " not found to update!");
                    }

                }
            }
            catch (Exception ex)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, ex);
            }

        }
    }
}
