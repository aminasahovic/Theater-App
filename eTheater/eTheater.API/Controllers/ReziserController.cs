using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class ReziserController : BaseCRUDController<Model.Reziser, ReziserSearchObject, ReziserInsertRequest, ReziserUpdateRequest>
    {
        public ReziserController(IReziserService service)
           : base(service) { }
    }
}
