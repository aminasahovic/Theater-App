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
    public class ObavijestService : BaseCRUDService<Model.Obavijest, ObavijestSearchObject, Database.Obavijest, ObavijestInsertRequest, ObavijestUpdateRequest>, IObavijestService
    {
        public ObavijestService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
        }
        public override IQueryable<Database.Obavijest> AddFilter(ObavijestSearchObject searchObject, IQueryable<Database.Obavijest> query)
        {
            query = base.AddFilter(searchObject, query);
            if (!string.IsNullOrWhiteSpace(searchObject?.Naslov))
            {
                query = query.Where(x => x.Naslov.StartsWith(searchObject.Naslov));
            }

            if (searchObject.DatumObjave.HasValue)
            {
                var datum = searchObject.DatumObjave.Value.Date;
                query = query.Where(x => x.DatumObjave.Value.Date == datum);
            }
            query = query.OrderByDescending(x => x.Id);

            return query;
        }
    }
}
