using MoneyFlow.Domain.Common;

namespace MoneyFlow.Domain.Entities;

public class AuditLog : BaseEntity
{
    public Guid UserId { get; set; }
    public string Action { get; set; } = string.Empty;
    public string EntityName { get; set; } = string.Empty;
    public Guid? EntityId { get; set; }
    public string? Details { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    // Navigation property
    public User? User { get; set; }
}
