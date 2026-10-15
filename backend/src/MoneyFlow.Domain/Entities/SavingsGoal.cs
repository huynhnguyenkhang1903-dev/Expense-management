using MoneyFlow.Domain.Common;
using MoneyFlow.Domain.Enums;

namespace MoneyFlow.Domain.Entities;

public class SavingsGoal : BaseEntity
{
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal TargetAmount { get; set; }
    public decimal CurrentAmount { get; set; } = 0m;
    public DateTime? TargetDate { get; set; }
    public SavingsGoalStatus Status { get; set; } = SavingsGoalStatus.InProgress;
    public string Color { get; set; } = "#10B981";

    // Navigation properties
    public User? User { get; set; }
    public ICollection<GoalEntry> Entries { get; set; } = new List<GoalEntry>();
}

public class GoalEntry : BaseEntity
{
    public Guid GoalId { get; set; }
    public Guid WalletId { get; set; }
    public decimal Amount { get; set; }
    public string Type { get; set; } = "Deposit"; // Deposit hoặc Withdraw
    public DateTime EntryDate { get; set; } = DateTime.UtcNow;
    public string? Note { get; set; }

    // Navigation properties
    public SavingsGoal? Goal { get; set; }
    public Wallet? Wallet { get; set; }
}
