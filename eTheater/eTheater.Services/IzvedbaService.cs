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
    public class IzvedbaService : BaseCRUDService<Model.Izvedba, IzvedbaSearchObject, Database.Izvedba, IzvedbaInsertRequest, IzvedbaUpdateRequest>, IIzvedbaService
    {
        public IzvedbaService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
