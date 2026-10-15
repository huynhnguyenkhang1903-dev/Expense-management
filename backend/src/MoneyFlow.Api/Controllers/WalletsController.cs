using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Wallets;
using MoneyFlow.Application.Interfaces;

namespace MoneyFlow.Api.Controllers;

[Authorize]
public class WalletsController : BaseApiController
{
    private readonly IWalletService _walletService;

    public WalletsController(IWalletService walletService)
    {
        _walletService = walletService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<WalletDto>>>> GetWallets()
    {
        var result = await _walletService.GetUserWalletsAsync(CurrentUserId);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ApiResponse<WalletDto>>> GetWallet(Guid id)
    {
        var result = await _walletService.GetWalletByIdAsync(CurrentUserId, id);
        if (!result.Success)
            return NotFound(result);

        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<WalletDto>>> CreateWallet([FromBody] CreateWalletRequest request)
    {
        var result = await _walletService.CreateWalletAsync(CurrentUserId, request);
        if (!result.Success)
            return BadRequest(result);

        return CreatedAtAction(nameof(GetWallet), new { id = result.Data!.Id }, result);
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<ApiResponse<WalletDto>>> UpdateWallet(Guid id, [FromBody] UpdateWalletRequest request)
    {
        var result = await _walletService.UpdateWalletAsync(CurrentUserId, id, request);
        if (!result.Success)
            return BadRequest(result);

        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteWallet(Guid id)
    {
        var result = await _walletService.DeleteWalletAsync(CurrentUserId, id);
        if (!result.Success)
            return BadRequest(result);

        return Ok(result);
    }

    [HttpPost("transfer")]
    public async Task<ActionResult<ApiResponse<TransferDto>>> TransferMoney([FromBody] TransferRequest request)
    {
        var result = await _walletService.TransferMoneyAsync(CurrentUserId, request);
        if (!result.Success)
            return BadRequest(result);

        return Ok(result);
    }
}
