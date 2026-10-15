using MoneyFlow.Domain.Enums;

namespace MoneyFlow.Application.DTOs.Wallets;

public class WalletDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public WalletType Type { get; set; }
    public decimal InitialBalance { get; set; }
    public decimal CurrentBalance { get; set; }
    public string Currency { get; set; } = "VND";
    public string ColorCode { get; set; } = "#3B82F6";
    public string IconName { get; set; } = "wallet";
    public bool IsExcludedFromTotal { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateWalletRequest
{
    public string Name { get; set; } = string.Empty;
    public WalletType Type { get; set; } = WalletType.Cash;
    public decimal InitialBalance { get; set; } = 0m;
    public string Currency { get; set; } = "VND";
    public string ColorCode { get; set; } = "#3B82F6";
    public string IconName { get; set; } = "wallet";
    public bool IsExcludedFromTotal { get; set; } = false;
}

public class UpdateWalletRequest
{
    public string Name { get; set; } = string.Empty;
    public WalletType Type { get; set; }
    public string ColorCode { get; set; } = "#3B82F6";
    public string IconName { get; set; } = "wallet";
    public bool IsExcludedFromTotal { get; set; }
}

public class TransferRequest
{
    public Guid FromWalletId { get; set; }
    public Guid ToWalletId { get; set; }
    public decimal Amount { get; set; }
    public decimal Fee { get; set; } = 0m;
    public DateTime? TransferDate { get; set; }
    public string? Note { get; set; }
}

public class TransferDto
{
    public Guid Id { get; set; }
    public Guid FromWalletId { get; set; }
    public string FromWalletName { get; set; } = string.Empty;
    public Guid ToWalletId { get; set; }
    public string ToWalletName { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public decimal Fee { get; set; }
    public DateTime TransferDate { get; set; }
    public string? Note { get; set; }
}
