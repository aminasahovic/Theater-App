using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Model.ViewModels;
using eTheater.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class IzvedbaController : BaseCRUDController<Model.Izvedba, IzvedbaSearchObject, IzvedbaInsertRequest, IzvedbaUpdateRequest>
    {
        private readonly IIzvedbaService _service;
        public IzvedbaController(IIzvedbaService service)
           : base(service) {
            _service = service;
        }


        [Authorize(Roles = "Administrativno osoblje")]
        [HttpPost]
        [Route("/add")]
        public async Task<IActionResult> AddIzvedbaAsync(IzvedbaInsertRequest obj)
        {
            try
            {
                var projekcija = await _service.AddIzvedbaAsync(obj);
                return Ok(projekcija);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
        [HttpGet()]
        [Route("/getall")]
        public async Task<PagedResult<IzvedbaViewModel>> GetAsync([FromQuery] IzvedbaSearchObject searchObject)
        {
            return await _service.GetAllAsync(searchObject);
        }

        [HttpGet("period")]
        public async Task<IActionResult> GetIzvedbeByPeriod([FromQuery] IzvedbaDateRangeSearch search)
        {
            if (search == null || (!search.DatumOd.HasValue && !search.DatumDo.HasValue))
            {
                return BadRequest("Morate unijeti barem jedan datum za filtriranje (DatumOd ili DatumDo).");
            }

            var izvedbe = await _service.GetIzvedbeByPeriodAsync(search);

            return Ok(izvedbe);
        }

    }
}
