using System;

class Program
{
    static void Main()
    {
        Console.WriteLine("Hello!");
        Console.Write("Input the first number: ");
        var firstInput = Console.ReadLine();
        if (!double.TryParse(firstInput, out double a))
        {
            Console.WriteLine("Invalid first number.");
            EndProgram();
            return;
        }

        Console.Write("Input the second number: ");
        var secondInput = Console.ReadLine();
        if (!double.TryParse(secondInput, out double b))
        {
            Console.WriteLine("Invalid second number.");
            EndProgram();
            return;
        }

        Console.WriteLine("What do you want to do with those numbers?");
        Console.WriteLine("[A]dd");
        Console.WriteLine("[S]ubtract");
        Console.WriteLine("[M]ultiply");
        Console.Write("Your choice: ");
        var choice = Console.ReadLine();

        if (string.IsNullOrWhiteSpace(choice))
        {
            Console.WriteLine("Invalid option");
            EndProgram();
            return;
        }

        char opt = char.ToUpper(choice.Trim()[0]);
        switch (opt)
        {
            case 'A':
                Console.WriteLine($"{a} + {b} = {a + b}");
                break;
            case 'S':
                Console.WriteLine($"{a} - {b} = {a - b}");
                break;
            case 'M':
                Console.WriteLine($"{a} * {b} = {a * b}");
                break;
            default:
                Console.WriteLine("Invalid option");
                break;
        }

        EndProgram();
    }

    static void EndProgram()
    {
        Console.WriteLine("Press any key to close");
        Console.ReadKey();
    }
}