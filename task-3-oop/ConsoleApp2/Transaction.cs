using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp2
{
    internal class Transaction
    {
        public DateTime Date { get; set; }
        public string Type { get; set; } 
        public decimal Amount { get; set; }
        public string Description { get; set; }

        public Transaction(string type, decimal amount, string description)
        {
            Date = DateTime.Now;
            Type = type;
            Amount = amount;
            Description = description;
        }

        public override string ToString()
        {
            return $"{Date} | {Type} | {Amount} | {Description}";
        }
    }
}
