using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyFlow.Application.Common.Models;
using MoneyFlow.Application.DTOs.Categories;
using MoneyFlow.Application.Interfaces;

namespace MoneyFlow.Api.Controllers;

[Authorize]
public class CategoriesController : BaseApiController
{
    private readonly ICategoryService _categoryService;

    public CategoriesController(ICategoryService categoryService)
    {
        _categoryService = categoryService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<CategoryDto>>>> GetCategories()
    {
        var result = await _categoryService.GetCategoriesAsync(CurrentUserId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<CategoryDto>>> CreateCategory([FromBody] CreateCategoryRequest request)
    {
        var result = await _categoryService.CreateCategoryAsync(CurrentUserId, request);
        if (!result.Success)
            return BadRequest(result);

        return Ok(result);
    }
}
