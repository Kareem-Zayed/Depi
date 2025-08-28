using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp2
{
    internal class Customer
    {
        private static int _idCounter = 1;

        public int CustomerID { get; private set; }
        public string FullName { get; set; }
        public string NationalID { get; set; }
        public DateTime DateOfBirth { get; set; }
        public List<BankAccount> Accounts { get; private set; }

        public Customer(string fullName, string nationalID, DateTime dob)
        {
            CustomerID = _idCounter++;
            FullName = fullName;
            NationalID = nationalID;
            DateOfBirth = dob;
            Accounts = new List<BankAccount>();
        }

        public decimal GetTotalBalance()
        {
            decimal total = 0;
            foreach (var acc in Accounts) total += acc.Balance;
            return total;
        }

        public void ShowCustomerDetails()
        {
            Console.WriteLine($"CustomerID: {CustomerID}, Name: {FullName}, NationalID: {NationalID}, DOB: {DateOfBirth.ToShortDateString()}");
            foreach (var acc in Accounts) acc.ShowAccountDetails();
            Console.WriteLine($"Total Balance: {GetTotalBalance()}");
        }
    }
}
