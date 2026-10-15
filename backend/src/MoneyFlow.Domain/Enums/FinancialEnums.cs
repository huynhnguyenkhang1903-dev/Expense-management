namespace MoneyFlow.Domain.Enums;

public enum TransactionType
{
    Expense = 1,
    Income = 2
}

public enum WalletType
{
    Cash = 1,
    Bank = 2,
    EWallet = 3,
    CreditCard = 4,
    Other = 5
}

public enum BudgetPeriod
{
    Monthly = 1,
    Weekly = 2,
    Yearly = 3
}

public enum BillFrequency
{
    None = 0,
    Daily = 1,
    Weekly = 2,
    Monthly = 3,
    Quarterly = 4,
    Yearly = 5
}

public enum BillStatus
{
    Pending = 1,
    Paid = 2,
    Overdue = 3,
    Cancelled = 4
}

public enum DebtType
{
    Borrow = 1, // Đi vay (mình nợ người khác)
    Lend = 2    // Cho vay (người khác nợ mình)
}

public enum DebtStatus
{
    Active = 1,
    Settled = 2
}

public enum SavingsGoalStatus
{
    InProgress = 1,
    Completed = 2,
    Cancelled = 3
}
