using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OppD1
{
    internal class SavingAccount : Bank
    {
        public double IntersetRate {  get; set; }
        public override double CalculateInterset()
        {
            return Balance * IntersetRate / 100.0;
        }
        public SavingAccount(string nationalID, double balance, double interestRate)
           : base(nationalID, balance)
        {
            IntersetRate = interestRate;
        }
        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine($"Interest Rate: {IntersetRate}%");
        }


    }
}
