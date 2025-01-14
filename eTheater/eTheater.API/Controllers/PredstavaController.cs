using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class PredstavaController : BaseCRUDController<Model.Predstava, PredstavaSearchObject, PredstavaInsertRequest, PredstavaUpdateRequest>
    {
        public PredstavaController(IPredstavaService service)
           : base(service) { }
    }
}
