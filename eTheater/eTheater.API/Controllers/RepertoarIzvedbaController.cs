using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class RepertoarIzvedbaController : BaseCRUDController<Model.RepertoarIzvedba, RepertoarIzvedbaSearchObject, RepertoarIzvedbaInsertRequest, RepertoarIzvedbaUpdateRequest>
    {
        IRepertoarIzvedbaService service;
        public RepertoarIzvedbaController(IRepertoarIzvedbaService service)
           : base(service) {
            this.service = service;
        }

        [HttpGet("Izvedbe/{repertoarId}")]
        public async Task<IActionResult> GetRepertoarIzvedbeWithDetails(int repertoarId)
        {
            var result = await service.GetRepertoarIzvedbeWithDetails(repertoarId);
            if (result == null)
            {
                return NotFound("No data found for the provided Repertoar ID.");
            }
            return Ok(result);
        }

    }
}
