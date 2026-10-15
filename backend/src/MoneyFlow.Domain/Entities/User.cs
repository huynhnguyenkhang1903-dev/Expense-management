using MoneyFlow.Domain.Common;

namespace MoneyFlow.Domain.Entities;

public class User : BaseEntity
{
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string DefaultCurrency { get; set; } = "VND";
    public bool IsActive { get; set; } = true;

    // Refresh Token
    public string? RefreshToken { get; set; }
    public DateTime? RefreshTokenExpiryTime { get; set; }

    // Navigation properties
    public ICollection<Wallet> Wallets { get; set; } = new List<Wallet>();
    public ICollection<Category> CustomCategories { get; set; } = new List<Category>();
    public ICollection<Budget> Budgets { get; set; } = new List<Budget>();
    public ICollection<SavingsGoal> SavingsGoals { get; set; } = new List<SavingsGoal>();
    public ICollection<Bill> Bills { get; set; } = new List<Bill>();
    public ICollection<Debt> Debts { get; set; } = new List<Debt>();
}
