using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class KomentarPredstavaController : BaseCRUDController<Model.KomentarPrestava, KomentarPrestavaSearchObject, KomentarPrestavaInsertRequest, KomentarPrestavaUpdateRequest>
    {
        private readonly IKomentarPrestavaService _service;

        public KomentarPredstavaController(IKomentarPrestavaService service)
           : base(service) {
            _service = service;
        }
        [HttpGet("ByPredstava")]
        public async Task<IActionResult> GetByPredstavaId([FromQuery] KomentarPrestavaSearchObject searchObject)
        {
            var result = await _service.GetByPredstavaIdAsync(searchObject);
            return Ok(result);
        }
    }
}
