using Microsoft.EntityFrameworkCore;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Transactions;
using MoneyFlow.Application.Interfaces;
using MoneyFlow.Domain.Entities;
using MoneyFlow.Domain.Enums;
using MoneyFlow.Infrastructure.Data;

namespace MoneyFlow.Infrastructure.Services;

public class TransactionService : ITransactionService
{
    private readonly AppDbContext _context;

    public TransactionService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<PagedResult<TransactionDto>>> GetTransactionsAsync(Guid userId, TransactionFilterParams filter)
    {
        var query = _context.Transactions
            .Include(t => t.Wallet)
            .Include(t => t.Category)
            .Where(t => t.Wallet!.UserId == userId);

        if (filter.WalletId.HasValue)
            query = query.Where(t => t.WalletId == filter.WalletId.Value);

        if (filter.CategoryId.HasValue)
            query = query.Where(t => t.CategoryId == filter.CategoryId.Value);

        if (filter.Type.HasValue)
            query = query.Where(t => t.Type == filter.Type.Value);

        if (filter.FromDate.HasValue)
            query = query.Where(t => t.TransactionDate >= filter.FromDate.Value);

        if (filter.ToDate.HasValue)
            query = query.Where(t => t.TransactionDate <= filter.ToDate.Value);

        if (!string.IsNullOrWhiteSpace(filter.SearchTerm))
        {
            var search = filter.SearchTerm.Trim().ToLower();
            query = query.Where(t => t.Note != null && t.Note.ToLower().Contains(search));
        }

        var totalCount = await query.CountAsync();

        var pageIndex = filter.PageIndex < 1 ? 1 : filter.PageIndex;
        var pageSize = filter.PageSize < 1 ? 20 : (filter.PageSize > 100 ? 100 : filter.PageSize);

        var items = await query
            .OrderByDescending(t => t.TransactionDate)
            .ThenByDescending(t => t.CreatedAt)
            .Skip((pageIndex - 1) * pageSize)
            .Take(pageSize)
            .Select(t => new TransactionDto
            {
                Id = t.Id,
                WalletId = t.WalletId,
                WalletName = t.Wallet!.Name,
                CategoryId = t.CategoryId,
                CategoryName = t.Category!.Name,
                CategoryIcon = t.Category.Icon,
                CategoryColor = t.Category.Color,
                Type = t.Type,
                Amount = t.Amount,
                TransactionDate = t.TransactionDate,
                Note = t.Note,
                ImageUrl = t.ImageUrl,
                CreatedAt = t.CreatedAt
            })
            .ToListAsync();

        return ApiResponse<PagedResult<TransactionDto>>.Ok(new PagedResult<TransactionDto>
        {
            Items = items,
            PageIndex = pageIndex,
            PageSize = pageSize,
            TotalCount = totalCount
        });
    }

    public async Task<ApiResponse<TransactionDto>> GetTransactionByIdAsync(Guid userId, Guid transactionId)
    {
        var t = await _context.Transactions
            .Include(t => t.Wallet)
            .Include(t => t.Category)
            .FirstOrDefaultAsync(t => t.Id == transactionId && t.Wallet!.UserId == userId);

        if (t == null)
            return ApiResponse<TransactionDto>.Fail("Không tìm thấy giao dịch");

        return ApiResponse<TransactionDto>.Ok(new TransactionDto
        {
            Id = t.Id,
            WalletId = t.WalletId,
            WalletName = t.Wallet!.Name,
            CategoryId = t.CategoryId,
            CategoryName = t.Category!.Name,
            CategoryIcon = t.Category.Icon,
            CategoryColor = t.Category.Color,
            Type = t.Type,
            Amount = t.Amount,
            TransactionDate = t.TransactionDate,
            Note = t.Note,
            ImageUrl = t.ImageUrl,
            CreatedAt = t.CreatedAt
        });
    }

    public async Task<ApiResponse<TransactionDto>> CreateTransactionAsync(Guid userId, CreateTransactionRequest request)
    {
        if (request.Amount <= 0)
            return ApiResponse<TransactionDto>.Fail("Số tiền giao dịch phải lớn hơn 0");

        var wallet = await _context.Wallets.FirstOrDefaultAsync(w => w.Id == request.WalletId && w.UserId == userId);
        if (wallet == null)
            return ApiResponse<TransactionDto>.Fail("Ví được chọn không tồn tại hoặc không thuộc quyền sở hữu");

        var category = await _context.Categories.FirstOrDefaultAsync(c => c.Id == request.CategoryId && (c.UserId == null || c.UserId == userId));
        if (category == null)
            return ApiResponse<TransactionDto>.Fail("Danh mục không tồn tại");

        await using var dbTx = await _context.Database.BeginTransactionAsync();
        try
        {
            if (request.Type == TransactionType.Expense)
                wallet.CurrentBalance -= request.Amount;
            else
                wallet.CurrentBalance += request.Amount;

            wallet.UpdatedAt = DateTime.UtcNow;

            var transaction = new Transaction
            {
                WalletId = request.WalletId,
                CategoryId = request.CategoryId,
                Type = request.Type,
                Amount = request.Amount,
                TransactionDate = request.TransactionDate,
                Note = request.Note,
                ImageUrl = request.ImageUrl
            };

            _context.Transactions.Add(transaction);
            await _context.SaveChangesAsync();
            await dbTx.CommitAsync();

            return ApiResponse<TransactionDto>.Ok(new TransactionDto
            {
                Id = transaction.Id,
                WalletId = wallet.Id,
                WalletName = wallet.Name,
                CategoryId = category.Id,
                CategoryName = category.Name,
                CategoryIcon = category.Icon,
                CategoryColor = category.Color,
                Type = transaction.Type,
                Amount = transaction.Amount,
                TransactionDate = transaction.TransactionDate,
                Note = transaction.Note,
                ImageUrl = transaction.ImageUrl,
                CreatedAt = transaction.CreatedAt
            }, "Thêm giao dịch thành công");
        }
        catch (Exception ex)
        {
            await dbTx.RollbackAsync();
            return ApiResponse<TransactionDto>.Fail($"Lỗi khi ghi nhận giao dịch: {ex.Message}");
        }
    }

