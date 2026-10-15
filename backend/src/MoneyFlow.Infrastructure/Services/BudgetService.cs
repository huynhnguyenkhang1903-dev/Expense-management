using Microsoft.EntityFrameworkCore;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Budgets;
using MoneyFlow.Application.Interfaces;
using MoneyFlow.Domain.Entities;
using MoneyFlow.Domain.Enums;
using MoneyFlow.Infrastructure.Data;

namespace MoneyFlow.Infrastructure.Services;

public class BudgetService : IBudgetService
{
    private readonly AppDbContext _context;

    public BudgetService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<List<BudgetDto>>> GetBudgetsAsync(Guid userId, int month, int year)
    {
        var budgets = await _context.Budgets
            .Include(b => b.Category)
            .Where(b => b.UserId == userId && b.Month == month && b.Year == year)
            .ToListAsync();

        var startDate = new DateTime(year, month, 1, 0, 0, 0, DateTimeKind.Utc);
        var endDate = startDate.AddMonths(1).AddTicks(-1);

        var result = new List<BudgetDto>();

        foreach (var b in budgets)
        {
            var expenseQuery = _context.Transactions
                .Where(t => t.Wallet!.UserId == userId
                         && t.Type == TransactionType.Expense
                         && t.TransactionDate >= startDate
                         && t.TransactionDate <= endDate);

            if (b.CategoryId.HasValue)
            {
                expenseQuery = expenseQuery.Where(t => t.CategoryId == b.CategoryId.Value);
            }

            var spentAmount = await expenseQuery.SumAsync(t => (decimal?)t.Amount) ?? 0m;

            result.Add(new BudgetDto
            {
                Id = b.Id,
                CategoryId = b.CategoryId,
                CategoryName = b.Category?.Name ?? "Ngân sách tổng",
                CategoryIcon = b.Category?.Icon ?? "account_balance_wallet",
                LimitAmount = b.LimitAmount,
                SpentAmount = spentAmount,
                Period = b.Period,
                Month = b.Month,
                Year = b.Year
            });
        }

        return ApiResponse<List<BudgetDto>>.Ok(result);
    }

    public async Task<ApiResponse<BudgetDto>> CreateOrUpdateBudgetAsync(Guid userId, CreateBudgetRequest request)
    {
        if (request.LimitAmount <= 0)
            return ApiResponse<BudgetDto>.Fail("Hạn mức ngân sách phải lớn hơn 0");

        var existing = await _context.Budgets
            .Include(b => b.Category)
            .FirstOrDefaultAsync(b => b.UserId == userId
                                   && b.CategoryId == request.CategoryId
                                   && b.Month == request.Month
                                   && b.Year == request.Year);

        if (existing != null)
        {
            existing.LimitAmount = request.LimitAmount;
            existing.Period = request.Period;
            existing.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return ApiResponse<BudgetDto>.Ok(new BudgetDto
            {
                Id = existing.Id,
                CategoryId = existing.CategoryId,
                CategoryName = existing.Category?.Name ?? "Ngân sách tổng",
                CategoryIcon = existing.Category?.Icon ?? "account_balance_wallet",
                LimitAmount = existing.LimitAmount,
                Period = existing.Period,
                Month = existing.Month,
                Year = existing.Year
            }, "Cập nhật ngân sách thành công");
        }

        var budget = new Budget
        {
            UserId = userId,
            CategoryId = request.CategoryId,
            LimitAmount = request.LimitAmount,
            Period = request.Period,
            Month = request.Month,
            Year = request.Year
        };

        _context.Budgets.Add(budget);
        await _context.SaveChangesAsync();

        var categoryName = "Ngân sách tổng";
        var categoryIcon = "account_balance_wallet";
        if (request.CategoryId.HasValue)
        {
            var cat = await _context.Categories.FindAsync(request.CategoryId.Value);
            if (cat != null)
            {
                categoryName = cat.Name;
                categoryIcon = cat.Icon;
            }
        }

        return ApiResponse<BudgetDto>.Ok(new BudgetDto
        {
            Id = budget.Id,
            CategoryId = budget.CategoryId,
            CategoryName = categoryName,
            CategoryIcon = categoryIcon,
            LimitAmount = budget.LimitAmount,
            Period = budget.Period,
            Month = budget.Month,
            Year = budget.Year
        }, "Tạo ngân sách thành công");
    }

    public async Task<ApiResponse<bool>> DeleteBudgetAsync(Guid userId, Guid budgetId)
    {
        var budget = await _context.Budgets.FirstOrDefaultAsync(b => b.Id == budgetId && b.UserId == userId);
        if (budget == null)
            return ApiResponse<bool>.Fail("Không tìm thấy ngân sách");

        _context.Budgets.Remove(budget);
        await _context.SaveChangesAsync();

        return ApiResponse<bool>.Ok(true, "Xóa ngân sách thành công");
    }
}
