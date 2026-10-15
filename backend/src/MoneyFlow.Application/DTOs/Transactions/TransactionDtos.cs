using MoneyFlow.Domain.Enums;

namespace MoneyFlow.Application.DTOs.Transactions;

public class TransactionDto
{
    public Guid Id { get; set; }
    public Guid WalletId { get; set; }
    public string WalletName { get; set; } = string.Empty;
    public Guid CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public string CategoryIcon { get; set; } = string.Empty;
    public string CategoryColor { get; set; } = string.Empty;
    public TransactionType Type { get; set; }
    public decimal Amount { get; set; }
    public DateTime TransactionDate { get; set; }
    public string? Note { get; set; }
    public string? ImageUrl { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateTransactionRequest
{
    public Guid WalletId { get; set; }
    public Guid CategoryId { get; set; }
    public TransactionType Type { get; set; } = TransactionType.Expense;
    public decimal Amount { get; set; }
    public DateTime TransactionDate { get; set; } = DateTime.UtcNow;
    public string? Note { get; set; }
    public string? ImageUrl { get; set; }
}

public class UpdateTransactionRequest
{
    public Guid WalletId { get; set; }
    public Guid CategoryId { get; set; }
    public TransactionType Type { get; set; }
    public decimal Amount { get; set; }
    public DateTime TransactionDate { get; set; }
    public string? Note { get; set; }
    public string? ImageUrl { get; set; }
}

public class TransactionFilterParams
{
    public Guid? WalletId { get; set; }
    public Guid? CategoryId { get; set; }
    public TransactionType? Type { get; set; }
    public DateTime? FromDate { get; set; }
    public DateTime? ToDate { get; set; }
    public string? SearchTerm { get; set; }
    public int PageIndex { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}
