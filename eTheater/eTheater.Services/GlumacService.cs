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
    public class GlumacService : BaseCRUDService<Model.Glumac, GlumacSearchObject, Database.Glumac, GlumacInsertRequest, GlumacUpdateRequest>, IGlumacService
    {
        public GlumacService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
