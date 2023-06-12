using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TodoApi.Data;
using TodoApi.Models;

namespace DotNetCoreSqlDb.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TodosController : ControllerBase
    {
        private readonly MyDatabaseContext _context;

        public TodosController(MyDatabaseContext context)
        {
            _context = context;
        }

        // GET: Todos
        [HttpGet]
        public async Task<IResult> Index()
        {
            var todos = new List<Todo>();

            // This allows the home page to load if migrations have not been run yet.
            try
            {
                todos = await _context.Todo.ToListAsync();
            }
            catch (Exception)
            {
                throw;
            }

            return Results.Ok(todos);
        }

        // GET: Todos/Details/5
        [HttpGet("{id}")]
        public async Task<IResult> Details(int? id)
        {
            if (id == null)
            {
                return Results.NotFound();
            }

            var todo = await _context.Todo
                .FirstOrDefaultAsync(m => m.ID == id);
            if (todo == null)
            {
                return Results.NotFound();
            }

            return Results.Ok(todo);
        }

        [HttpPost]
        public async Task<IResult> CreateMock()
        {
            var date = DateTime.Now;
            var toAdd = new Todo{CreatedDate = date, Description = $"Test {date.ToShortTimeString()}", Details = Guid.NewGuid().ToString() };
            var added = _context.Todo.Add(toAdd);
            await _context.SaveChangesAsync();
            
            return Results.Ok(toAdd);
        }

        // Delete: Todos/Delete/5
        [HttpDelete, ActionName("Delete")]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var todo = await _context.Todo.FindAsync(id);
            _context.Todo.Remove(todo);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool TodoExists(int id)
        {
            return _context.Todo.Any(e => e.ID == id);
        }
    }
}
