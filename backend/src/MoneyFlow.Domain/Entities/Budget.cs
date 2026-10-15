using MoneyFlow.Domain.Common;
using MoneyFlow.Domain.Enums;

namespace MoneyFlow.Domain.Entities;

public class Budget : BaseEntity
{
    public Guid UserId { get; set; }
    public Guid? CategoryId { get; set; } // Null = Ngân sách tổng cho mọi khoản chi
    public decimal LimitAmount { get; set; }
    public BudgetPeriod Period { get; set; } = BudgetPeriod.Monthly;
    public int Month { get; set; }
    public int Year { get; set; }

    // Navigation properties
    public User? User { get; set; }
    public Category? Category { get; set; }
}
