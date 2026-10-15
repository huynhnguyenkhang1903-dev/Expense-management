using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Budgets;
using MoneyFlow.Application.Interfaces;

namespace MoneyFlow.Api.Controllers;

[Authorize]
public class BudgetsController : BaseApiController
{
    private readonly IBudgetService _budgetService;

    public BudgetsController(IBudgetService budgetService)
    {
        _budgetService = budgetService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<BudgetDto>>>> GetBudgets([FromQuery] int? month, [FromQuery] int? year)
    {
        var targetMonth = month ?? DateTime.UtcNow.Month;
        var targetYear = year ?? DateTime.UtcNow.Year;

        var result = await _budgetService.GetBudgetsAsync(CurrentUserId, targetMonth, targetYear);
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<BudgetDto>>> CreateOrUpdateBudget([FromBody] CreateBudgetRequest request)
    {
        var result = await _budgetService.CreateOrUpdateBudgetAsync(CurrentUserId, request);
        if (!result.Success)
            return BadRequest(result);

        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteBudget(Guid id)
    {
        var result = await _budgetService.DeleteBudgetAsync(CurrentUserId, id);
        if (!result.Success)
            return BadRequest(result);

        return Ok(result);
    }
}
