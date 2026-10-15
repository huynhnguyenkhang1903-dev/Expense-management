using MoneyFlow.Domain.Common;
using MoneyFlow.Domain.Enums;

namespace MoneyFlow.Domain.Entities;

public class Bill : BaseEntity
{
    public Guid UserId { get; set; }
    public Guid CategoryId { get; set; }
    public Guid? WalletId { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateTime DueDate { get; set; }
    public BillFrequency Frequency { get; set; } = BillFrequency.Monthly;
    public BillStatus Status { get; set; } = BillStatus.Pending;
    public int RemindDaysBefore { get; set; } = 3;
    public DateTime? LastPaidDate { get; set; }

    // Navigation properties
    public User? User { get; set; }
    public Category? Category { get; set; }
    public Wallet? Wallet { get; set; }
}
