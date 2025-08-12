using System.Reflection.Emit;

namespace Simple_calculator
{
    internal class Program
    {
       

        static void Main(string[] args)
        {
            double Fnum;
            double Snum;
            string operand;
            Console.WriteLine("Hello!\r\nInput the first number:");
           Fnum= Convert.ToDouble(Console.ReadLine());
            Console.WriteLine("Input the second number::");
            Snum = Convert.ToDouble(Console.ReadLine());
            Console.WriteLine("What do you want to do with those numbers?\r\n[A]dd\r\n[S]ubtract\r\n[M]ultiply");
           operand = Console.ReadLine();
            if (operand == "A")
            {
                Console.WriteLine(Add(Fnum, Snum)); 
            } else if(operand == "S")
            {
                Console.WriteLine(Subtract(Fnum, Snum));
                
            }
            else if (operand == "M")
            {
                Console.WriteLine(Multiply(Fnum, Snum));
            }
            Console.WriteLine("Press any key to close");
            double Add(double x, double y)
            {
                return x + y;
            }
            double Subtract(double x, double y)
            {
                return x - y;
            }
            double Multiply(double x, double y)
            {
                return x * y;
            }
        }
    }
}
