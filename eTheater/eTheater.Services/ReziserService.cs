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
    public class ReziserService : BaseCRUDService<Model.Reziser, ReziserSearchObject, Database.Reziser, ReziserInsertRequest, ReziserUpdateRequest>, IReziserService
    {
        public ReziserService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
        }
        public override IQueryable<Database.Reziser> AddFilter(ReziserSearchObject searchObject, IQueryable<Database.Reziser> query)
        {
            query = base.AddFilter(searchObject, query);
            if (!string.IsNullOrWhiteSpace(searchObject?.ImePrezime))
            {
                query = query.Where(x => x.Ime.StartsWith(searchObject.ImePrezime) || x.Prezime.StartsWith(searchObject.ImePrezime));
            }
            return query;

        }
    }
}
