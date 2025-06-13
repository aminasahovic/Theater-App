using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using eTheater.Services.Database;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{

    [ApiController]
    [Route("[controller]")]
    public class KorisnikController : BaseCRUDController<Model.Korisnik, KorisniciSearchObject, KorisnikInsertRequest, KorisnikUpdateRequest>
    {
        public KorisnikController(IKorisnikService service)
            : base(service) { }


        [HttpPost("login")]
        [AllowAnonymous]
        public Model.Korisnik Login(string username, string password)
        {
            return (_service as IKorisnikService).Login(username, password);
        }
        [HttpPost]
        [AllowAnonymous]
        public override Model.Korisnik Insert([FromBody] KorisnikInsertRequest request)
        {
            return base.Insert(request);
        }
        [HttpPost("posalji-potvrdu")]
        public async Task<IActionResult> PosaljiPotvrdu(int korisnikID,string nazivPredstave,DateTime datumPrikazivanja,string sala,int brojKarata,decimal ukupnaCijena,bool isRezervacija)
        {
            try
            {
                await (_service as IKorisnikService).PosaljiPotvrdniEmailZaKupovinuAsync(korisnikID, nazivPredstave, datumPrikazivanja, sala, brojKarata, ukupnaCijena, isRezervacija);

                return Ok(new { poruka = "Email je uspješno poslan." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { greska = "Greška prilikom slanja emaila.", detalji = ex.Message });
            }
        }
    }
}
