using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class KomentarPredstavaController : BaseCRUDController<Model.KomentarPrestava, KomentarPrestavaSearchObject, KomentarPrestavaInsertRequest, KomentarPrestavaUpdateRequest>
    {
        public KomentarPredstavaController(IKomentarPrestavaService service)
           : base(service) { }
    }
}
