using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class KomentarObavijestController : BaseCRUDController<Model.KomentarObavijest, KomentarObavijestSearchObject, KomentarObavijestInsertRequest, KomentarObavijestUpdateRequest>
    {
        public KomentarObavijestController(IKomentarObavijestService service)
           : base(service) { }
    }
}
