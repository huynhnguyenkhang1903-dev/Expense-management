using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Scalar.AspNetCore;
using MoneyFlow.Api.Middlewares;
using MoneyFlow.Api.Services;
using MoneyFlow.Application.Common.Interfaces;
using MoneyFlow.Application.Interfaces;
using MoneyFlow.Infrastructure.Data;
using MoneyFlow.Infrastructure.Services;

var builder = WebApplication.CreateBuilder(args);

// 1. Cấu hình EF Core với SQL Server
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=(localdb)\\mssqllocaldb;Database=MoneyFlowDb;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True";

builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseSqlServer(connectionString);
});

// 2. Cấu hình JWT Bearer Authentication
var jwtSecret = builder.Configuration["Jwt:Secret"] ?? "MoneyFlow_Super_Secure_Secret_Key_For_Jwt_Token_2026_DotNet10_Graduation_Project_Long_Enough!";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "MoneyFlowApi";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "MoneyFlowMobile";

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret)),
        ValidateIssuer = true,
        ValidIssuer = jwtIssuer,
        ValidateAudience = true,
        ValidAudience = jwtAudience,
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddAuthorization();

// 3. Đăng ký các dịch vụ tầng Application & Infrastructure
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddScoped<IJwtTokenService, JwtTokenService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IWalletService, WalletService>();
builder.Services.AddScoped<ICategoryService, CategoryService>();
builder.Services.AddScoped<ITransactionService, TransactionService>();
builder.Services.AddScoped<IBudgetService, BudgetService>();
builder.Services.AddScoped<IReportService, ReportService>();
builder.Services.AddScoped<ISavingsGoalService, SavingsGoalService>();
builder.Services.AddScoped<IDebtService, DebtService>();
builder.Services.AddScoped<IBillService, BillService>();
builder.Services.AddScoped<IAiAdvisorService, AiAdvisorService>();
builder.Services.AddScoped<IExportService, ExportService>();

// 4. Cấu hình CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddControllers();

// 5. Cấu hình OpenAPI (chuẩn .NET 10)
builder.Services.AddOpenApi();

var app = builder.Build();

// 6. Cấu hình Pipeline Middleware
app.UseMiddleware<GlobalExceptionMiddleware>();

if (app.Environment.IsDevelopment() || true)
{
    app.MapOpenApi();
    app.MapScalarApiReference(options =>
    {
        options.WithTitle("MoneyFlow API Docs")
               .WithTheme(ScalarTheme.Moon);
    });
}

app.UseCors("AllowAll");

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
