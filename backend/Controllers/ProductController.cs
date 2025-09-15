using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Mvc;
using App.Models;

namespace App.Controllers
{
    public class ProductController : Controller
    {
        private readonly DataContext _context;

        public ProductController(DataContext context)
        {
            _context = context;
        }

        [HttpGet("api/products")]
        public async Task<IActionResult> Index()
        {
            var products = await _context.Product.ToListAsync();
            return Ok(products);
        }

        [HttpGet("api/products/{id}")]
        public async Task<IActionResult> Detail(int? id)
        {
            var product = await _context.Product.FirstOrDefaultAsync(e => e.Id == id);
            return Ok(product);
        }

        [HttpPost("api/products")]
        public async Task<IActionResult> Create([FromBody] Product model)
        {
            var product = new Product();
            product.Id = model.Id;
            product.Name = model.Name;
            product.Price = model.Price;
            _context.Add(product);
            await _context.SaveChangesAsync();
            return Ok(product);
        }

        [HttpPut("api/products/{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] Product model)
        {
            var product = await _context.Product.FirstOrDefaultAsync(e => e.Id == id);
            product.Name = model.Name;
            product.Price = model.Price;
            await _context.SaveChangesAsync();
            return Ok(product);
        }

        [HttpDelete("api/products/{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var product = await _context.Product.FindAsync(id);
            _context.Product.Remove(product);
            await _context.SaveChangesAsync();
            return Ok();
        }
    }
}