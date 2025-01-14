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
    public class RepertoarIzvedbaService : BaseCRUDService<Model.RepertoarIzvedba, RepertoarIzvedbaSearchObject, Database.RepertoarIzvedba, RepertoarIzvedbaInsertRequest, RepertoarIzvedbaUpdateRequest>, IRepertoarIzvedbaService
    {
        public RepertoarIzvedbaService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