    public async Task<ApiResponse<TransactionDto>> UpdateTransactionAsync(Guid userId, Guid transactionId, UpdateTransactionRequest request)
    {
        if (request.Amount <= 0)
            return ApiResponse<TransactionDto>.Fail("Số tiền giao dịch phải lớn hơn 0");

        var transaction = await _context.Transactions
            .Include(t => t.Wallet)
            .Include(t => t.Category)
            .FirstOrDefaultAsync(t => t.Id == transactionId && t.Wallet!.UserId == userId);

        if (transaction == null)
            return ApiResponse<TransactionDto>.Fail("Không tìm thấy giao dịch");

        var newWallet = await _context.Wallets.FirstOrDefaultAsync(w => w.Id == request.WalletId && w.UserId == userId);
        if (newWallet == null)
            return ApiResponse<TransactionDto>.Fail("Ví đích không hợp lệ");

        var category = await _context.Categories.FirstOrDefaultAsync(c => c.Id == request.CategoryId && (c.UserId == null || c.UserId == userId));
        if (category == null)
            return ApiResponse<TransactionDto>.Fail("Danh mục không hợp lệ");

        await using var dbTx = await _context.Database.BeginTransactionAsync();
        try
        {
            // 1. Hoàn tác ảnh hưởng số dư cũ
            var oldWallet = transaction.Wallet!;
            if (transaction.Type == TransactionType.Expense)
                oldWallet.CurrentBalance += transaction.Amount;
            else
                oldWallet.CurrentBalance -= transaction.Amount;

            oldWallet.UpdatedAt = DateTime.UtcNow;

            // 2. Áp dụng ảnh hưởng số dư mới vào ví mới
            if (request.Type == TransactionType.Expense)
                newWallet.CurrentBalance -= request.Amount;
            else
                newWallet.CurrentBalance += request.Amount;

            newWallet.UpdatedAt = DateTime.UtcNow;

            // 3. Cập nhật thuộc tính giao dịch
            transaction.WalletId = request.WalletId;
            transaction.CategoryId = request.CategoryId;
            transaction.Type = request.Type;
            transaction.Amount = request.Amount;
            transaction.TransactionDate = request.TransactionDate;
            transaction.Note = request.Note;
            transaction.ImageUrl = request.ImageUrl;
            transaction.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            await dbTx.CommitAsync();

            return ApiResponse<TransactionDto>.Ok(new TransactionDto
            {
                Id = transaction.Id,
                WalletId = newWallet.Id,
                WalletName = newWallet.Name,
                CategoryId = category.Id,
                CategoryName = category.Name,
                CategoryIcon = category.Icon,
                CategoryColor = category.Color,
                Type = transaction.Type,
                Amount = transaction.Amount,
                TransactionDate = transaction.TransactionDate,
                Note = transaction.Note,
                ImageUrl = transaction.ImageUrl,
                CreatedAt = transaction.CreatedAt
            }, "Cập nhật giao dịch thành công");
        }
        catch (Exception ex)
        {
            await dbTx.RollbackAsync();
            return ApiResponse<TransactionDto>.Fail($"Lỗi khi cập nhật giao dịch: {ex.Message}");
        }
    }

    public async Task<ApiResponse<bool>> DeleteTransactionAsync(Guid userId, Guid transactionId)
    {
        var transaction = await _context.Transactions
            .Include(t => t.Wallet)
            .FirstOrDefaultAsync(t => t.Id == transactionId && t.Wallet!.UserId == userId);

        if (transaction == null)
            return ApiResponse<bool>.Fail("Không tìm thấy giao dịch");

        await using var dbTx = await _context.Database.BeginTransactionAsync();
        try
        {
            var wallet = transaction.Wallet!;
            // Hoàn lại số dư
            if (transaction.Type == TransactionType.Expense)
                wallet.CurrentBalance += transaction.Amount;
            else
                wallet.CurrentBalance -= transaction.Amount;

            wallet.UpdatedAt = DateTime.UtcNow;

            transaction.IsDeleted = true;
            transaction.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            await dbTx.CommitAsync();

            return ApiResponse<bool>.Ok(true, "Xóa giao dịch thành công");
        }
        catch (Exception ex)
        {
            await dbTx.RollbackAsync();
            return ApiResponse<bool>.Fail($"Lỗi khi xóa giao dịch: {ex.Message}");
        }
    }
}
