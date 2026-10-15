using Microsoft.EntityFrameworkCore;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.AiAdvisor;
using MoneyFlow.Application.Interfaces;
using MoneyFlow.Domain.Enums;
using MoneyFlow.Infrastructure.Data;

namespace MoneyFlow.Infrastructure.Services;

public class AiAdvisorService : IAiAdvisorService
{
    private readonly AppDbContext _context;

    public AiAdvisorService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<FinancialHealthScoreDto>> GetHealthScoreAsync(Guid userId)
    {
        var now = DateTime.UtcNow;
        var startOfMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var thirtyDaysAgo = now.AddDays(-30);

        // 1. Tổng số dư hiện tại của tất cả ví
        var totalBalance = await _context.Wallets
            .Where(w => w.UserId == userId)
            .SumAsync(w => (decimal?)w.CurrentBalance) ?? 0m;

        // 2. Thu chi 30 ngày gần nhất
        var recentTransactions = await _context.Transactions
            .Where(t => t.Wallet!.UserId == userId && t.TransactionDate >= thirtyDaysAgo)
            .ToListAsync();

        var recentIncome = recentTransactions.Where(t => t.Type == TransactionType.Income).Sum(t => t.Amount);
        var recentExpense = recentTransactions.Where(t => t.Type == TransactionType.Expense).Sum(t => t.Amount);

        // 3. Tỷ lệ tiết kiệm và tỷ lệ chi tiêu
        decimal savingsRate = 0m;
        decimal expenseRatio = 0m;
        if (recentIncome > 0)
        {
            var netSavings = Math.Max(0, recentIncome - recentExpense);
            savingsRate = Math.Round((netSavings / recentIncome) * 100, 1);
            expenseRatio = Math.Round((recentExpense / recentIncome) * 100, 1);
        }
        else if (recentExpense == 0)
        {
            savingsRate = 50m;
            expenseRatio = 0m;
        }
        else
        {
            savingsRate = 0m;
            expenseRatio = 100m;
        }

        // 4. Dự phòng khẩn cấp (Emergency Runway Months)
        var monthlyBurn = recentExpense > 0 ? recentExpense : 5000000m;
        decimal emergencyRunway = Math.Round(totalBalance / monthlyBurn, 1);

        // 5. Kỷ luật ngân sách (Budget Discipline)
        var currentBudgets = await _context.Budgets
            .Where(b => b.UserId == userId && b.Month == now.Month && b.Year == now.Year)
            .ToListAsync();

        int budgetScore = 250;
        int exceededBudgetsCount = 0;
        if (currentBudgets.Any())
        {
            foreach (var b in currentBudgets)
            {
                var query = _context.Transactions
                    .Where(t => t.Wallet!.UserId == userId && t.Type == TransactionType.Expense && t.TransactionDate >= startOfMonth);
                if (b.CategoryId.HasValue)
                    query = query.Where(t => t.CategoryId == b.CategoryId.Value);

                var spent = await query.SumAsync(t => (decimal?)t.Amount) ?? 0m;
                if (spent > b.LimitAmount) exceededBudgetsCount++;
            }

            budgetScore = Math.Max(60, 250 - (exceededBudgetsCount * 80));
        }

        // Tính điểm 4 trụ cột (Mỗi trụ cột tối đa 250 điểm)
        int savingsScore = savingsRate >= 35 ? 250 : savingsRate >= 20 ? 210 : savingsRate >= 10 ? 160 : savingsRate > 0 ? 110 : 50;
        int expenseScore = expenseRatio <= 50 ? 250 : expenseRatio <= 70 ? 210 : expenseRatio <= 85 ? 160 : expenseRatio <= 100 ? 110 : 60;
        int runwayScore = emergencyRunway >= 6 ? 250 : emergencyRunway >= 3 ? 210 : emergencyRunway >= 1 ? 160 : emergencyRunway > 0 ? 100 : 50;

        int totalScore = Math.Clamp(savingsScore + expenseScore + runwayScore + budgetScore, 100, 1000);

        string grade;
        string title;
        string desc;

        if (totalScore >= 850)
        {
            grade = "AAA+";
            title = "VIP Prime Client · Đẳng Cấp Toàn Diện";
            desc = "Cơ cấu tài chính đạt chuẩn Private Banking. Bạn có tỷ lệ tiết kiệm lý tưởng và dòng tiền kiểm soát chặt chẽ.";
        }
        else if (totalScore >= 700)
        {
            grade = "AA";
            title = "Khách Hàng Ưu Tiên · Tăng Trưởng Vững Vàng";
            desc = "Sức khỏe tài chính rất tốt. Thu nhập vượt trội chi phí sinh hoạt, nền tảng tích lũy ổn định.";
        }
        else if (totalScore >= 550)
        {
            grade = "A";
            title = "Hạng Vàng Tiềm Năng · Cân Bằng Ổn Định";
            desc = "Dòng tiền cân bằng, kiểm soát tốt các danh mục chi tiêu cơ bản. Nên gia tăng quỹ tích lũy dự phòng.";
        }
        else if (totalScore >= 400)
        {
            grade = "B";
            title = "Hạng Bạc · Cần Tối Ưu Chi Phí";
            desc = "Chi phí sinh hoạt đang chiếm tỷ lệ cao trong thu nhập. Khuyến nghị cắt giảm các khoản chi ngoài kế hoạch.";
        }
        else
        {
            grade = "C";
            title = "Hạng C · Cần Tái Cơ Cấu Tài Chính";
            desc = "Dòng tiền có nguy cơ âm hoặc thâm hụt dự phòng. Cần thiết lập ngân sách nghiêm ngặt ngay hôm nay.";
        }

        var insights = await GenerateInsightsInternalAsync(userId, recentIncome, recentExpense, totalBalance, emergencyRunway);

        var result = new FinancialHealthScoreDto
        {
            Score = totalScore,
            RatingGrade = grade,
            RatingTitle = title,
            RatingDescription = desc,
            SavingsRatePercentage = savingsRate,
            ExpenseToIncomeRatio = expenseRatio,
            EmergencyRunwayMonths = emergencyRunway,
            BudgetDisciplinePercentage = Math.Max(0, 100 - (exceededBudgetsCount * 25)),
            SavingsPillarScore = savingsScore,
            ExpensePillarScore = expenseScore,
            RunwayPillarScore = runwayScore,
            BudgetPillarScore = budgetScore,
            TopInsights = insights
        };

        return ApiResponse<FinancialHealthScoreDto>.Ok(result);
    }

