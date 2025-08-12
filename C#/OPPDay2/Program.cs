namespace OPPDay2
{
    internal class Program
    {
        static void Main(string[] args)
        {
            BankAccount account1 = new BankAccount(
         "Ahmed Ali",
         2,
         "12345678901234",
         "01012345678",
         "Cairo, Egypt",
         5000
     );

            // Object 2 - using overloaded constructor (no balance)
            BankAccount account2 = new BankAccount(
                "Sara Reda",
                3,
                "98765432109876",
                "01198765432",
                "Giza, Egypt"
            );

            // Show details
            account1.ShowAccountDetails();
            account2.ShowAccountDetails();
        }
      


    } 
    
}
    

