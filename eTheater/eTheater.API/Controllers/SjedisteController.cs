using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    public class SjedisteController : BaseCRUDController<Model.Sjediste, SjedisteSearchObject, SjedisteInsertRequest, SjedisteUpdateRequest>
    {
        public SjedisteController(ISjedisteService service)
           : base(service) { }
    }
}
