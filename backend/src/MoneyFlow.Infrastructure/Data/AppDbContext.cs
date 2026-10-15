using Microsoft.EntityFrameworkCore;
using MoneyFlow.Domain.Entities;
using MoneyFlow.Domain.Enums;

namespace MoneyFlow.Infrastructure.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Wallet> Wallets => Set<Wallet>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Transaction> Transactions => Set<Transaction>();
    public DbSet<Transfer> Transfers => Set<Transfer>();
    public DbSet<Budget> Budgets => Set<Budget>();
    public DbSet<SavingsGoal> SavingsGoals => Set<SavingsGoal>();
    public DbSet<GoalEntry> GoalEntries => Set<GoalEntry>();
    public DbSet<Bill> Bills => Set<Bill>();
    public DbSet<Debt> Debts => Set<Debt>();
    public DbSet<DebtPayment> DebtPayments => Set<DebtPayment>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // 1. Cấu hình độ chính xác Decimal(18, 2) cho tất cả các trường tiền tệ
        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            var decimalProps = entityType.ClrType.GetProperties()
                .Where(p => p.PropertyType == typeof(decimal) || p.PropertyType == typeof(decimal?));

            foreach (var prop in decimalProps)
            {
                modelBuilder.Entity(entityType.ClrType)
                    .Property(prop.Name)
                    .HasPrecision(18, 2);
            }
        }

        // 2. User Configuration
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(u => u.Email).IsUnique();
            entity.Property(u => u.Email).HasMaxLength(255).IsRequired();
            entity.Property(u => u.FullName).HasMaxLength(150).IsRequired();
        });

        // 3. Wallet Configuration
        modelBuilder.Entity<Wallet>(entity =>
        {
            entity.Property(w => w.Name).HasMaxLength(100).IsRequired();
            entity.Property(w => w.Currency).HasMaxLength(10).HasDefaultValue("VND");
            entity.HasOne(w => w.User)
                  .WithMany(u => u.Wallets)
                  .HasForeignKey(w => w.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // 4. Transfer Configuration (Source & Destination)
        modelBuilder.Entity<Transfer>(entity =>
        {
            entity.HasOne(t => t.FromWallet)
                  .WithMany(w => w.OutgoingTransfers)
                  .HasForeignKey(t => t.FromWalletId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(t => t.ToWallet)
                  .WithMany(w => w.IncomingTransfers)
                  .HasForeignKey(t => t.ToWalletId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // 5. Transaction Configuration
        modelBuilder.Entity<Transaction>(entity =>
        {
            entity.HasOne(t => t.Wallet)
                  .WithMany(w => w.Transactions)
                  .HasForeignKey(t => t.WalletId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(t => t.Category)
                  .WithMany(c => c.Transactions)
                  .HasForeignKey(t => t.CategoryId)
                  .OnDelete(DeleteBehavior.Restrict);

            // Bỏ query filter trên Wallet và Transaction để việc tính toán và query quan hệ tự do, xử lý IsDeleted trong Service queries
        });

        // 6. Category Configuration
        modelBuilder.Entity<Category>(entity =>
        {
            entity.Property(c => c.Name).HasMaxLength(100).IsRequired();
            entity.HasOne(c => c.ParentCategory)
                  .WithMany(c => c.SubCategories)
                  .HasForeignKey(c => c.ParentId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // 7. Cấu hình tránh multiple cascade paths trên SQL Server
        modelBuilder.Entity<DebtPayment>(entity =>
        {
            entity.HasOne(dp => dp.Wallet)
                  .WithMany()
                  .HasForeignKey(dp => dp.WalletId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<GoalEntry>(entity =>
        {
            entity.HasOne(ge => ge.Wallet)
                  .WithMany()
                  .HasForeignKey(ge => ge.WalletId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Bill>(entity =>
        {
            entity.HasOne(b => b.Category)
                  .WithMany()
                  .HasForeignKey(b => b.CategoryId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(b => b.Wallet)
                  .WithMany()
                  .HasForeignKey(b => b.WalletId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // 8. Seed Default System Categories
        SeedDefaultCategories(modelBuilder);
    }

    private static void SeedDefaultCategories(ModelBuilder modelBuilder)
    {
        var seedTime = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc);
        var defaultCategories = new List<Category>
        {
            // Expense Categories
            new() { Id = Guid.Parse("11111111-1111-1111-1111-111111111001"), Name = "Ăn uống", Type = TransactionType.Expense, Icon = "restaurant", Color = "#F59E0B", IsSystemDefault = true, CreatedAt = seedTime },
            new() { Id = Guid.Parse("11111111-1111-1111-1111-111111111002"), Name = "Mua sắm", Type = TransactionType.Expense, Icon = "shopping_bag", Color = "#EC4899", IsSystemDefault = true, CreatedAt = seedTime },
            new() { Id = Guid.Parse("11111111-1111-1111-1111-111111111003"), Name = "Di chuyển & Xăng xe", Type = TransactionType.Expense, Icon = "directions_car", Color = "#3B82F6", IsSystemDefault = true, CreatedAt = seedTime },
            new() { Id = Guid.Parse("11111111-1111-1111-1111-111111111004"), Name = "Nhà ở & Tiền trọ", Type = TransactionType.Expense, Icon = "home", Color = "#8B5CF6", IsSystemDefault = true, CreatedAt = seedTime },
            new() { Id = Guid.Parse("11111111-1111-1111-1111-111111111005"), Name = "Hóa đơn & Tiện ích", Type = TransactionType.Expense, Icon = "receipt_long", Color = "#EF4444", IsSystemDefault = true, CreatedAt = seedTime },
            new() { Id = Guid.Parse("11111111-1111-1111-1111-111111111006"), Name = "Giải trí & Thể thao", Type = TransactionType.Expense, Icon = "sports_esports", Color = "#10B981", IsSystemDefault = true, CreatedAt = seedTime },
            new() { Id = Guid.Parse("11111111-1111-1111-1111-111111111007"), Name = "Sức khỏe & Y tế", Type = TransactionType.Expense, Icon = "medical_services", Color = "#14B8A6", IsSystemDefault = true, CreatedAt = seedTime },
            new() { Id = Guid.Parse("11111111-1111-1111-1111-111111111008"), Name = "Giáo dục & Học tập", Type = TransactionType.Expense, Icon = "school", Color = "#6366F1", IsSystemDefault = true, CreatedAt = seedTime },
            
            // Income Categories
            new() { Id = Guid.Parse("22222222-2222-2222-2222-222222222001"), Name = "Tiền lương", Type = TransactionType.Income, Icon = "payments", Color = "#10B981", IsSystemDefault = true, CreatedAt = seedTime },
            new() { Id = Guid.Parse("22222222-2222-2222-2222-222222222002"), Name = "Tiền thưởng & Phụ cấp", Type = TransactionType.Income, Icon = "card_giftcard", Color = "#F59E0B", IsSystemDefault = true, CreatedAt = seedTime },
            new() { Id = Guid.Parse("22222222-2222-2222-2222-222222222003"), Name = "Đầu tư & Tiết kiệm", Type = TransactionType.Income, Icon = "trending_up", Color = "#3B82F6", IsSystemDefault = true, CreatedAt = seedTime },
            new() { Id = Guid.Parse("22222222-2222-2222-2222-222222222004"), Name = "Thu nhập khác", Type = TransactionType.Income, Icon = "attach_money", Color = "#8B5CF6", IsSystemDefault = true, CreatedAt = seedTime }
        };

        modelBuilder.Entity<Category>().HasData(defaultCategories);
    }
}
