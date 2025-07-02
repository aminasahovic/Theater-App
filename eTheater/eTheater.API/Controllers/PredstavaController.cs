using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Model.ViewModels;
using eTheater.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class PredstavaController : BaseCRUDController<Model.Predstava, PredstavaSearchObject, PredstavaInsertRequest, PredstavaUpdateRequest>
    {
        private readonly IPredstavaService _service;
        public PredstavaController(IPredstavaService service)
           : base(service) {
            _service = service;
        }

        [Authorize(Roles = "Administrativno osoblje")]
        public override Predstava Insert(PredstavaInsertRequest request)
        {
            return base.Insert(request);
        }

        [AllowAnonymous]
        public override PagedResult<Predstava> GetList([FromQuery] PredstavaSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [AllowAnonymous]
        [HttpGet("GetAllIdNaziv")]
        public async Task<ActionResult<List<PredstavaIdNazivDto>>> GetAllIdNaziv([FromQuery] PredstavaLovSearchObject predstavaLovSearchObject)
        {
            var predstave = await _service.GetAllPredstaveIdNazivAsync(predstavaLovSearchObject);
            return Ok(predstave);
        }

        [HttpGet("GetPreporukuByKorisnikID/{korisnikId}")]
        public async Task<ActionResult<List<PredstavaPreporukaDTO>>> GetPreporukuByKorisnikID(int korisnikId)
        {
            try
            {
                var result = await _service.GetPreprukuByKorisnikID(korisnikId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Greška prilikom dohvaćanja preporuka: {ex.Message}");
            }
        }
    }
}
