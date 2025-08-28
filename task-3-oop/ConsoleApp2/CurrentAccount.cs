using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp2
{
    internal class CurrentAccount : BankAccount
    {
        public decimal OverdraftLimit { get; set; }

        public CurrentAccount(decimal overdraftLimit)
        {
            OverdraftLimit = overdraftLimit;
        }

        public override void Withdraw(decimal amount)
        {
            if (amount <= 0) throw new ArgumentException("Withdraw must be > 0");
            if (Balance - amount < -OverdraftLimit) throw new InvalidOperationException("Overdraft limit exceeded!");
            Balance -= amount;
            Transactions.Add(new Transaction("Withdraw", amount, $"Withdrew {amount} (Overdraft Allowed)"));
        }

        public override void ShowAccountDetails()
        {
            Console.WriteLine($"[CurrentAccount] AccountNo: {AccountNumber}, Balance: {Balance}, OverdraftLimit: {OverdraftLimit}");
        }
    }
}
