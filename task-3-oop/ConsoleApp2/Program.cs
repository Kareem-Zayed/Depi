namespace ConsoleApp2
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Bank bank = new Bank("National Bank", "Cairo01");

            
            var cust1 = bank.AddCustomer("Ahmed Ali", "12345678901234", new DateTime(1995, 5, 12));
            var cust2 = bank.AddCustomer("Sara Mohamed", "98765432109876", new DateTime(2000, 8, 25));

            
            var acc1 = new SavingAccount(5); 
            var acc2 = new CurrentAccount(3000); 
            cust1.Accounts.Add(acc1);
            cust2.Accounts.Add(acc2);

            
            acc1.Deposit(10000);
            acc2.Deposit(2000);
            acc1.Transfer(acc2, 1500);
            acc2.Withdraw(500);

            bank.ShowBankReport();

            
            Console.WriteLine("Transaction History (Ahmed - Saving):");
            foreach (var t in acc1.Transactions)
                Console.WriteLine(t);

            
            Console.WriteLine($"Monthly Interest (Ahmed): {acc1.CalculateMonthlyInterest()}");
        }
    }
}