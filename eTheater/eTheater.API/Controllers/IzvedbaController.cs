using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class IzvedbaController : BaseCRUDController<Model.Izvedba, IzvedbaSearchObject, IzvedbaInsertRequest, IzvedbaUpdateRequest>
    {
        public IzvedbaController(IIzvedbaService service)
           : base(service) { }
    }
}
