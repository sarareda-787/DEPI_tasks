using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OppD1
{
    internal class CurrentAccount :Bank
    {
        public decimal OverDraftLimit { get; set; }
        public override double CalculateInterset() => 0;

        public CurrentAccount(string nationalID, double balance, decimal overdraftLimit)
              : base(nationalID, balance)
        {
            OverDraftLimit = overdraftLimit;
        }
        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine($"Overdraft Limit: {OverDraftLimit:C}");
        }
    }
}
