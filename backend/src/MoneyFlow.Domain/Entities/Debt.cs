using MoneyFlow.Domain.Common;
using MoneyFlow.Domain.Enums;

namespace MoneyFlow.Domain.Entities;

public class Debt : BaseEntity
{
    public Guid UserId { get; set; }
    public string PersonName { get; set; } = string.Empty;
    public DebtType Type { get; set; } = DebtType.Borrow;
    public decimal PrincipalAmount { get; set; }
    public decimal RemainingAmount { get; set; }
    public DateTime? DueDate { get; set; }
    public DebtStatus Status { get; set; } = DebtStatus.Active;
    public string? Note { get; set; }

    // Navigation properties
    public User? User { get; set; }
    public ICollection<DebtPayment> Payments { get; set; } = new List<DebtPayment>();
}

public class DebtPayment : BaseEntity
{
    public Guid DebtId { get; set; }
    public Guid WalletId { get; set; }
    public decimal Amount { get; set; }
    public DateTime PaymentDate { get; set; } = DateTime.UtcNow;
    public string? Note { get; set; }

    // Navigation properties
    public Debt? Debt { get; set; }
    public Wallet? Wallet { get; set; }
}
