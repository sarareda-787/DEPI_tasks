namespace OppD1
{
    internal class Program
    {
        static void Main(string[] args)
        {
            var savingAcc = new SavingAccount("12345678901234", 5000, 5);

            var currentAcc = new CurrentAccount("98765432109876", 2000, 1000);

            
            List<Bank> accounts = new List<Bank> { savingAcc, currentAcc };

            foreach (var acc in accounts)
            {
                acc.ShowAccountDetails();
                Console.WriteLine($"Interest: {acc.CalculateInterset():C}");
                Console.WriteLine(new string('-', 30));
            }

            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
        }
    }
    
}
