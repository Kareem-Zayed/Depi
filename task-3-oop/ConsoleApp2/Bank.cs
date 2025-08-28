using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp2
{
    internal class Bank
    {
        public string BankName { get; set; }
        public string BranchCode { get; set; }
        public List<Customer> Customers { get; private set; }

        public Bank(string name, string branchCode)
        {
            BankName = name;
            BranchCode = branchCode;
            Customers = new List<Customer>();
        }

       
        public Customer AddCustomer(string fullName, string nationalID, DateTime dob)
        {
            var c = new Customer(fullName, nationalID, dob);
            Customers.Add(c);
            return c;
        }

        public void RemoveCustomer(int customerId)
        {
            var customer = Customers.Find(c => c.CustomerID == customerId);
            if (customer != null)
            {
                if (customer.GetTotalBalance() == 0) Customers.Remove(customer);
                else throw new InvalidOperationException("Cannot remove customer with non-zero balance.");
            }
        }

        public List<Customer> SearchByName(string name)
        {
            return Customers.FindAll(c => c.FullName.Contains(name, StringComparison.OrdinalIgnoreCase));
        }

        public Customer SearchByNationalID(string nid)
        {
            return Customers.Find(c => c.NationalID == nid);
        }

     
        public void ShowBankReport()
        {
            Console.WriteLine($"===== Bank Report: {BankName} (Branch: {BranchCode}) =====");
            foreach (var c in Customers)
            {
                c.ShowCustomerDetails();
                Console.WriteLine("------------------------------------");
            }
        }
    }
}
