namespace MoneyFlow.Application.DTOs.Bills;

public class BillDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public Guid CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public string CategoryIcon { get; set; } = "receipt";
    public Guid? WalletId { get; set; }
    public string? WalletName { get; set; }
    public DateTime DueDate { get; set; }
    public string Frequency { get; set; } = "Monthly"; // Daily, Weekly, Monthly, Yearly
    public string Status { get; set; } = "Pending";
    public int RemindDaysBefore { get; set; } = 3;
    public int DaysRemaining => (int)(DueDate.Date - DateTime.UtcNow.Date).TotalDays;
    public bool IsOverdue => DueDate.Date < DateTime.UtcNow.Date && Status != "Paid";
    public DateTime? LastPaidDate { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateBillRequest
{
    public string Name { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public Guid CategoryId { get; set; }
    public Guid? WalletId { get; set; }
    public DateTime DueDate { get; set; }
    public string Frequency { get; set; } = "Monthly";
    public int RemindDaysBefore { get; set; } = 3;
}

public class PayBillRequest
{
    public Guid WalletId { get; set; }
    public decimal? Amount { get; set; }
    public string? Note { get; set; }
}