    public async Task<ApiResponse<List<FinancialInsightDto>>> GetInsightsAsync(Guid userId)
    {
        var now = DateTime.UtcNow;
        var thirtyDaysAgo = now.AddDays(-30);

        var totalBalance = await _context.Wallets
            .Where(w => w.UserId == userId)
            .SumAsync(w => (decimal?)w.CurrentBalance) ?? 0m;

        var recentTransactions = await _context.Transactions
            .Where(t => t.Wallet!.UserId == userId && t.TransactionDate >= thirtyDaysAgo)
            .ToListAsync();

        var recentIncome = recentTransactions.Where(t => t.Type == TransactionType.Income).Sum(t => t.Amount);
        var recentExpense = recentTransactions.Where(t => t.Type == TransactionType.Expense).Sum(t => t.Amount);
        var runway = recentExpense > 0 ? Math.Round(totalBalance / recentExpense, 1) : 6m;

        var insights = await GenerateInsightsInternalAsync(userId, recentIncome, recentExpense, totalBalance, runway);
        return ApiResponse<List<FinancialInsightDto>>.Ok(insights);
    }

    private async Task<List<FinancialInsightDto>> GenerateInsightsInternalAsync(Guid userId, decimal recentIncome, decimal recentExpense, decimal totalBalance, decimal runway)
    {
        var list = new List<FinancialInsightDto>();
        var now = DateTime.UtcNow;

        // 1. Phân tích danh mục chi tiêu đột biến
        var topExpenseCategory = await _context.Transactions
            .Where(t => t.Wallet!.UserId == userId && t.Type == TransactionType.Expense && t.TransactionDate >= now.AddDays(-30))
            .GroupBy(t => t.Category!.Name)
            .Select(g => new { Category = g.Key, Total = g.Sum(x => x.Amount) })
            .OrderByDescending(x => x.Total)
            .FirstOrDefaultAsync();

        if (topExpenseCategory != null && topExpenseCategory.Total > 0)
        {
            list.Add(new FinancialInsightDto
            {
                Type = "Optimization",
                Category = "Expense",
                Title = $"Trọng tâm chi tiêu: {topExpenseCategory.Category}",
                Message = $"Trong 30 ngày qua, danh mục '{topExpenseCategory.Category}' chiếm {topExpenseCategory.Total:N0} ₫. Hãy cân nhắc đặt hạn mức ngân sách để tối ưu dòng tiền.",
                ActionText = "Thiết lập ngân sách",
                ImpactLevel = "High"
            });
        }

        // 2. Dự phòng tài chính khẩn cấp
        if (runway >= 6)
        {
            list.Add(new FinancialInsightDto
            {
                Type = "Success",
                Category = "Savings",
                Title = "Quỹ dự phòng an toàn tuyệt đối",
                Message = $"Số dư hiện hữu ({totalBalance:N0} ₫) đủ để duy trì sinh hoạt trong {runway:N1} tháng tới mà không cần thêm thu nhập.",
                ActionText = "Tạo hũ đầu tư",
                ImpactLevel = "Medium"
            });
        }
        else if (runway < 2)
        {
            list.Add(new FinancialInsightDto
            {
                Type = "Warning",
                Category = "Savings",
                Title = "Cảnh báo quỹ dự trữ mỏng",
                Message = $"Tổng số dư ví chỉ đủ cho {runway:N1} tháng chi tiêu. Khuyến nghị ưu tiên trích 10% thu nhập mỗi tháng vào Hũ Tiết Kiệm Khẩn Cấp.",
                ActionText = "Gia tăng hũ tích lũy",
                ImpactLevel = "High"
            });
        }

        // 3. Kiểm tra hóa đơn định kỳ sắp đến hạn
        var upcomingBills = await _context.Bills
            .Where(b => b.UserId == userId && b.Status == BillStatus.Pending && b.DueDate <= now.AddDays(5))
            .ToListAsync();

        if (upcomingBills.Any())
        {
            var totalBillAmount = upcomingBills.Sum(b => b.Amount);
            list.Add(new FinancialInsightDto
            {
                Type = "Warning",
                Category = "Budget",
                Title = $"Có {upcomingBills.Count} hóa đơn sắp đến hạn",
                Message = $"Tổng số tiền {totalBillAmount:N0} ₫ cần thanh toán trong 5 ngày tới. Đảm bảo ví chính có đủ số dư thanh toán.",
                ActionText = "Xem hóa đơn",
                ImpactLevel = "High"
            });
        }

        // 4. Mẹo tài chính từ AI
        list.Add(new FinancialInsightDto
        {
            Type = "Tip",
            Category = "General",
            Title = "Nguyên tắc 50/30/20 của Cố vấn Tài chính",
            Message = "Phân bổ 50% thu nhập cho Nhu cầu thiết yếu, 30% cho Mong muốn cá nhân, và tối thiểu 20% cho Tiết kiệm & Tích lũy.",
            ActionText = "Khám phá thêm",
            ImpactLevel = "Low"
        });

        return list;
    }

