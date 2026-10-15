using Microsoft.EntityFrameworkCore;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Auth;
using MoneyFlow.Application.Interfaces;
using MoneyFlow.Domain.Entities;
using MoneyFlow.Domain.Enums;
using MoneyFlow.Infrastructure.Data;

namespace MoneyFlow.Infrastructure.Services;

public class AuthService : IAuthService
{
    private readonly AppDbContext _context;
    private readonly IJwtTokenService _jwtTokenService;

    public AuthService(AppDbContext context, IJwtTokenService jwtTokenService)
    {
        _context = context;
        _jwtTokenService = jwtTokenService;
    }

    public async Task<ApiResponse<AuthResponse>> RegisterAsync(RegisterRequest request)
    {
        var emailLower = request.Email.Trim().ToLower();
        var existingUser = await _context.Users.AnyAsync(u => u.Email.ToLower() == emailLower);
        if (existingUser)
        {
            return ApiResponse<AuthResponse>.Fail("Email đã được đăng ký trong hệ thống");
        }

        var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
        var user = new User
        {
            FullName = request.FullName.Trim(),
            Email = emailLower,
            PasswordHash = passwordHash,
            DefaultCurrency = string.IsNullOrWhiteSpace(request.DefaultCurrency) ? "VND" : request.DefaultCurrency
        };

        var refreshToken = _jwtTokenService.GenerateRefreshToken();
        user.RefreshToken = refreshToken;
        user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(30);

        _context.Users.Add(user);

        // Tự động tạo ví tiền mặt mặc định cho người dùng mới
        var defaultWallet = new Wallet
        {
            UserId = user.Id,
            Name = "Tiền mặt",
            Type = WalletType.Cash,
            InitialBalance = 0,
            CurrentBalance = 0,
            Currency = user.DefaultCurrency,
            ColorCode = "#10B981",
            IconName = "wallet"
        };
        _context.Wallets.Add(defaultWallet);

        await _context.SaveChangesAsync();

        var (accessToken, expiresAt) = _jwtTokenService.GenerateAccessToken(user);

        return ApiResponse<AuthResponse>.Ok(new AuthResponse
        {
            UserId = user.Id,
            FullName = user.FullName,
            Email = user.Email,
            DefaultCurrency = user.DefaultCurrency,
            AccessToken = accessToken,
            RefreshToken = refreshToken,
            ExpiresAt = expiresAt
        }, "Đăng ký tài khoản thành công");
    }

    public async Task<ApiResponse<AuthResponse>> LoginAsync(LoginRequest request)
    {
        var emailLower = request.Email.Trim().ToLower();
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == emailLower);
        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            return ApiResponse<AuthResponse>.Fail("Email hoặc mật khẩu không chính xác");
        }

        if (!user.IsActive)
        {
            return ApiResponse<AuthResponse>.Fail("Tài khoản của bạn đã bị vô hiệu hóa");
        }

        var (accessToken, expiresAt) = _jwtTokenService.GenerateAccessToken(user);
        var refreshToken = _jwtTokenService.GenerateRefreshToken();

        user.RefreshToken = refreshToken;
        user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(30);
        user.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return ApiResponse<AuthResponse>.Ok(new AuthResponse
        {
            UserId = user.Id,
            FullName = user.FullName,
            Email = user.Email,
            DefaultCurrency = user.DefaultCurrency,
            AccessToken = accessToken,
            RefreshToken = refreshToken,
            ExpiresAt = expiresAt
        }, "Đăng nhập thành công");
    }

    public async Task<ApiResponse<AuthResponse>> RefreshTokenAsync(RefreshTokenRequest request)
    {
        var principal = _jwtTokenService.GetPrincipalFromExpiredToken(request.AccessToken);
        if (principal == null)
        {
            return ApiResponse<AuthResponse>.Fail("Token không hợp lệ");
        }

        var userIdClaim = principal.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userIdClaim, out var userId))
        {
            return ApiResponse<AuthResponse>.Fail("Token chứa thông tin người dùng không hợp lệ");
        }

        var user = await _context.Users.FindAsync(userId);
        if (user == null || user.RefreshToken != request.RefreshToken || user.RefreshTokenExpiryTime <= DateTime.UtcNow)
        {
            return ApiResponse<AuthResponse>.Fail("Refresh token không hợp lệ hoặc đã hết hạn");
        }

        var (newAccessToken, expiresAt) = _jwtTokenService.GenerateAccessToken(user);
        var newRefreshToken = _jwtTokenService.GenerateRefreshToken();

        user.RefreshToken = newRefreshToken;
        user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(30);
        user.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return ApiResponse<AuthResponse>.Ok(new AuthResponse
        {
            UserId = user.Id,
            FullName = user.FullName,
            Email = user.Email,
            DefaultCurrency = user.DefaultCurrency,
            AccessToken = newAccessToken,
            RefreshToken = newRefreshToken,
            ExpiresAt = expiresAt
        }, "Cấp lại token thành công");
    }

    public async Task<ApiResponse<bool>> ChangePasswordAsync(Guid userId, ChangePasswordRequest request)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return ApiResponse<bool>.Fail("Không tìm thấy người dùng");
        }

        if (!BCrypt.Net.BCrypt.Verify(request.CurrentPassword, user.PasswordHash))
        {
            return ApiResponse<bool>.Fail("Mật khẩu hiện tại không chính xác");
        }

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        user.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return ApiResponse<bool>.Ok(true, "Đổi mật khẩu thành công");
    }
}
