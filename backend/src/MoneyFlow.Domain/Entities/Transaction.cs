using MoneyFlow.Domain.Common;
using MoneyFlow.Domain.Enums;

namespace MoneyFlow.Domain.Entities;

public class Transaction : BaseEntity
{
    public Guid WalletId { get; set; }
    public Guid CategoryId { get; set; }
    public TransactionType Type { get; set; } = TransactionType.Expense;
    public decimal Amount { get; set; }
    public DateTime TransactionDate { get; set; } = DateTime.UtcNow;
    public string? Note { get; set; }
    public string? ImageUrl { get; set; }
    public bool IsDeleted { get; set; } = false;

    // Navigation properties
    public Wallet? Wallet { get; set; }
    public Category? Category { get; set; }
}
