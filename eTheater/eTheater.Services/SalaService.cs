using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eTheater.Services
{
    public class SalaService : BaseCRUDService<Model.Sala, SalaSearchObject, Database.Sala, SalaInsertRequest, SalaUpdateRequest>, ISalaService
    {
        public SalaService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
