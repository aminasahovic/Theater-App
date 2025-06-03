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
    }
}
