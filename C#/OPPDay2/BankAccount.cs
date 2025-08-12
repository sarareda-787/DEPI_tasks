using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OPPDay2
{
    internal class BankAccount
    {
        const string Bankcode = "BNK001";
        private DateTime CreatedDate;
        private int _accountNumber;
        private string _fullName;
        private string _nationalID;
        private string _phoneNumber;
        private string _address;
        private double _balance;
        // properties 
        public int AccountNumber
        { get; set; }
        public string FullName
        {
            get { return _fullName; }
            set
            {
                if (string.IsNullOrEmpty(value))
                    throw new ArgumentNullException("Must not be null or empty.");
                _fullName = value;
            }
        }
        public string NationalID
        {
            get { return _nationalID; }
            set
            {
                if (value == null || value.Length != 14 || !long.TryParse(value, out _))
                    throw new ArgumentException("National ID must be exactly 14 digits.");
                _nationalID = value;


            }
        }
        public string PhoneNumber
        {
            get { return _phoneNumber; }
            set
            {
                if (value == null || value.Length != 11 || !value.StartsWith("01") || !long.TryParse(value, out _))
                    throw new ArgumentException("Phone number must start with '01' and be 11 digits.");
                _phoneNumber = value;
            }

        }
        public double Balance
        {
            get { return _balance; }
            set
            {
                if (value < 0)
                    throw new ArgumentException("Balance cannot be negative.");
                _balance = value;
            }
        }
        public string Address { set; get; }

        public BankAccount()
        {
            CreatedDate = DateTime.Now;
            AccountNumber = 1;
            FullName = "Sara Reda";
            NationalID = "00000000000000";
            PhoneNumber = "01000000000";
            Address = "Benha";
            Balance = 0;
        }
        public BankAccount(string fullname,int accountnumber, string nationalID, string phonenumber, string address, double balance)
        {
            FullName = fullname;
            AccountNumber=accountnumber;
            NationalID = nationalID;
            PhoneNumber = phonenumber;
            Address = address;
            Balance = balance;

        }
        public BankAccount(string fullname,int accountnumber, string nationalID, string phonenumber, string address)
            : this(fullname, accountnumber, nationalID, phonenumber, address, 0)
        {
        }
       
        public void ShowAccountDetails()
        {
            Console.WriteLine("===== Account Details =====");
            Console.WriteLine($"Bank Code     : {Bankcode}");
            Console.WriteLine($"Account No.   : {AccountNumber}");
            Console.WriteLine($"Created Date  : {CreatedDate}");
            Console.WriteLine($"Full Name     : {FullName}");
            Console.WriteLine($"National ID   : {NationalID}");
            Console.WriteLine($"Phone Number  : {PhoneNumber}");
            Console.WriteLine($"Address       : {Address}");
            Console.WriteLine($"Balance       : {Balance:C}");
            Console.WriteLine("============================\n");
        }
        public static bool IsValidNationalID(string id)
        {
            return id != null && id.Length == 14 && long.TryParse(id, out _);
        }

        public static bool IsValidPhoneNumber(string phone)
        {
            return phone != null && phone.Length == 11 && phone.StartsWith("01") && long.TryParse(phone, out _);
        }
    }
}
