namespace MoneyFlow.Application.DTOs.Reports;

public class DashboardSummaryDto
{
    public decimal TotalBalance { get; set; }
    public decimal TotalIncomeThisMonth { get; set; }
    public decimal TotalExpenseThisMonth { get; set; }
    public decimal NetSavingsThisMonth => TotalIncomeThisMonth - TotalExpenseThisMonth;
    public decimal TotalBudgetThisMonth { get; set; }
    public decimal TotalBudgetSpentThisMonth { get; set; }
    public int ActiveWalletsCount { get; set; }
    public List<CategoryExpenseReportDto> TopExpenseCategories { get; set; } = new();
}

public class CategoryExpenseReportDto
{
    public Guid CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public string CategoryIcon { get; set; } = string.Empty;
    public string CategoryColor { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public double Percentage { get; set; }
    public int TransactionCount { get; set; }
}

public class CashFlowReportDto
{
    public string PeriodLabel { get; set; } = string.Empty; // e.g. "T10/2026" or "14/10"
    public decimal Income { get; set; }
    public decimal Expense { get; set; }
    public decimal NetFlow => Income - Expense;
}
