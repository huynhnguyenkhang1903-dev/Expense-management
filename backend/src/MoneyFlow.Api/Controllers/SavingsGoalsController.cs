using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.SavingsGoals;
using MoneyFlow.Application.Interfaces;

namespace MoneyFlow.Api.Controllers;

[Authorize]
[Route("api/v1/savings-goals")]
public class SavingsGoalsController : BaseApiController
{
    private readonly ISavingsGoalService _goalService;

    public SavingsGoalsController(ISavingsGoalService goalService)
    {
        _goalService = goalService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<SavingsGoalDto>>>> GetGoals()
    {
        var result = await _goalService.GetGoalsAsync(CurrentUserId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<SavingsGoalDto>>> CreateGoal([FromBody] CreateSavingsGoalRequest request)
    {
        var result = await _goalService.CreateGoalAsync(CurrentUserId, request);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [HttpPost("{id:guid}/deposit")]
    public async Task<ActionResult<ApiResponse<SavingsGoalDto>>> DepositToGoal(Guid id, [FromBody] DepositGoalRequest request)
    {
        var result = await _goalService.DepositToGoalAsync(CurrentUserId, id, request);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteGoal(Guid id)
    {
        var result = await _goalService.DeleteGoalAsync(CurrentUserId, id);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }
}
