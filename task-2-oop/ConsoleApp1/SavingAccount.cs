using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp1
{
    internal class SavingAccount : BankAccount
    {
        public decimal InterestRate { get; set; }

        public SavingAccount(int accountNumber, string fullName, string nationalID,
                             string phoneNumber, string address, decimal balance, decimal interestRate)
            : base(accountNumber, fullName, nationalID, phoneNumber, address, balance)
        {
            InterestRate = interestRate;
        }

        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine($"Interest Rate: {InterestRate}%");
            Console.WriteLine("=============================\n");
        }

        public decimal CalculateInterest()
        {
            return Balance * (InterestRate / 100);
        }
    }
}
