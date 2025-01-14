using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class RepertoarController : BaseCRUDController<Model.Repertoar, RepertoarSearchObject, RepertoarInsertRequest, RepertoarUpdateRequest>
    {
        public RepertoarController(IRepertoarService service)
           : base(service) { }
    }
}
