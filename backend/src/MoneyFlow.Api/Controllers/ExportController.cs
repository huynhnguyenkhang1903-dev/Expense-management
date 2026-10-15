using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Export;
using MoneyFlow.Application.Interfaces;

namespace MoneyFlow.Api.Controllers;

[Authorize]
public class ExportController : BaseApiController
{
    private readonly IExportService _exportService;

    public ExportController(IExportService exportService)
    {
        _exportService = exportService;
    }

    [HttpGet("csv")]
    public async Task<IActionResult> ExportCsv()
    {
        var bytes = await _exportService.ExportTransactionsCsvAsync(CurrentUserId);
        var fileName = $"MoneyFlow_Transactions_{DateTime.UtcNow:yyyyMMdd_HHmmss}.csv";
        return File(bytes, "text/csv; charset=utf-8", fileName);
    }

    [HttpGet("audit-logs")]
    public async Task<ActionResult<ApiResponse<List<AuditLogDto>>>> GetAuditLogs()
    {
        var result = await _exportService.GetAuditLogsAsync(CurrentUserId);
        return Ok(result);
    }
}