    public async Task<ApiResponse<AiChatResponse>> AskAiAdvisorAsync(Guid userId, AiChatRequest request)
    {
        var now = DateTime.UtcNow;
        var totalBalance = await _context.Wallets
            .Where(w => w.UserId == userId)
            .SumAsync(w => (decimal?)w.CurrentBalance) ?? 0m;

        var startOfMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var thisMonthExpense = await _context.Transactions
            .Where(t => t.Wallet!.UserId == userId && t.Type == TransactionType.Expense && t.TransactionDate >= startOfMonth)
            .SumAsync(t => (decimal?)t.Amount) ?? 0m;

        var thisMonthIncome = await _context.Transactions
            .Where(t => t.Wallet!.UserId == userId && t.Type == TransactionType.Income && t.TransactionDate >= startOfMonth)
            .SumAsync(t => (decimal?)t.Amount) ?? 0m;

        var q = request.Question.ToLower();
        string answer;
        var suggestions = new List<string>
        {
            "Tháng này tôi đã chi tiêu bao nhiêu?",
            "Làm thế nào để nâng điểm sức khỏe tài chính?",
            "Tôi có nên mua món đồ đắt tiền ngay bây giờ không?",
            "Cách thiết lập hũ tiết kiệm 6 tháng khẩn cấp?"
        };

        if (q.Contains("chi tiêu") || q.Contains("đã tiêu") || q.Contains("hết bao nhiêu"))
        {
            answer = $"Trong tháng {now.Month}/{now.Year}, bạn đã ghi nhận tổng chi tiêu là **{thisMonthExpense:N0} ₫**, trên tổng thu nhập **{thisMonthIncome:N0} ₫**.\n\n" +
                     (thisMonthIncome > 0 && thisMonthExpense <= thisMonthIncome * 0.7m
                        ? "✅ Dòng tiền đang được kiểm soát rất tốt (dưới 70% thu nhập)."
                        : "⚠️ Chi tiêu đang chiếm tỷ trọng lớn trong tháng, hãy lưu ý các danh mục mua sắm và giải trí.");
        }
        else if (q.Contains("điểm") || q.Contains("sức khỏe") || q.Contains("xếp hạng"))
        {
            answer = $"Để đạt hạng **VIP AAA+ Prime Client (850+ điểm)**, Cố vấn AI gợi ý 3 bước hành động:\n" +
                     "1. **Tích lũy tối thiểu 20%** thu nhập vào các Hũ Tiết Kiệm.\n" +
                     "2. **Duy trì quỹ dự phòng** tương đương 3 đến 6 tháng chi phí sinh hoạt tối thiểu.\n" +
                     "3. **Không để vượt hạn mức ngân sách** đã thiết lập trong kỳ.";
        }
        else if (q.Contains("mua") || q.Contains("sắm") || q.Contains("đắt tiền"))
        {
            decimal safetyBudget = totalBalance * 0.15m;
            answer = $"Dựa trên số dư khả dụng hiện tại ({totalBalance:N0} ₫), hạn mức mua sắm an toàn khuyến nghị cho một món đồ là dưới **{safetyBudget:N0} ₫** (không quá 15% tổng tài sản lỏng).\n\n" +
                     "Quy tắc 48 Giờ: Hãy tạm dừng 48 giờ trước khi thanh toán món đồ không thiết yếu. Nếu sau 2 ngày bạn vẫn thực sự cần nó, hãy quyết định mua!";
        }
        else
        {
            answer = $"Chào bạn! Tôi là **MoneyFlow AI Advisor** — trợ lý tài chính thông minh của bạn.\n\n" +
                     $"Hiện tại bạn có tổng số dư khả dụng là **{totalBalance:N0} ₫**, thu nhập tháng này là **{thisMonthIncome:N0} ₫**, và đã chi tiêu **{thisMonthExpense:N0} ₫**.\n\n" +
                     "Tôi có thể hỗ trợ bạn phân tích thói quen tiêu dùng, dự báo dòng tiền tương lai, lên kế hoạch trả nợ và tối ưu hũ tiết kiệm.";
        }

        return ApiResponse<AiChatResponse>.Ok(new AiChatResponse
        {
            Answer = answer,
            SuggestedQuestions = suggestions,
            AnsweredAt = DateTime.UtcNow
        });
    }
}
