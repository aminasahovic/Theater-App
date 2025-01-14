using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class RepertoarIzvedbaController : BaseCRUDController<Model.RepertoarIzvedba, RepertoarIzvedbaSearchObject, RepertoarIzvedbaInsertRequest, RepertoarIzvedbaUpdateRequest>
    {
        public RepertoarIzvedbaController(IRepertoarIzvedbaService service)
           : base(service) { }
    }
}
