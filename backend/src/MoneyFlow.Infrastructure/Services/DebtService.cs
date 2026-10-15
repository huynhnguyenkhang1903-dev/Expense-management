using Microsoft.EntityFrameworkCore;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Debts;
using MoneyFlow.Application.Interfaces;
using MoneyFlow.Domain.Entities;
using MoneyFlow.Domain.Enums;
using MoneyFlow.Infrastructure.Data;

namespace MoneyFlow.Infrastructure.Services;

public class DebtService : IDebtService
{
    private readonly AppDbContext _context;

    public DebtService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<DebtSummaryDto>> GetDebtsSummaryAsync(Guid userId)
    {
        var debts = await _context.Debts
            .Where(d => d.UserId == userId)
            .OrderByDescending(d => d.CreatedAt)
            .ToListAsync();

        var dtoList = debts.Select(d => new DebtDto
        {
            Id = d.Id,
            PersonName = d.PersonName,
            Type = d.Type.ToString(),
            PrincipalAmount = d.PrincipalAmount,
            RemainingAmount = d.RemainingAmount,
            DueDate = d.DueDate,
            Status = d.Status.ToString(),
            Note = d.Note,
            CreatedAt = d.CreatedAt
        }).ToList();

        var totalPayable = debts.Where(d => d.Type == DebtType.Borrow && d.Status == DebtStatus.Active).Sum(d => d.RemainingAmount);
        var totalReceivable = debts.Where(d => d.Type == DebtType.Lend && d.Status == DebtStatus.Active).Sum(d => d.RemainingAmount);

        var summary = new DebtSummaryDto
        {
            TotalPayable = totalPayable,
            TotalReceivable = totalReceivable,
            ActiveDebtsCount = debts.Count(d => d.Status == DebtStatus.Active),
            Debts = dtoList
        };

        return ApiResponse<DebtSummaryDto>.Ok(summary);
    }

