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
    public class RepertoarService : BaseCRUDService<Model.Repertoar, RepertoarSearchObject, Database.Repertoar, RepertoarInsertRequest, RepertoarUpdateRequest>, IRepertoarService
    {
        public RepertoarService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
        }
        public override IQueryable<Database.Repertoar> AddFilter(RepertoarSearchObject searchObject, IQueryable<Database.Repertoar> query)
        {
            query = base.AddFilter(searchObject, query);
            if (!string.IsNullOrWhiteSpace(searchObject?.Naziv))
            {
                query = query.Where(x => x.Naziv.StartsWith(searchObject.Naziv));
            }

            if (searchObject.PocetakDatum.HasValue)
            {
                query = query.Where(x => x.PocetakDatum.Date.Equals(searchObject.PocetakDatum.Value.Date));
            }
            if (searchObject.IsActive == true)
            {
                query = query.Where(x => x.KrajDatum > DateTime.Now).OrderBy(x => x.PocetakDatum);
            }

            return query;
        }
    }
}
