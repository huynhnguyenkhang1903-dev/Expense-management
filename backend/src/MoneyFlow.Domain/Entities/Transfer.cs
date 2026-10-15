using MoneyFlow.Domain.Common;

namespace MoneyFlow.Domain.Entities;

public class Transfer : BaseEntity
{
    public Guid FromWalletId { get; set; }
    public Guid ToWalletId { get; set; }
    public decimal Amount { get; set; }
    public decimal Fee { get; set; } = 0m;
    public DateTime TransferDate { get; set; } = DateTime.UtcNow;
    public string? Note { get; set; }

    // Navigation properties
    public Wallet? FromWallet { get; set; }
    public Wallet? ToWallet { get; set; }
}
