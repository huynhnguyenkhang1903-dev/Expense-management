using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Reports;
using MoneyFlow.Application.Interfaces;

namespace MoneyFlow.Api.Controllers;

[Authorize]
public class ReportsController : BaseApiController
{
    private readonly IReportService _reportService;

    public ReportsController(IReportService reportService)
    {
        _reportService = reportService;
    }

    [HttpGet("dashboard")]
    public async Task<ActionResult<ApiResponse<DashboardSummaryDto>>> GetDashboardSummary()
    {
        var result = await _reportService.GetDashboardSummaryAsync(CurrentUserId);
        return Ok(result);
    }

    [HttpGet("category-breakdown")]
    public async Task<ActionResult<ApiResponse<List<CategoryExpenseReportDto>>>> GetCategoryBreakdown(
        [FromQuery] DateTime? fromDate,
        [FromQuery] DateTime? toDate)
    {
        var now = DateTime.UtcNow;
        var start = fromDate ?? new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var end = toDate ?? start.AddMonths(1).AddTicks(-1);

        var result = await _reportService.GetExpenseBreakdownAsync(CurrentUserId, start, end);
        return Ok(result);
    }

    [HttpGet("monthly-cashflow")]
    public async Task<ActionResult<ApiResponse<List<CashFlowReportDto>>>> GetMonthlyCashFlow([FromQuery] int? year)
    {
        var targetYear = year ?? DateTime.UtcNow.Year;
        var result = await _reportService.GetMonthlyCashFlowAsync(CurrentUserId, targetYear);
        return Ok(result);
    }
}
