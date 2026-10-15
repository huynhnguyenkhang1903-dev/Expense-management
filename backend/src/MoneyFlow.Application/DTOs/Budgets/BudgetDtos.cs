using MoneyFlow.Domain.Enums;

namespace MoneyFlow.Application.DTOs.Budgets;

public class BudgetDto
{
    public Guid Id { get; set; }
    public Guid? CategoryId { get; set; }
    public string? CategoryName { get; set; }
    public string? CategoryIcon { get; set; }
    public decimal LimitAmount { get; set; }
    public decimal SpentAmount { get; set; }
    public decimal RemainingAmount => LimitAmount - SpentAmount;
    public double PercentageUsed => LimitAmount > 0 ? (double)(SpentAmount / LimitAmount) * 100 : 0;
    public BudgetPeriod Period { get; set; }
    public int Month { get; set; }
    public int Year { get; set; }
}

public class CreateBudgetRequest
{
    public Guid? CategoryId { get; set; }
    public decimal LimitAmount { get; set; }
    public BudgetPeriod Period { get; set; } = BudgetPeriod.Monthly;
    public int Month { get; set; }
    public int Year { get; set; }
}
