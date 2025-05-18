using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Model.ViewModels;
using eTheater.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eTheater.Services
{
    public class PredstavaService : BaseCRUDService<Model.Predstava, PredstavaSearchObject, Database.Predstava, PredstavaInsertRequest, PredstavaUpdateRequest>, IPredstavaService
    {
        private readonly ETheaterContext _context;
        public PredstavaService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }
        public async Task<List<PredstavaIdNazivDto>> GetAllPredstaveIdNazivAsync()
        {
            return await _context.Predstavas.Where(x=> x.IsActive==true && x.IsDeleted==false)
                .Select(p => new PredstavaIdNazivDto
                {
                    Id = p.Id,
                    Naziv = p.Naziv
                })
                .ToListAsync();
        }
        public override IQueryable<Database.Predstava> AddFilter(PredstavaSearchObject searchObject, IQueryable<Database.Predstava> query)
        {
            query = base.AddFilter(searchObject, query);
            if (!string.IsNullOrWhiteSpace(searchObject?.Naziv))
            {
                query = query.Where(x => x.Naziv.StartsWith(searchObject.Naziv));
            }

            if (searchObject.ZanrId.HasValue)
            {
                query = query.Where(x => x.ZanrId.Equals(searchObject.ZanrId));
            }


            if (searchObject.ReziserId.HasValue)
            {
                query = query.Where(x => x.ZanrId.Equals(searchObject.ReziserId));
            }

            if (searchObject.Godina.HasValue)
            {
                query = query.Where(x => x.Godina == searchObject.Godina);
            }

            return query;
        }
    }
}
