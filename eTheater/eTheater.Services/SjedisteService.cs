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
    public class SjedisteService : BaseCRUDService<Model.Sjediste, SjedisteSearchObject, Database.Sjediste, SjedisteInsertRequest, SjedisteUpdateRequest>, ISjedisteService
    {
        public SjedisteService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
