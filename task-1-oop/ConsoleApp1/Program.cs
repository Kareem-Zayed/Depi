namespace ConsoleApp1
{
    internal class Program
    {
        static void Main(string[] args)
        {
           
            BankAccount account1 = new BankAccount();
            account1.ShowAccountDetails();

            BankAccount account2 = new BankAccount(1001, "Ahmed Ali", "12345678901234", "01012345678", "Cairo", 5000);
            account2.ShowAccountDetails();

            BankAccount account3 = new BankAccount(1002, "Sara Mohamed", "98765432109876", "01123456789", "Giza");
            account3.ShowAccountDetails();
            



         






        }
    }
}
