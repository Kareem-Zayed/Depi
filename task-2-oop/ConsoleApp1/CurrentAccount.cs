using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp1
{
    internal class CurrentAccount : BankAccount
    {
        public decimal OverdraftLimit { get; set; }

        public CurrentAccount(int accountNumber, string fullName, string nationalID,
                              string phoneNumber, string address, decimal balance, decimal overdraftLimit)
            : base(accountNumber, fullName, nationalID, phoneNumber, address, balance)
        {
            OverdraftLimit = overdraftLimit;
        }

        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine($"Overdraft Limit: {OverdraftLimit}");
            Console.WriteLine("=============================\n");
        }

        public bool CheckOverdraft()
        {
            return Balance < -OverdraftLimit; 
        }
        }
    }
}
