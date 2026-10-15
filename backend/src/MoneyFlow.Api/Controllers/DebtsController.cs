using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Debts;
using MoneyFlow.Application.Interfaces;

namespace MoneyFlow.Api.Controllers;

[Authorize]
public class DebtsController : BaseApiController
{
    private readonly IDebtService _debtService;

    public DebtsController(IDebtService debtService)
    {
        _debtService = debtService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<DebtSummaryDto>>> GetDebtsSummary()
    {
        var result = await _debtService.GetDebtsSummaryAsync(CurrentUserId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<DebtDto>>> CreateDebt([FromBody] CreateDebtRequest request)
    {
        var result = await _debtService.CreateDebtAsync(CurrentUserId, request);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [HttpPost("{id:guid}/payments")]
    public async Task<ActionResult<ApiResponse<DebtDto>>> MakePayment(Guid id, [FromBody] DebtPaymentRequest request)
    {
        var result = await _debtService.MakePaymentAsync(CurrentUserId, id, request);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteDebt(Guid id)
    {
        var result = await _debtService.DeleteDebtAsync(CurrentUserId, id);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }
}