    public async Task<ApiResponse<DebtDto>> CreateDebtAsync(Guid userId, CreateDebtRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.PersonName))
            return ApiResponse<DebtDto>.Fail("Tên đối tác / người liên quan không được để trống");

        if (request.PrincipalAmount <= 0)
            return ApiResponse<DebtDto>.Fail("Số tiền phải lớn hơn 0");

        var debtType = string.Equals(request.Type, "Lend", StringComparison.OrdinalIgnoreCase)
            ? DebtType.Lend
            : DebtType.Borrow;

        var debt = new Debt
        {
            UserId = userId,
            PersonName = request.PersonName.Trim(),
            Type = debtType,
            PrincipalAmount = request.PrincipalAmount,
            RemainingAmount = request.PrincipalAmount,
            DueDate = request.DueDate,
            Note = request.Note,
            Status = DebtStatus.Active
        };

        _context.Debts.Add(debt);

        // Nếu người dùng chọn ví để liên kết dòng tiền thực tế
        if (request.WalletId.HasValue)
        {
            var wallet = await _context.Wallets.FirstOrDefaultAsync(w => w.Id == request.WalletId.Value && w.UserId == userId);
            if (wallet != null)
            {
                if (debtType == DebtType.Borrow)
                {
                    // Đi vay => Tiền vào ví
                    wallet.CurrentBalance += request.PrincipalAmount;
                }
                else
                {
                    // Cho vay => Tiền ra khỏi ví
                    if (wallet.CurrentBalance < request.PrincipalAmount)
                        return ApiResponse<DebtDto>.Fail($"Số dư ví '{wallet.Name}' không đủ để thực hiện cho vay");
                    wallet.CurrentBalance -= request.PrincipalAmount;
                }
            }
        }

        await _context.SaveChangesAsync();

        var dto = new DebtDto
        {
            Id = debt.Id,
            PersonName = debt.PersonName,
            Type = debt.Type.ToString(),
            PrincipalAmount = debt.PrincipalAmount,
            RemainingAmount = debt.RemainingAmount,
            DueDate = debt.DueDate,
            Status = debt.Status.ToString(),
            Note = debt.Note,
            CreatedAt = debt.CreatedAt
        };

        return ApiResponse<DebtDto>.Ok(dto, "Ghi nhận sổ nợ / cho vay thành công");
    }

    public async Task<ApiResponse<DebtDto>> MakePaymentAsync(Guid userId, Guid debtId, DebtPaymentRequest request)
    {
        if (request.Amount <= 0)
            return ApiResponse<DebtDto>.Fail("Số tiền thanh toán phải lớn hơn 0");

        var debt = await _context.Debts.FirstOrDefaultAsync(d => d.Id == debtId && d.UserId == userId);
        if (debt == null)
            return ApiResponse<DebtDto>.Fail("Không tìm thấy khoản nợ");

        if (debt.Status == DebtStatus.Settled)
            return ApiResponse<DebtDto>.Fail("Khoản nợ này đã được thanh toán hoàn tất");

        var wallet = await _context.Wallets.FirstOrDefaultAsync(w => w.Id == request.WalletId && w.UserId == userId);
        if (wallet == null)
            return ApiResponse<DebtDto>.Fail("Không tìm thấy ví thanh toán");

        if (request.Amount > debt.RemainingAmount)
            return ApiResponse<DebtDto>.Fail($"Số tiền thanh toán ({request.Amount:N0} ₫) vượt quá dư nợ còn lại ({debt.RemainingAmount:N0} ₫)");

        using var dbTransaction = await _context.Database.BeginTransactionAsync();
        try
        {
            if (debt.Type == DebtType.Borrow)
            {
                // Mình trả nợ cho người khác => Tiền rời ví
                if (wallet.CurrentBalance < request.Amount)
                    return ApiResponse<DebtDto>.Fail($"Số dư ví '{wallet.Name}' không đủ ({wallet.CurrentBalance:N0} ₫)");
                wallet.CurrentBalance -= request.Amount;
            }
            else
            {
                // Người ta trả nợ cho mình => Tiền vào ví
                wallet.CurrentBalance += request.Amount;
            }

            debt.RemainingAmount -= request.Amount;
            if (debt.RemainingAmount <= 0)
            {
                debt.RemainingAmount = 0m;
                debt.Status = DebtStatus.Settled;
            }

            _context.DebtPayments.Add(new DebtPayment
            {
                DebtId = debt.Id,
                WalletId = wallet.Id,
                Amount = request.Amount,
                Note = request.Note ?? $"Thanh toán khoản {debt.Type}: {debt.PersonName}"
            });

            await _context.SaveChangesAsync();
            await dbTransaction.CommitAsync();

            var dto = new DebtDto
            {
                Id = debt.Id,
                PersonName = debt.PersonName,
                Type = debt.Type.ToString(),
                PrincipalAmount = debt.PrincipalAmount,
                RemainingAmount = debt.RemainingAmount,
                DueDate = debt.DueDate,
                Status = debt.Status.ToString(),
                Note = debt.Note,
                CreatedAt = debt.CreatedAt
            };

            return ApiResponse<DebtDto>.Ok(dto, "Ghi nhận thanh toán khoản nợ thành công");
        }
        catch (Exception ex)
        {
            await dbTransaction.RollbackAsync();
            return ApiResponse<DebtDto>.Fail("Lỗi hệ thống khi thanh toán nợ: " + ex.Message);
        }
    }

    public async Task<ApiResponse<bool>> DeleteDebtAsync(Guid userId, Guid debtId)
    {
        var debt = await _context.Debts.FirstOrDefaultAsync(d => d.Id == debtId && d.UserId == userId);
        if (debt == null)
            return ApiResponse<bool>.Fail("Không tìm thấy khoản nợ");

        _context.Debts.Remove(debt);
        await _context.SaveChangesAsync();

        return ApiResponse<bool>.Ok(true, "Xóa khoản nợ thành công");
    }
}
