using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Transactions;
using MoneyFlow.Application.Interfaces;

namespace MoneyFlow.Api.Controllers;

[Authorize]
public class TransactionsController : BaseApiController
{
    private readonly ITransactionService _transactionService;

    public TransactionsController(ITransactionService transactionService)
    {
        _transactionService = transactionService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<PagedResult<TransactionDto>>>> GetTransactions([FromQuery] TransactionFilterParams filter)
    {
        var result = await _transactionService.GetTransactionsAsync(CurrentUserId, filter);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ApiResponse<TransactionDto>>> GetTransaction(Guid id)
    {
        var result = await _transactionService.GetTransactionByIdAsync(CurrentUserId, id);
        if (!result.Success)
            return NotFound(result);

        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<TransactionDto>>> CreateTransaction([FromBody] CreateTransactionRequest request)
    {
        var result = await _transactionService.CreateTransactionAsync(CurrentUserId, request);
        if (!result.Success)
            return BadRequest(result);

        return CreatedAtAction(nameof(GetTransaction), new { id = result.Data!.Id }, result);
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<ApiResponse<TransactionDto>>> UpdateTransaction(Guid id, [FromBody] UpdateTransactionRequest request)
    {
        var result = await _transactionService.UpdateTransactionAsync(CurrentUserId, id, request);
        if (!result.Success)
            return BadRequest(result);

        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteTransaction(Guid id)
    {
        var result = await _transactionService.DeleteTransactionAsync(CurrentUserId, id);
        if (!result.Success)
            return BadRequest(result);

        return Ok(result);
    }
}
