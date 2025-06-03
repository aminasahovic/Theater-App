using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class IzvedbaSjedisteController : BaseCRUDController<Model.IzvedbaSjediste, IzvedbaSjedisteSearchObject, IzvedbaSjedisteInsertRequest, IzvedbaSjedisteUpdateRequest>
    {
        private readonly IIzvedbaSjedisteService _service;

        public IzvedbaSjedisteController(IIzvedbaSjedisteService service)
            : base(service)
        {
            _service = service;
        }

        [HttpGet("ByIzvedba/{izvedbaId}")]
        public async Task<ActionResult<List<Model.IzvedbaSjediste>>> GetByIzvedbaId(int izvedbaId)
        {
            var result = await _service.GetByIzvedbaIdAsync(izvedbaId);
            return Ok(result);
        }
    }
}
