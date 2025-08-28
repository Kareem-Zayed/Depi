using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp2
{
    internal class SavingAccount : BankAccount
    {
        public decimal InterestRate { get; set; }

        public SavingAccount(decimal interestRate)
        {
            InterestRate = interestRate;
        }

        public decimal CalculateMonthlyInterest()
        {
            return Balance * (InterestRate / 100m);
        }

        public override void ShowAccountDetails()
        {
            Console.WriteLine($"[SavingAccount] AccountNo: {AccountNumber}, Balance: {Balance}, InterestRate: {InterestRate}%");
        }
    }
}
