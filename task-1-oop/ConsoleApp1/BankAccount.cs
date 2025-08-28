using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp1
{
    internal class BankAccount
    {

       
        public const string BankCode = "BNK001";  
        public readonly DateTime CreatedDate; 

        private int _accountNumber;
        private string _fullName;
        private string _nationalID;
        private string _phoneNumber;
        private string _address;
        private decimal _balance;

        public int AccountNumber
        {
            get { return _accountNumber; }
            set { _accountNumber = value; }
        }

        public string FullName
        {
            get { return _fullName; }
            set
            {
                if (string.IsNullOrWhiteSpace(value))
                    throw new ArgumentException("Full Name cannot be empty.");
                _fullName = value;
            }
        }

        public string NationalID
        {
            get { return _nationalID; }
            set
            {
                if (value.Length != 14 || !long.TryParse(value, out _))
                    throw new ArgumentException("National ID must be exactly 14 digits.");
                _nationalID = value;
            }
        }

        public string PhoneNumber
        {
            get { return _phoneNumber; }
            set
            {
                if (value.Length != 11 || !value.StartsWith("01") || !long.TryParse(value, out _))
                    throw new ArgumentException("Phone number must start with 01 and be 11 digits.");
                _phoneNumber = value;
            }
        }

        public string Address
        {
            get { return _address; }
            set { _address = value; } 
        }

        public decimal Balance
        {
            get { return _balance; }
            set
            {
                if (value < 0)
                    throw new ArgumentException("Balance cannot be negative.");
                _balance = value;
            }
        }


        public BankAccount()
        {
            CreatedDate = DateTime.Now;
            _accountNumber = 0;
            _fullName = "N/A";
            _nationalID = "00000000000000";
            _phoneNumber = "00000000000";
            _address = "N/A";
            _balance = 0;
        }

        public BankAccount(int accountNumber, string fullName, string nationalID, string phoneNumber, string address, decimal balance)
        {
            CreatedDate = DateTime.Now;
            AccountNumber = accountNumber;
            FullName = fullName;
            NationalID = nationalID;
            PhoneNumber = phoneNumber;
            Address = address;
            Balance = balance;
        }

        public BankAccount(int accountNumber, string fullName, string nationalID, string phoneNumber, string address)
        {
            CreatedDate = DateTime.Now;
            AccountNumber = accountNumber;
            FullName = fullName;
            NationalID = nationalID;
            PhoneNumber = phoneNumber;
            Address = address;
            Balance = 0; 
        }

        public void ShowAccountDetails()
        {
            Console.WriteLine("====== Account Details ======");
            Console.WriteLine($"Bank Code: {BankCode}");
            Console.WriteLine($"Created Date: {CreatedDate}");
            Console.WriteLine($"Account Number: {_accountNumber}");
            Console.WriteLine($"Full Name: {_fullName}");
            Console.WriteLine($"National ID: {_nationalID}");
            Console.WriteLine($"Phone Number: {_phoneNumber}");
            Console.WriteLine($"Address: {_address}");
            Console.WriteLine($"Balance: {_balance}");
            Console.WriteLine("=============================\n");
        }

        public bool IsValidNationalID()
        {
            return _nationalID.Length == 14 && long.TryParse(_nationalID, out _);
        }

        public bool IsValidPhoneNumber()
        {
            return _phoneNumber.Length == 11 && _phoneNumber.StartsWith("01") && long.TryParse(_phoneNumber, out _);
        }
    }
}
