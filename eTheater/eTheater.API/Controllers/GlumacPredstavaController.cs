using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class GlumacPredstavaController : BaseCRUDController<Model.GlumacPredstava, GlumacPredstavaSearchObject, GlumacPredstavaInsertRequest, GlumacPredstavaUpdateRequest>
    {
        private readonly IGlumacPredstavaService _glumacPredstavaService;

        public GlumacPredstavaController(IGlumacPredstavaService service)
           : base(service) {
            _glumacPredstavaService = service;
        }

        [HttpGet("predstava/{predstavaId}/glumci")]
        public async Task<ActionResult<List<GlumacUlogaDto>>> GetGlumciZaPredstavu(int predstavaId)
        {
            var result = await _glumacPredstavaService.GetGlumciZaPredstavuAsync(predstavaId);
            return Ok(result);
        }

    }
}
