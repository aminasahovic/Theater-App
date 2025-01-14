using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using eTheater.Services.Database;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{

    [ApiController]
    [Route("[controller]")]
    public class KorisnikController : BaseCRUDController<Model.Korisnik, KorisniciSearchObject, KorisnikInsertRequest, KorisnikUpdateRequest>
    {

        public KorisnikController(IKorisnikService service)
            : base(service) { }
    }
}
