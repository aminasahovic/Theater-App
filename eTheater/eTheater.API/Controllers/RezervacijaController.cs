using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Model.ViewModels;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class RezervacijaController : BaseCRUDController<Model.Rezervacija, RezervacijaSearchObject, RezervacijaInsertRequest, RezervacijaUpdateRequest>
    {
        public RezervacijaController(IRezervacijaService service)
           : base(service) { }

        [HttpGet("korisnik")]
        public async Task<ActionResult<PagedResult<RezervacijaViewModel>>> GetByKorisnikAsync([FromQuery] KorisnikRezervacijaSearchObject search)
        {
            var result = await ((IRezervacijaService)_service).GetRezervacijeByKorisnikAsync(search);
            return Ok(result);
        }

        [HttpPost("novaRezervacija")]
        public async Task<ActionResult<Boolean>> KreirajRezervaciju(RezervacijaInsertRequest insertRequest)
        {
            var result = await ((IRezervacijaService)_service).KreirajRezervaciju(insertRequest);
            return Ok(result);
        }
        [HttpDelete("obrisi/{id}")]
        public async Task<ActionResult<bool>> ObrisiRezervaciju(int id)
        {
            var result = await ((IRezervacijaService)_service).ObrisiRezervacijuAsync(id);
            if (result)
                return Ok(true);
            else
                return NotFound(false);
        }
        [HttpGet("izvjestaj/prodaja/{izvedbaId}")]
        public async Task<IActionResult> GetTicketSalesReport(int izvedbaId)
        {
            var result = await ((IRezervacijaService)_service).GetTicketSalesReportAsync(izvedbaId);
            return Ok(result);
        }

    }
}
