namespace ConsoleApp1
{
    internal class Program
    {
        static void Main(string[] args)
        {

            SavingAccount savingAcc = new SavingAccount(2001, "Ahmed Ali", "12345678901234",
                                                        "01012345678", "Cairo", 10000, 5);

            CurrentAccount currentAcc = new CurrentAccount(2002, "Sara Mohamed", "98765432109876",
                                                           "01123456789", "Giza", 2000, 3000);

            List<BankAccount> accounts = new List<BankAccount> { savingAcc, currentAcc };

            foreach (var acc in accounts)
            {
                acc.ShowAccountDetails();

                if (acc is SavingAccount sa)
                {
                    Console.WriteLine($"Calculated Interest: {sa.CalculateInterest()}");
                }
                else if (acc is CurrentAccount ca)
                {
                    Console.WriteLine($"Is Overdraft Exceeded? {ca.CheckOverdraft()}");
                }

                Console.WriteLine("------------------------------------\n");

            }
           

         






        }
    }
}
