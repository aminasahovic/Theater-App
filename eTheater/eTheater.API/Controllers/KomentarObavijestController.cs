using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Model.ViewModels;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class KomentarObavijestController : BaseCRUDController<Model.KomentarObavijest, KomentarObavijestSearchObject, KomentarObavijestInsertRequest, KomentarObavijestUpdateRequest>
    {
        IKomentarObavijestService service;
        public KomentarObavijestController(IKomentarObavijestService service)
           : base(service) { 
            this.service=service;
        }

        [HttpGet("GetByObavijest")]
        public async Task<ActionResult<PagedResult<KomentarObavijestDto>>> GetKomentariDtoAsync([FromQuery] KomentarObavijestiSearchObjectVM search)
        {
            var komentari = await service.GetKomentariObavijestiAsync(search);
            return Ok(komentari);
        }
    }
}
