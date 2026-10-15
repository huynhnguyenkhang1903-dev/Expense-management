using Microsoft.EntityFrameworkCore;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Wallets;
using MoneyFlow.Application.Interfaces;
using MoneyFlow.Domain.Entities;
using MoneyFlow.Infrastructure.Data;

namespace MoneyFlow.Infrastructure.Services;

public class WalletService : IWalletService
{
    private readonly AppDbContext _context;

    public WalletService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<List<WalletDto>>> GetUserWalletsAsync(Guid userId)
    {
        var wallets = await _context.Wallets
            .Where(w => w.UserId == userId)
            .OrderBy(w => w.CreatedAt)
            .Select(w => new WalletDto
            {
                Id = w.Id,
                Name = w.Name,
                Type = w.Type,
                InitialBalance = w.InitialBalance,
                CurrentBalance = w.CurrentBalance,
                Currency = w.Currency,
                ColorCode = w.ColorCode,
                IconName = w.IconName,
                IsExcludedFromTotal = w.IsExcludedFromTotal,
                CreatedAt = w.CreatedAt
            })
            .ToListAsync();

        return ApiResponse<List<WalletDto>>.Ok(wallets);
    }

    public async Task<ApiResponse<WalletDto>> GetWalletByIdAsync(Guid userId, Guid walletId)
    {
        var wallet = await _context.Wallets
            .FirstOrDefaultAsync(w => w.Id == walletId && w.UserId == userId);

        if (wallet == null)
            return ApiResponse<WalletDto>.Fail("Không tìm thấy ví");

        return ApiResponse<WalletDto>.Ok(new WalletDto
        {
            Id = wallet.Id,
            Name = wallet.Name,
            Type = wallet.Type,
            InitialBalance = wallet.InitialBalance,
            CurrentBalance = wallet.CurrentBalance,
            Currency = wallet.Currency,
            ColorCode = wallet.ColorCode,
            IconName = wallet.IconName,
            IsExcludedFromTotal = wallet.IsExcludedFromTotal,
            CreatedAt = wallet.CreatedAt
        });
    }

