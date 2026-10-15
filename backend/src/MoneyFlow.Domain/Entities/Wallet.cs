using MoneyFlow.Domain.Common;
using MoneyFlow.Domain.Enums;

namespace MoneyFlow.Domain.Entities;

public class Wallet : BaseEntity
{
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public WalletType Type { get; set; } = WalletType.Cash;
    public decimal InitialBalance { get; set; } = 0m;
    public decimal CurrentBalance { get; set; } = 0m;
    public string Currency { get; set; } = "VND";
    public string ColorCode { get; set; } = "#3B82F6";
    public string IconName { get; set; } = "wallet";
    public bool IsExcludedFromTotal { get; set; } = false;
    public bool IsDeleted { get; set; } = false;

    // Navigation properties
    public User? User { get; set; }
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    public ICollection<Transfer> OutgoingTransfers { get; set; } = new List<Transfer>();
    public ICollection<Transfer> IncomingTransfers { get; set; } = new List<Transfer>();
}
