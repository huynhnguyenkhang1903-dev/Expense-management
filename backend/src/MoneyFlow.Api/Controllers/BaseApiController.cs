using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;

namespace MoneyFlow.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public abstract class BaseApiController : ControllerBase
{
    protected Guid CurrentUserId
    {
        get
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (Guid.TryParse(claim, out var id))
                return id;

            throw new UnauthorizedAccessException("Người dùng chưa được xác thực hoặc phiên đăng nhập không hợp lệ");
        }
    }
}
