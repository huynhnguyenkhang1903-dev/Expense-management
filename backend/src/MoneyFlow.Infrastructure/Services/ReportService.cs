using Microsoft.EntityFrameworkCore;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Reports;
using MoneyFlow.Application.Interfaces;
using MoneyFlow.Domain.Enums;
using MoneyFlow.Infrastructure.Data;

namespace MoneyFlow.Infrastructure.Services;

public class ReportService : IReportService
{
    private readonly AppDbContext _context;

    public ReportService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<DashboardSummaryDto>> GetDashboardSummaryAsync(Guid userId)
    {
        var now = DateTime.UtcNow;
        var startOfMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var endOfMonth = startOfMonth.AddMonths(1).AddTicks(-1);

        // 1. Tổng số dư các ví
        var wallets = await _context.Wallets
            .Where(w => w.UserId == userId && !w.IsExcludedFromTotal)
            .ToListAsync();

        var totalBalance = wallets.Sum(w => w.CurrentBalance);
        var activeWalletsCount = wallets.Count;

        // 2. Tổng thu / chi trong tháng
        var monthlyTransactions = await _context.Transactions
            .Include(t => t.Category)
            .Where(t => t.Wallet!.UserId == userId
                     && t.TransactionDate >= startOfMonth
                     && t.TransactionDate <= endOfMonth)
            .ToListAsync();

        var totalIncome = monthlyTransactions
            .Where(t => t.Type == TransactionType.Income)
            .Sum(t => t.Amount);

        var totalExpense = monthlyTransactions
            .Where(t => t.Type == TransactionType.Expense)
            .Sum(t => t.Amount);

        // 3. Top danh mục chi tiêu trong tháng
        var expenseCategories = monthlyTransactions
            .Where(t => t.Type == TransactionType.Expense && t.Category != null)
            .GroupBy(t => new { t.CategoryId, t.Category!.Name, t.Category.Icon, t.Category.Color })
            .Select(g => new
            {
                g.Key.CategoryId,
                g.Key.Name,
                g.Key.Icon,
                g.Key.Color,
                Total = g.Sum(x => x.Amount),
                Count = g.Count()
            })
            .OrderByDescending(x => x.Total)
            .Take(5)
            .ToList();

        var topExpenseList = expenseCategories.Select(c => new CategoryExpenseReportDto
        {
            CategoryId = c.CategoryId,
            CategoryName = c.Name,
            CategoryIcon = c.Icon,
            CategoryColor = c.Color,
            TotalAmount = c.Total,
            Percentage = totalExpense > 0 ? (double)(c.Total / totalExpense) * 100 : 0,
            TransactionCount = c.Count
        }).ToList();

        // 4. Ngân sách tháng
        var budgets = await _context.Budgets
            .Where(b => b.UserId == userId && b.Month == now.Month && b.Year == now.Year)
            .ToListAsync();

        var totalBudget = budgets.Sum(b => b.LimitAmount);

        return ApiResponse<DashboardSummaryDto>.Ok(new DashboardSummaryDto
        {
            TotalBalance = totalBalance,
            TotalIncomeThisMonth = totalIncome,
            TotalExpenseThisMonth = totalExpense,
            TotalBudgetThisMonth = totalBudget,
            TotalBudgetSpentThisMonth = totalExpense,
            ActiveWalletsCount = activeWalletsCount,
            TopExpenseCategories = topExpenseList
        });
    }

    public async Task<ApiResponse<List<CategoryExpenseReportDto>>> GetExpenseBreakdownAsync(Guid userId, DateTime fromDate, DateTime toDate)
    {
        var transactions = await _context.Transactions
            .Include(t => t.Category)
            .Where(t => t.Wallet!.UserId == userId
                     && t.Type == TransactionType.Expense
                     && t.TransactionDate >= fromDate
                     && t.TransactionDate <= toDate)
            .ToListAsync();

        var totalExpense = transactions.Sum(t => t.Amount);

        var breakdown = transactions
            .Where(t => t.Category != null)
            .GroupBy(t => new { t.CategoryId, t.Category!.Name, t.Category.Icon, t.Category.Color })
            .Select(g => new CategoryExpenseReportDto
            {
                CategoryId = g.Key.CategoryId,
                CategoryName = g.Key.Name,
                CategoryIcon = g.Key.Icon,
                CategoryColor = g.Key.Color,
                TotalAmount = g.Sum(x => x.Amount),
                Percentage = totalExpense > 0 ? (double)(g.Sum(x => x.Amount) / totalExpense) * 100 : 0,
                TransactionCount = g.Count()
            })
            .OrderByDescending(b => b.TotalAmount)
            .ToList();

        return ApiResponse<List<CategoryExpenseReportDto>>.Ok(breakdown);
    }

    public async Task<ApiResponse<List<CashFlowReportDto>>> GetMonthlyCashFlowAsync(Guid userId, int year)
    {
        var startOfYear = new DateTime(year, 1, 1, 0, 0, 0, DateTimeKind.Utc);
        var endOfYear = new DateTime(year, 12, 31, 23, 59, 59, DateTimeKind.Utc);

        var transactions = await _context.Transactions
            .Where(t => t.Wallet!.UserId == userId
                     && t.TransactionDate >= startOfYear
                     && t.TransactionDate <= endOfYear)
            .ToListAsync();

        var result = new List<CashFlowReportDto>();

        for (int m = 1; m <= 12; m++)
        {
            var monthTrans = transactions.Where(t => t.TransactionDate.Month == m).ToList();
            var income = monthTrans.Where(t => t.Type == TransactionType.Income).Sum(t => t.Amount);
            var expense = monthTrans.Where(t => t.Type == TransactionType.Expense).Sum(t => t.Amount);

            result.Add(new CashFlowReportDto
            {
                PeriodLabel = $"T{m}",
                Income = income,
                Expense = expense
            });
        }

        return ApiResponse<List<CashFlowReportDto>>.Ok(result);
    }
}
