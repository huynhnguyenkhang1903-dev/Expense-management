using MoneyFlow.Domain.Common;
using MoneyFlow.Domain.Enums;

namespace MoneyFlow.Domain.Entities;

public class Category : BaseEntity
{
    public Guid? UserId { get; set; } // Null nếu là danh mục mặc định của hệ thống
    public string Name { get; set; } = string.Empty;
    public TransactionType Type { get; set; } = TransactionType.Expense;
    public string Icon { get; set; } = "category";
    public string Color { get; set; } = "#6B7280";
    public Guid? ParentId { get; set; }
    public bool IsSystemDefault { get; set; } = false;

    // Navigation properties
    public User? User { get; set; }
    public Category? ParentCategory { get; set; }
    public ICollection<Category> SubCategories { get; set; } = new List<Category>();
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    public ICollection<Budget> Budgets { get; set; } = new List<Budget>();
}
