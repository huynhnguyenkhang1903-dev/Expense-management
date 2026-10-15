using System.Text;
using Microsoft.EntityFrameworkCore;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Export;
using MoneyFlow.Application.Interfaces;
using MoneyFlow.Infrastructure.Data;

namespace MoneyFlow.Infrastructure.Services;

public class ExportService : IExportService
{
    private readonly AppDbContext _context;

    public ExportService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<byte[]> ExportTransactionsCsvAsync(Guid userId)
    {
        var transactions = await _context.Transactions
            .Include(t => t.Category)
            .Include(t => t.Wallet)
            .Where(t => t.Wallet!.UserId == userId)
            .OrderByDescending(t => t.TransactionDate)
            .ToListAsync();

        var sb = new StringBuilder();
        // Thêm UTF-8 BOM để Excel hiển thị đúng dấu tiếng Việt
        sb.AppendLine("ID Giao Dịch,Thời Gian,Loại,Danh Mục,Ví Thanh Toán,Số Tiền (VND),Ghi Chú");

        foreach (var t in transactions)
        {
            var typeStr = t.Type.ToString() == "Expense" ? "Chi tiêu" : "Thu nhập";
            var note = (t.Note ?? string.Empty).Replace("\"", "\"\"");
            sb.AppendLine($"\"{t.Id}\",\"{t.TransactionDate:yyyy-MM-dd HH:mm:ss}\",\"{typeStr}\",\"{t.Category?.Name}\",\"{t.Wallet?.Name}\",\"{t.Amount:F0}\",\"{note}\"");
        }

        var preamble = Encoding.UTF8.GetPreamble();
        var contentBytes = Encoding.UTF8.GetBytes(sb.ToString());
        var finalBytes = new byte[preamble.Length + contentBytes.Length];
        Buffer.BlockCopy(preamble, 0, finalBytes, 0, preamble.Length);
        Buffer.BlockCopy(contentBytes, 0, finalBytes, preamble.Length, contentBytes.Length);

        return finalBytes;
    }

    public async Task<ApiResponse<List<AuditLogDto>>> GetAuditLogsAsync(Guid userId)
    {
        var logs = await _context.AuditLogs
            .Where(a => a.UserId == userId)
            .OrderByDescending(a => a.CreatedAt)
            .Take(50)
            .Select(a => new AuditLogDto
            {
                Id = a.Id,
                Action = a.Action,
                EntityName = a.EntityName,
                EntityId = a.EntityId.HasValue ? a.EntityId.Value.ToString() : null,
                Details = a.Details,
                CreatedAt = a.Timestamp
            })
            .ToListAsync();

        return ApiResponse<List<AuditLogDto>>.Ok(logs);
    }
}
