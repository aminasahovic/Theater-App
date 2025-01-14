using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class SalaController : BaseCRUDController<Model.Sala, SalaSearchObject, SalaInsertRequest, SalaUpdateRequest>
    {
        public SalaController(ISalaService service)
           : base(service) { }
    }
}
