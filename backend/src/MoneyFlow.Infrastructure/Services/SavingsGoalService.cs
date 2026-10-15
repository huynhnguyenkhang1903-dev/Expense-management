using Microsoft.EntityFrameworkCore;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.SavingsGoals;
using MoneyFlow.Application.Interfaces;
using MoneyFlow.Domain.Entities;
using MoneyFlow.Domain.Enums;
using MoneyFlow.Infrastructure.Data;

namespace MoneyFlow.Infrastructure.Services;

public class SavingsGoalService : ISavingsGoalService
{
    private readonly AppDbContext _context;

    public SavingsGoalService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<List<SavingsGoalDto>>> GetGoalsAsync(Guid userId)
    {
        var goals = await _context.SavingsGoals
            .Where(g => g.UserId == userId)
            .OrderByDescending(g => g.CreatedAt)
            .Select(g => new SavingsGoalDto
            {
                Id = g.Id,
                Name = g.Name,
                TargetAmount = g.TargetAmount,
                CurrentAmount = g.CurrentAmount,
                TargetDate = g.TargetDate,
                Status = g.Status.ToString(),
                Color = g.Color,
                CreatedAt = g.CreatedAt
            })
            .ToListAsync();

        return ApiResponse<List<SavingsGoalDto>>.Ok(goals);
    }

    public async Task<ApiResponse<SavingsGoalDto>> CreateGoalAsync(Guid userId, CreateSavingsGoalRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name))
            return ApiResponse<SavingsGoalDto>.Fail("Tên mục tiêu tích lũy không được để trống");

        if (request.TargetAmount <= 0)
            return ApiResponse<SavingsGoalDto>.Fail("Số tiền mục tiêu phải lớn hơn 0");

        var goal = new SavingsGoal
        {
            UserId = userId,
            Name = request.Name.Trim(),
            TargetAmount = request.TargetAmount,
            CurrentAmount = 0m,
            TargetDate = request.TargetDate,
            Color = string.IsNullOrWhiteSpace(request.Color) ? "#10B981" : request.Color,
            Status = SavingsGoalStatus.InProgress
        };

        _context.SavingsGoals.Add(goal);
        await _context.SaveChangesAsync();

        if (request.InitialAmount > 0 && request.WalletId.HasValue)
        {
            var wallet = await _context.Wallets.FirstOrDefaultAsync(w => w.Id == request.WalletId.Value && w.UserId == userId);
            if (wallet != null && wallet.CurrentBalance >= request.InitialAmount)
            {
                wallet.CurrentBalance -= request.InitialAmount;
                goal.CurrentAmount += request.InitialAmount;
                if (goal.CurrentAmount >= goal.TargetAmount)
                    goal.Status = SavingsGoalStatus.Completed;

                _context.GoalEntries.Add(new GoalEntry
                {
                    GoalId = goal.Id,
                    WalletId = wallet.Id,
                    Amount = request.InitialAmount,
                    Type = "Deposit",
                    Note = "Khoản nạp khởi đầu khi tạo hũ tích lũy"
                });

                await _context.SaveChangesAsync();
            }
        }

        var dto = new SavingsGoalDto
        {
            Id = goal.Id,
            Name = goal.Name,
            TargetAmount = goal.TargetAmount,
            CurrentAmount = goal.CurrentAmount,
            TargetDate = goal.TargetDate,
            Status = goal.Status.ToString(),
            Color = goal.Color,
            CreatedAt = goal.CreatedAt
        };

        return ApiResponse<SavingsGoalDto>.Ok(dto, "Khởi tạo mục tiêu tích lũy thành công");
    }

    public async Task<ApiResponse<SavingsGoalDto>> DepositToGoalAsync(Guid userId, Guid goalId, DepositGoalRequest request)
    {
        if (request.Amount <= 0)
            return ApiResponse<SavingsGoalDto>.Fail("Số tiền nạp phải lớn hơn 0");

        var goal = await _context.SavingsGoals.FirstOrDefaultAsync(g => g.Id == goalId && g.UserId == userId);
        if (goal == null)
            return ApiResponse<SavingsGoalDto>.Fail("Không tìm thấy mục tiêu tích lũy");

        var wallet = await _context.Wallets.FirstOrDefaultAsync(w => w.Id == request.WalletId && w.UserId == userId);
        if (wallet == null)
            return ApiResponse<SavingsGoalDto>.Fail("Không tìm thấy nguồn ví thanh toán");

        if (wallet.CurrentBalance < request.Amount)
            return ApiResponse<SavingsGoalDto>.Fail($"Số dư ví '{wallet.Name}' không đủ ({wallet.CurrentBalance:N0} ₫)");

        using var dbTransaction = await _context.Database.BeginTransactionAsync();
        try
        {
            wallet.CurrentBalance -= request.Amount;
            goal.CurrentAmount += request.Amount;

            if (goal.CurrentAmount >= goal.TargetAmount)
            {
                goal.Status = SavingsGoalStatus.Completed;
            }

            _context.GoalEntries.Add(new GoalEntry
            {
                GoalId = goal.Id,
                WalletId = wallet.Id,
                Amount = request.Amount,
                Type = "Deposit",
                Note = request.Note ?? $"Nạp tiền vào quỹ tích lũy '{goal.Name}'"
            });

            await _context.SaveChangesAsync();
            await dbTransaction.CommitAsync();

            var dto = new SavingsGoalDto
            {
                Id = goal.Id,
                Name = goal.Name,
                TargetAmount = goal.TargetAmount,
                CurrentAmount = goal.CurrentAmount,
                TargetDate = goal.TargetDate,
                Status = goal.Status.ToString(),
                Color = goal.Color,
                CreatedAt = goal.CreatedAt
            };

            return ApiResponse<SavingsGoalDto>.Ok(dto, $"Đã nạp {request.Amount:N0} ₫ vào hũ '{goal.Name}' thành công");
        }
        catch (Exception ex)
        {
            await dbTransaction.RollbackAsync();
            return ApiResponse<SavingsGoalDto>.Fail("Lỗi hệ thống khi trích tiền nạp quỹ: " + ex.Message);
        }
    }

    public async Task<ApiResponse<bool>> DeleteGoalAsync(Guid userId, Guid goalId)
    {
        var goal = await _context.SavingsGoals.FirstOrDefaultAsync(g => g.Id == goalId && g.UserId == userId);
        if (goal == null)
            return ApiResponse<bool>.Fail("Không tìm thấy mục tiêu tích lũy");

        _context.SavingsGoals.Remove(goal);
        await _context.SaveChangesAsync();

        return ApiResponse<bool>.Ok(true, "Đã xóa mục tiêu tích lũy thành công");
    }
}
