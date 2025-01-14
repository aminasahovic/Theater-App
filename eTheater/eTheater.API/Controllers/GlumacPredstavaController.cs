using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class GlumacPredstavaController : BaseCRUDController<Model.GlumacPredstava, GlumacPredstavaSearchObject, GlumacPredstavaInsertRequest, GlumacPredstavaUpdateRequest>
    {
        public GlumacPredstavaController(IGlumacPredstavaService service)
           : base(service) { }
    }
}
