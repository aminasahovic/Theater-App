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
        public async Task<ActionResult<List<PredstavaIdNazivDto>>> GetAllIdNaziv()
        {
            var predstave = await _service.GetAllPredstaveIdNazivAsync();
            return Ok(predstave);
        }
    }
}
