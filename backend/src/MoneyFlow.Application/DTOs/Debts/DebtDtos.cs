namespace MoneyFlow.Application.DTOs.Debts;

public class DebtDto
{
    public Guid Id { get; set; }
    public string PersonName { get; set; } = string.Empty;
    public string Type { get; set; } = "Borrow"; // Borrow (Tôi nợ) hoặc Lend (Cho vay)
    public decimal PrincipalAmount { get; set; }
    public decimal RemainingAmount { get; set; }
    public decimal PaidAmount => PrincipalAmount - RemainingAmount;
    public decimal RepaymentProgress => PrincipalAmount > 0 ? Math.Round(((PrincipalAmount - RemainingAmount) / PrincipalAmount) * 100, 1) : 0;
    public DateTime? DueDate { get; set; }
    public string Status { get; set; } = "Active";
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class DebtSummaryDto
{
    public decimal TotalPayable { get; set; } // Tổng tiền tôi đang nợ người khác
    public decimal TotalReceivable { get; set; } // Tổng tiền người khác nợ tôi
    public int ActiveDebtsCount { get; set; }
    public List<DebtDto> Debts { get; set; } = new();
}

public class CreateDebtRequest
{
    public string PersonName { get; set; } = string.Empty;
    public string Type { get; set; } = "Borrow"; // Borrow hoặc Lend
    public decimal PrincipalAmount { get; set; }
    public DateTime? DueDate { get; set; }
    public string? Note { get; set; }
    public Guid? WalletId { get; set; } // Nếu có, cập nhật biến động số dư ví tương ứng
}

public class DebtPaymentRequest
{
    public Guid WalletId { get; set; }
    public decimal Amount { get; set; }
    public string? Note { get; set; }
}
