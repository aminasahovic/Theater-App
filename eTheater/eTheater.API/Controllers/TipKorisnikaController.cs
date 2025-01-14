using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class TipKorisnikaController : BaseCRUDController<Model.TipKorisnika, TipKorisnikSearchObject, TipKorisnikInsertRequest, TipKorisnikUpdateRequest>
    {
        public TipKorisnikaController(ITipKorisnikService service)
           : base(service) { }
    }
}