    public async Task<ApiResponse<WalletDto>> CreateWalletAsync(Guid userId, CreateWalletRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name))
            return ApiResponse<WalletDto>.Fail("Tên ví không được để trống");

        var wallet = new Wallet
        {
            UserId = userId,
            Name = request.Name.Trim(),
            Type = request.Type,
            InitialBalance = request.InitialBalance,
            CurrentBalance = request.InitialBalance, // Số dư ban đầu bằng số dư hiện tại
            Currency = string.IsNullOrWhiteSpace(request.Currency) ? "VND" : request.Currency,
            ColorCode = request.ColorCode,
            IconName = request.IconName,
            IsExcludedFromTotal = request.IsExcludedFromTotal
        };

        _context.Wallets.Add(wallet);
        await _context.SaveChangesAsync();

        return ApiResponse<WalletDto>.Ok(new WalletDto
        {
            Id = wallet.Id,
            Name = wallet.Name,
            Type = wallet.Type,
            InitialBalance = wallet.InitialBalance,
            CurrentBalance = wallet.CurrentBalance,
            Currency = wallet.Currency,
            ColorCode = wallet.ColorCode,
            IconName = wallet.IconName,
            IsExcludedFromTotal = wallet.IsExcludedFromTotal,
            CreatedAt = wallet.CreatedAt
        }, "Tạo ví thành công");
    }

    public async Task<ApiResponse<WalletDto>> UpdateWalletAsync(Guid userId, Guid walletId, UpdateWalletRequest request)
    {
        var wallet = await _context.Wallets.FirstOrDefaultAsync(w => w.Id == walletId && w.UserId == userId);
        if (wallet == null)
            return ApiResponse<WalletDto>.Fail("Không tìm thấy ví");

        if (string.IsNullOrWhiteSpace(request.Name))
            return ApiResponse<WalletDto>.Fail("Tên ví không được để trống");

        wallet.Name = request.Name.Trim();
        wallet.Type = request.Type;
        wallet.ColorCode = request.ColorCode;
        wallet.IconName = request.IconName;
        wallet.IsExcludedFromTotal = request.IsExcludedFromTotal;
        wallet.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return ApiResponse<WalletDto>.Ok(new WalletDto
        {
            Id = wallet.Id,
            Name = wallet.Name,
            Type = wallet.Type,
            InitialBalance = wallet.InitialBalance,
            CurrentBalance = wallet.CurrentBalance,
            Currency = wallet.Currency,
            ColorCode = wallet.ColorCode,
            IconName = wallet.IconName,
            IsExcludedFromTotal = wallet.IsExcludedFromTotal,
            CreatedAt = wallet.CreatedAt
        }, "Cập nhật ví thành công");
    }

    public async Task<ApiResponse<bool>> DeleteWalletAsync(Guid userId, Guid walletId)
    {
        var wallet = await _context.Wallets.FirstOrDefaultAsync(w => w.Id == walletId && w.UserId == userId);
        if (wallet == null)
            return ApiResponse<bool>.Fail("Không tìm thấy ví");

        wallet.IsDeleted = true;
        wallet.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return ApiResponse<bool>.Ok(true, "Xóa ví thành công");
    }

    public async Task<ApiResponse<TransferDto>> TransferMoneyAsync(Guid userId, TransferRequest request)
    {
        if (request.FromWalletId == request.ToWalletId)
            return ApiResponse<TransferDto>.Fail("Ví chuyển và ví nhận không được trùng nhau");

        if (request.Amount <= 0)
            return ApiResponse<TransferDto>.Fail("Số tiền chuyển phải lớn hơn 0");

        var fromWallet = await _context.Wallets.FirstOrDefaultAsync(w => w.Id == request.FromWalletId && w.UserId == userId);
        var toWallet = await _context.Wallets.FirstOrDefaultAsync(w => w.Id == request.ToWalletId && w.UserId == userId);

        if (fromWallet == null || toWallet == null)
            return ApiResponse<TransferDto>.Fail("Một trong hai ví không tồn tại hoặc không thuộc quyền sở hữu");

        var totalDeduction = request.Amount + request.Fee;

        // Bắt đầu Transaction Database ACID đảm bảo tính nguyên tử
        await using var dbTransaction = await _context.Database.BeginTransactionAsync();
        try
        {
            fromWallet.CurrentBalance -= totalDeduction;
            toWallet.CurrentBalance += request.Amount;

            fromWallet.UpdatedAt = DateTime.UtcNow;
            toWallet.UpdatedAt = DateTime.UtcNow;

            var transfer = new Transfer
            {
                FromWalletId = fromWallet.Id,
                ToWalletId = toWallet.Id,
                Amount = request.Amount,
                Fee = request.Fee,
                TransferDate = request.TransferDate ?? DateTime.UtcNow,
                Note = request.Note
            };

            _context.Transfers.Add(transfer);
            await _context.SaveChangesAsync();
            await dbTransaction.CommitAsync();

            return ApiResponse<TransferDto>.Ok(new TransferDto
            {
                Id = transfer.Id,
                FromWalletId = fromWallet.Id,
                FromWalletName = fromWallet.Name,
                ToWalletId = toWallet.Id,
                ToWalletName = toWallet.Name,
                Amount = transfer.Amount,
                Fee = transfer.Fee,
                TransferDate = transfer.TransferDate,
                Note = transfer.Note
            }, "Chuyển tiền thành công");
        }
        catch (Exception ex)
        {
            await dbTransaction.RollbackAsync();
            return ApiResponse<TransferDto>.Fail($"Lỗi khi thực hiện chuyển tiền: {ex.Message}");
        }
    }
}
