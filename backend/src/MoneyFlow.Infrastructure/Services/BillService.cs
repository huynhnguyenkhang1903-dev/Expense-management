using Microsoft.EntityFrameworkCore;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Bills;
using MoneyFlow.Application.Interfaces;
using MoneyFlow.Domain.Entities;
using MoneyFlow.Domain.Enums;
using MoneyFlow.Infrastructure.Data;

namespace MoneyFlow.Infrastructure.Services;

public class BillService : IBillService
{
    private readonly AppDbContext _context;

    public BillService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<List<BillDto>>> GetBillsAsync(Guid userId)
    {
        var bills = await _context.Bills
            .Include(b => b.Category)
            .Include(b => b.Wallet)
            .Where(b => b.UserId == userId)
            .OrderBy(b => b.DueDate)
            .ToListAsync();

        var result = bills.Select(b => new BillDto
        {
            Id = b.Id,
            Name = b.Name,
            Amount = b.Amount,
            CategoryId = b.CategoryId,
            CategoryName = b.Category?.Name ?? "Hóa đơn chung",
            CategoryIcon = b.Category?.Icon ?? "receipt",
            WalletId = b.WalletId,
            WalletName = b.Wallet?.Name,
            DueDate = b.DueDate,
            Frequency = b.Frequency.ToString(),
            Status = b.Status.ToString(),
            RemindDaysBefore = b.RemindDaysBefore,
            LastPaidDate = b.LastPaidDate,
            CreatedAt = b.CreatedAt
        }).ToList();

        return ApiResponse<List<BillDto>>.Ok(result);
    }

    public async Task<ApiResponse<BillDto>> CreateBillAsync(Guid userId, CreateBillRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name))
            return ApiResponse<BillDto>.Fail("Tên hóa đơn / dịch vụ không được để trống");

        if (request.Amount <= 0)
            return ApiResponse<BillDto>.Fail("Số tiền hóa đơn phải lớn hơn 0");

        var frequency = request.Frequency?.ToLower() switch
        {
            "daily" => BillFrequency.Daily,
            "weekly" => BillFrequency.Weekly,
            "yearly" => BillFrequency.Yearly,
            _ => BillFrequency.Monthly
        };

        var bill = new Bill
        {
            UserId = userId,
            Name = request.Name.Trim(),
            Amount = request.Amount,
            CategoryId = request.CategoryId,
            WalletId = request.WalletId,
            DueDate = request.DueDate,
            Frequency = frequency,
            RemindDaysBefore = request.RemindDaysBefore > 0 ? request.RemindDaysBefore : 3,
            Status = BillStatus.Pending
        };

        _context.Bills.Add(bill);
        await _context.SaveChangesAsync();

        var category = await _context.Categories.FindAsync(bill.CategoryId);
        var wallet = bill.WalletId.HasValue ? await _context.Wallets.FindAsync(bill.WalletId.Value) : null;

        var dto = new BillDto
        {
            Id = bill.Id,
            Name = bill.Name,
            Amount = bill.Amount,
            CategoryId = bill.CategoryId,
            CategoryName = category?.Name ?? "Hóa đơn",
            CategoryIcon = category?.Icon ?? "receipt",
            WalletId = bill.WalletId,
            WalletName = wallet?.Name,
            DueDate = bill.DueDate,
            Frequency = bill.Frequency.ToString(),
            Status = bill.Status.ToString(),
            RemindDaysBefore = bill.RemindDaysBefore,
            CreatedAt = bill.CreatedAt
        };

        return ApiResponse<BillDto>.Ok(dto, "Thiết lập hóa đơn định kỳ thành công");
    }

    public async Task<ApiResponse<BillDto>> PayBillAsync(Guid userId, Guid billId, PayBillRequest request)
    {
        var bill = await _context.Bills
            .Include(b => b.Category)
            .FirstOrDefaultAsync(b => b.Id == billId && b.UserId == userId);

        if (bill == null)
            return ApiResponse<BillDto>.Fail("Không tìm thấy hóa đơn");

        var wallet = await _context.Wallets.FirstOrDefaultAsync(w => w.Id == request.WalletId && w.UserId == userId);
        if (wallet == null)
            return ApiResponse<BillDto>.Fail("Không tìm thấy ví thanh toán");

        var paymentAmount = request.Amount ?? bill.Amount;
        if (paymentAmount <= 0)
            return ApiResponse<BillDto>.Fail("Số tiền thanh toán phải lớn hơn 0");

        if (wallet.CurrentBalance < paymentAmount)
            return ApiResponse<BillDto>.Fail($"Số dư ví '{wallet.Name}' không đủ ({wallet.CurrentBalance:N0} ₫)");

        using var dbTransaction = await _context.Database.BeginTransactionAsync();
        try
        {
            // Trừ tiền ví
            wallet.CurrentBalance -= paymentAmount;

            // Ghi nhận Expense Transaction
            _context.Transactions.Add(new Transaction
            {
                WalletId = wallet.Id,
                CategoryId = bill.CategoryId,
                Amount = paymentAmount,
                Type = TransactionType.Expense,
                TransactionDate = DateTime.UtcNow,
                Note = request.Note ?? $"Thanh toán hóa đơn định kỳ: {bill.Name}"
            });

            // Cập nhật trạng thái hóa đơn & dời hạn kỳ tiếp theo
            bill.LastPaidDate = DateTime.UtcNow;
            bill.Status = BillStatus.Paid;

            // Tự động gia hạn chu kỳ kế tiếp
            bill.DueDate = bill.Frequency switch
            {
                BillFrequency.Daily => bill.DueDate.AddDays(1),
                BillFrequency.Weekly => bill.DueDate.AddDays(7),
                BillFrequency.Yearly => bill.DueDate.AddYears(1),
                _ => bill.DueDate.AddMonths(1)
            };
            bill.Status = BillStatus.Pending; // Sẵn sàng cho kỳ tới

            await _context.SaveChangesAsync();
            await dbTransaction.CommitAsync();

            var dto = new BillDto
            {
                Id = bill.Id,
                Name = bill.Name,
                Amount = bill.Amount,
                CategoryId = bill.CategoryId,
                CategoryName = bill.Category?.Name ?? "Hóa đơn",
                CategoryIcon = bill.Category?.Icon ?? "receipt",
                WalletId = wallet.Id,
                WalletName = wallet.Name,
                DueDate = bill.DueDate,
                Frequency = bill.Frequency.ToString(),
                Status = bill.Status.ToString(),
                LastPaidDate = bill.LastPaidDate,
                CreatedAt = bill.CreatedAt
            };

            return ApiResponse<BillDto>.Ok(dto, $"Đã thanh toán hóa đơn '{bill.Name}' thành công. Đã dời kỳ hạn sang {bill.DueDate:dd/MM/yyyy}");
        }
        catch (Exception ex)
        {
            await dbTransaction.RollbackAsync();
            return ApiResponse<BillDto>.Fail("Lỗi khi xử lý thanh toán hóa đơn: " + ex.Message);
        }
    }

    public async Task<ApiResponse<bool>> DeleteBillAsync(Guid userId, Guid billId)
    {
        var bill = await _context.Bills.FirstOrDefaultAsync(b => b.Id == billId && b.UserId == userId);
        if (bill == null)
            return ApiResponse<bool>.Fail("Không tìm thấy hóa đơn");

        _context.Bills.Remove(bill);
        await _context.SaveChangesAsync();

        return ApiResponse<bool>.Ok(true, "Xóa hóa đơn thành công");
    }
}
