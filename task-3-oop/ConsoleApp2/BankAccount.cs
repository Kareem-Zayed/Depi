using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp2
{
    internal abstract class BankAccount
    {
        private static int _accountCounter = 1000;

        public int AccountNumber { get; private set; }
        public decimal Balance { get; protected set; }
        public DateTime DateOpened { get; private set; }
        public List<Transaction> Transactions { get; private set; }

        public BankAccount()
        {
            AccountNumber = ++_accountCounter;
            Balance = 0;
            DateOpened = DateTime.Now;
            Transactions = new List<Transaction>();
        }

        public virtual void Deposit(decimal amount)
        {
            if (amount <= 0) throw new ArgumentException("Deposit must be > 0");
            Balance += amount;
            Transactions.Add(new Transaction("Deposit", amount, $"Deposited {amount}"));
        }

        public virtual void Withdraw(decimal amount)
        {
            if (amount <= 0) throw new ArgumentException("Withdraw must be > 0");
            if (Balance < amount) throw new InvalidOperationException("Insufficient balance!");
            Balance -= amount;
            Transactions.Add(new Transaction("Withdraw", amount, $"Withdrew {amount}"));
        }

        public void Transfer(BankAccount target, decimal amount)
        {
            this.Withdraw(amount);
            target.Deposit(amount);
            Transactions.Add(new Transaction("Transfer", amount, $"Transferred to {target.AccountNumber}"));
        }

        public abstract void ShowAccountDetails();
    }
}
