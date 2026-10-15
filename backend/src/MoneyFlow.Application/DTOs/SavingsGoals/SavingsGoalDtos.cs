namespace MoneyFlow.Application.DTOs.SavingsGoals;

public class SavingsGoalDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal TargetAmount { get; set; }
    public decimal CurrentAmount { get; set; }
    public decimal ProgressPercentage => TargetAmount > 0 ? Math.Round((CurrentAmount / TargetAmount) * 100, 1) : 0;
    public decimal RemainingAmount => Math.Max(0, TargetAmount - CurrentAmount);
    public DateTime? TargetDate { get; set; }
    public int? DaysRemaining => TargetDate.HasValue ? Math.Max(0, (int)(TargetDate.Value.Date - DateTime.UtcNow.Date).TotalDays) : null;
    public string Status { get; set; } = "InProgress";
    public string Color { get; set; } = "#10B981";
    public DateTime CreatedAt { get; set; }
}

public class CreateSavingsGoalRequest
{
    public string Name { get; set; } = string.Empty;
    public decimal TargetAmount { get; set; }
    public decimal InitialAmount { get; set; } = 0;
    public Guid? WalletId { get; set; }
    public DateTime? TargetDate { get; set; }
    public string Color { get; set; } = "#10B981";
}

public class DepositGoalRequest
{
    public Guid WalletId { get; set; }
    public decimal Amount { get; set; }
    public string? Note { get; set; }
}
