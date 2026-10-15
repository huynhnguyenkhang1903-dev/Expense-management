using MoneyFlow.Domain.Enums;

namespace MoneyFlow.Application.DTOs.Categories;

public class CategoryDto
{
    public Guid Id { get; set; }
    public Guid? UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public TransactionType Type { get; set; }
    public string Icon { get; set; } = "category";
    public string Color { get; set; } = "#6B7280";
    public Guid? ParentId { get; set; }
    public bool IsSystemDefault { get; set; }
    public List<CategoryDto> SubCategories { get; set; } = new();
}

public class CreateCategoryRequest
{
    public string Name { get; set; } = string.Empty;
    public TransactionType Type { get; set; } = TransactionType.Expense;
    public string Icon { get; set; } = "category";
    public string Color { get; set; } = "#6B7280";
    public Guid? ParentId { get; set; }
}
