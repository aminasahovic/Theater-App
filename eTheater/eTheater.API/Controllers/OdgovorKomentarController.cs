using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Model.ViewModels;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class OdgovorKomentarController : BaseCRUDController<Model.OdgovorKomentar, OdgovorKomentarSearchObject, OdgovorKomentarInsertRequest, OdgovorKomentarUpdateRequest>
    {
        IOdgovorKomentarService service;
        public OdgovorKomentarController(IOdgovorKomentarService service)
           : base(service) {
            this.service = service;
        }

        [HttpGet("GetByKomentarId")]
        public async Task<ActionResult<PagedResult<KomentarOdgovorDTO>>> GetByKomentarId([FromQuery] OdgovorKomentarSearchObject search)
        {
            var odgovori = await service.GetOdgovoriKomentaraAsync(search);
            return Ok(odgovori);
        }
    }
}
