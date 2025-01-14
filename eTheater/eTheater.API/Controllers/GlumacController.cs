using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class GlumacController : BaseCRUDController<Model.Glumac, GlumacSearchObject, GlumacInsertRequest, GlumacUpdateRequest>
    {
        public GlumacController(IGlumacService service)
           : base(service) { }
    }
}
