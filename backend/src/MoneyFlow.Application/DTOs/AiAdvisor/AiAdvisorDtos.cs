namespace MoneyFlow.Application.DTOs.AiAdvisor;

public class FinancialHealthScoreDto
{
    public int Score { get; set; } // 0 - 1000
    public string RatingGrade { get; set; } = "AAA+"; // AAA+, AA, A, B, C
    public string RatingTitle { get; set; } = "Khách Hàng Ưu Tiên VIP";
    public string RatingDescription { get; set; } = string.Empty;
    public decimal SavingsRatePercentage { get; set; }
    public decimal ExpenseToIncomeRatio { get; set; }
    public decimal EmergencyRunwayMonths { get; set; }
    public decimal BudgetDisciplinePercentage { get; set; }
    
    // 4 Pillar Scores (mỗi pillar tối đa 250 điểm)
    public int SavingsPillarScore { get; set; }
    public int ExpensePillarScore { get; set; }
    public int RunwayPillarScore { get; set; }
    public int BudgetPillarScore { get; set; }

    public List<FinancialInsightDto> TopInsights { get; set; } = new();
}

public class FinancialInsightDto
{
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string Type { get; set; } = "Warning"; // Tip, Warning, Success, Optimization
    public string Category { get; set; } = "General"; // Expense, Budget, Savings, Debt
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string? ActionText { get; set; }
    public string ImpactLevel { get; set; } = "Medium"; // Low, Medium, High
}

public class AiChatRequest
{
    public string Question { get; set; } = string.Empty;
}

public class AiChatResponse
{
    public string Answer { get; set; } = string.Empty;
    public List<string> SuggestedQuestions { get; set; } = new();
    public DateTime AnsweredAt { get; set; } = DateTime.UtcNow;
}
