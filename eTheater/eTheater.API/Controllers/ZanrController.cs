using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ZanrController : BaseCRUDController<Model.Zanr, ZanrSearchObject, ZanrInsertRequest, ZanrUpdateRequest>
    {
        public ZanrController(IZanrService service)
           : base(service) { }
    }
}
