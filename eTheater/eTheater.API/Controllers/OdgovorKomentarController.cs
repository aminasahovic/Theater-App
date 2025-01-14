using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class OdgovorKomentarController : BaseCRUDController<Model.OdgovorKomentar, OdgovorKomentarSearchObject, OdgovorKomentarInsertRequest, OdgovorKomentarUpdateRequest>
    {
        public OdgovorKomentarController(IOdgovorKomentarService service)
           : base(service) { }
    }
}
