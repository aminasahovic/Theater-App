using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class IzvedbaSjedisteController : BaseCRUDController<Model.IzvedbaSjediste, IzvedbaSjedisteSearchObject, IzvedbaSjedisteInsertRequest, IzvedbaSjedisteUpdateRequest>
    {
        public IzvedbaSjedisteController(IIzvedbaSjedisteService service)
           : base(service) { }
    }
}
