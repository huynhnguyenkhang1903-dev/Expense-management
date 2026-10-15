using Microsoft.EntityFrameworkCore;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Categories;
using MoneyFlow.Application.Interfaces;
using MoneyFlow.Domain.Entities;
using MoneyFlow.Infrastructure.Data;

namespace MoneyFlow.Infrastructure.Services;

public class CategoryService : ICategoryService
{
    private readonly AppDbContext _context;

    public CategoryService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<List<CategoryDto>>> GetCategoriesAsync(Guid userId)
    {
        var categories = await _context.Categories
            .Where(c => c.UserId == null || c.UserId == userId)
            .OrderBy(c => c.Type)
            .ThenBy(c => c.Name)
            .Select(c => new CategoryDto
            {
                Id = c.Id,
                UserId = c.UserId,
                Name = c.Name,
                Type = c.Type,
                Icon = c.Icon,
                Color = c.Color,
                ParentId = c.ParentId,
                IsSystemDefault = c.IsSystemDefault
            })
            .ToListAsync();

        return ApiResponse<List<CategoryDto>>.Ok(categories);
    }

    public async Task<ApiResponse<CategoryDto>> CreateCategoryAsync(Guid userId, CreateCategoryRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name))
            return ApiResponse<CategoryDto>.Fail("Tên danh mục không được để trống");

        var category = new Category
        {
            UserId = userId,
            Name = request.Name.Trim(),
            Type = request.Type,
            Icon = string.IsNullOrWhiteSpace(request.Icon) ? "category" : request.Icon,
            Color = string.IsNullOrWhiteSpace(request.Color) ? "#6B7280" : request.Color,
            ParentId = request.ParentId,
            IsSystemDefault = false
        };

        _context.Categories.Add(category);
        await _context.SaveChangesAsync();

        return ApiResponse<CategoryDto>.Ok(new CategoryDto
        {
            Id = category.Id,
            UserId = category.UserId,
            Name = category.Name,
            Type = category.Type,
            Icon = category.Icon,
            Color = category.Color,
            ParentId = category.ParentId,
            IsSystemDefault = category.IsSystemDefault
        }, "Tạo danh mục thành công");
    }
}
