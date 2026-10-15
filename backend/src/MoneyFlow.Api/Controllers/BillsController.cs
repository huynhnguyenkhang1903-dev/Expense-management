using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Bills;
using MoneyFlow.Application.Interfaces;

namespace MoneyFlow.Api.Controllers;

[Authorize]
public class BillsController : BaseApiController
{
    private readonly IBillService _billService;

    public BillsController(IBillService billService)
    {
        _billService = billService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<BillDto>>>> GetBills()
    {
        var result = await _billService.GetBillsAsync(CurrentUserId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<BillDto>>> CreateBill([FromBody] CreateBillRequest request)
    {
        var result = await _billService.CreateBillAsync(CurrentUserId, request);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [HttpPost("{id:guid}/pay")]
    public async Task<ActionResult<ApiResponse<BillDto>>> PayBill(Guid id, [FromBody] PayBillRequest request)
    {
        var result = await _billService.PayBillAsync(CurrentUserId, id, request);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteBill(Guid id)
    {
        var result = await _billService.DeleteBillAsync(CurrentUserId, id);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }
}
