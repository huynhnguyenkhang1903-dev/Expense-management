using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.AiAdvisor;
using MoneyFlow.Application.Interfaces;

namespace MoneyFlow.Api.Controllers;

[Authorize]
[Route("api/v1/ai-advisor")]
public class AiAdvisorController : BaseApiController
{
    private readonly IAiAdvisorService _advisorService;

    public AiAdvisorController(IAiAdvisorService advisorService)
    {
        _advisorService = advisorService;
    }

    [HttpGet("health-score")]
    public async Task<ActionResult<ApiResponse<FinancialHealthScoreDto>>> GetHealthScore()
    {
        var result = await _advisorService.GetHealthScoreAsync(CurrentUserId);
        return Ok(result);
    }

    [HttpGet("insights")]
    public async Task<ActionResult<ApiResponse<List<FinancialInsightDto>>>> GetInsights()
    {
        var result = await _advisorService.GetInsightsAsync(CurrentUserId);
        return Ok(result);
    }

    [HttpPost("chat")]
    public async Task<ActionResult<ApiResponse<AiChatResponse>>> AskAiAdvisor([FromBody] AiChatRequest request)
    {
        var result = await _advisorService.AskAiAdvisorAsync(CurrentUserId, request);
        return Ok(result);
    }
}
