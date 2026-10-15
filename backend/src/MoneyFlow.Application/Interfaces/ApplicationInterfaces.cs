using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Auth;
using MoneyFlow.Application.DTOs.Budgets;
using MoneyFlow.Application.DTOs.Categories;
using MoneyFlow.Application.DTOs.Reports;
using MoneyFlow.Application.DTOs.Transactions;
using MoneyFlow.Application.DTOs.Wallets;

namespace MoneyFlow.Application.Interfaces;

public interface IAuthService
{
    Task<ApiResponse<AuthResponse>> RegisterAsync(RegisterRequest request);
    Task<ApiResponse<AuthResponse>> LoginAsync(LoginRequest request);
    Task<ApiResponse<AuthResponse>> RefreshTokenAsync(RefreshTokenRequest request);
    Task<ApiResponse<bool>> ChangePasswordAsync(Guid userId, ChangePasswordRequest request);
}

public interface IWalletService
{
    Task<ApiResponse<List<WalletDto>>> GetUserWalletsAsync(Guid userId);
    Task<ApiResponse<WalletDto>> GetWalletByIdAsync(Guid userId, Guid walletId);
    Task<ApiResponse<WalletDto>> CreateWalletAsync(Guid userId, CreateWalletRequest request);
    Task<ApiResponse<WalletDto>> UpdateWalletAsync(Guid userId, Guid walletId, UpdateWalletRequest request);
    Task<ApiResponse<bool>> DeleteWalletAsync(Guid userId, Guid walletId);
    Task<ApiResponse<TransferDto>> TransferMoneyAsync(Guid userId, TransferRequest request);
}

public interface ICategoryService
{
    Task<ApiResponse<List<CategoryDto>>> GetCategoriesAsync(Guid userId);
    Task<ApiResponse<CategoryDto>> CreateCategoryAsync(Guid userId, CreateCategoryRequest request);
}

public interface ITransactionService
{
    Task<ApiResponse<PagedResult<TransactionDto>>> GetTransactionsAsync(Guid userId, TransactionFilterParams filter);
    Task<ApiResponse<TransactionDto>> GetTransactionByIdAsync(Guid userId, Guid transactionId);
    Task<ApiResponse<TransactionDto>> CreateTransactionAsync(Guid userId, CreateTransactionRequest request);
    Task<ApiResponse<TransactionDto>> UpdateTransactionAsync(Guid userId, Guid transactionId, UpdateTransactionRequest request);
    Task<ApiResponse<bool>> DeleteTransactionAsync(Guid userId, Guid transactionId);
}

public interface IBudgetService
{
    Task<ApiResponse<List<BudgetDto>>> GetBudgetsAsync(Guid userId, int month, int year);
    Task<ApiResponse<BudgetDto>> CreateOrUpdateBudgetAsync(Guid userId, CreateBudgetRequest request);
    Task<ApiResponse<bool>> DeleteBudgetAsync(Guid userId, Guid budgetId);
}

public interface IReportService
{
    Task<ApiResponse<DashboardSummaryDto>> GetDashboardSummaryAsync(Guid userId);
    Task<ApiResponse<List<CategoryExpenseReportDto>>> GetExpenseBreakdownAsync(Guid userId, DateTime fromDate, DateTime toDate);
    Task<ApiResponse<List<CashFlowReportDto>>> GetMonthlyCashFlowAsync(Guid userId, int year);
}

public interface ISavingsGoalService
{
    Task<ApiResponse<List<MoneyFlow.Application.DTOs.SavingsGoals.SavingsGoalDto>>> GetGoalsAsync(Guid userId);
    Task<ApiResponse<MoneyFlow.Application.DTOs.SavingsGoals.SavingsGoalDto>> CreateGoalAsync(Guid userId, MoneyFlow.Application.DTOs.SavingsGoals.CreateSavingsGoalRequest request);
    Task<ApiResponse<MoneyFlow.Application.DTOs.SavingsGoals.SavingsGoalDto>> DepositToGoalAsync(Guid userId, Guid goalId, MoneyFlow.Application.DTOs.SavingsGoals.DepositGoalRequest request);
    Task<ApiResponse<bool>> DeleteGoalAsync(Guid userId, Guid goalId);
}

public interface IDebtService
{
    Task<ApiResponse<MoneyFlow.Application.DTOs.Debts.DebtSummaryDto>> GetDebtsSummaryAsync(Guid userId);
    Task<ApiResponse<MoneyFlow.Application.DTOs.Debts.DebtDto>> CreateDebtAsync(Guid userId, MoneyFlow.Application.DTOs.Debts.CreateDebtRequest request);
    Task<ApiResponse<MoneyFlow.Application.DTOs.Debts.DebtDto>> MakePaymentAsync(Guid userId, Guid debtId, MoneyFlow.Application.DTOs.Debts.DebtPaymentRequest request);
    Task<ApiResponse<bool>> DeleteDebtAsync(Guid userId, Guid debtId);
}

public interface IBillService
{
    Task<ApiResponse<List<MoneyFlow.Application.DTOs.Bills.BillDto>>> GetBillsAsync(Guid userId);
    Task<ApiResponse<MoneyFlow.Application.DTOs.Bills.BillDto>> CreateBillAsync(Guid userId, MoneyFlow.Application.DTOs.Bills.CreateBillRequest request);
    Task<ApiResponse<MoneyFlow.Application.DTOs.Bills.BillDto>> PayBillAsync(Guid userId, Guid billId, MoneyFlow.Application.DTOs.Bills.PayBillRequest request);
    Task<ApiResponse<bool>> DeleteBillAsync(Guid userId, Guid billId);
}

public interface IAiAdvisorService
{
    Task<ApiResponse<MoneyFlow.Application.DTOs.AiAdvisor.FinancialHealthScoreDto>> GetHealthScoreAsync(Guid userId);
    Task<ApiResponse<List<MoneyFlow.Application.DTOs.AiAdvisor.FinancialInsightDto>>> GetInsightsAsync(Guid userId);
    Task<ApiResponse<MoneyFlow.Application.DTOs.AiAdvisor.AiChatResponse>> AskAiAdvisorAsync(Guid userId, MoneyFlow.Application.DTOs.AiAdvisor.AiChatRequest request);
}

public interface IExportService
{
    Task<byte[]> ExportTransactionsCsvAsync(Guid userId);
    Task<ApiResponse<List<MoneyFlow.Application.DTOs.Export.AuditLogDto>>> GetAuditLogsAsync(Guid userId);
}

