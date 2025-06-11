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
        private readonly IMapper _mapper;
        public PredstavaService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
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
                query = query.Where(x => x.ReziserId.Equals(searchObject.ReziserId));
            }

            if (searchObject.Godina.HasValue)
            {
                query = query.Where(x => x.Godina == searchObject.Godina);
            }

            if (searchObject.IsActive != null)
            {
                query = query.Where(x => x.IsActive == searchObject.IsActive);

            }
            query = query.OrderByDescending(x => x.Id);

            return query;
        }
        public async Task<List<Model.Predstava>> GetPreprukuByKorisnikID(int korisnikId)
        {
            var preporuka = await _context.Recommenders.Where(x => x.KorisnikId == korisnikId).ToListAsync();
            var listaId = new List<int>();
            foreach (var p in preporuka)
            {
                listaId.Add((int)p.CoPredstavaId1);
                listaId.Add((int)p.CoPredstavaId2);
                listaId.Add((int)p.CoPredstavaId3);

            }
            var preporuceniFilmoviDetalji = await _context.Predstavas
                .Where(x => listaId.Contains(x.Id))
                .Include(z => z.Zanr)
                .Include(r => r.Reziser)
                .ToListAsync();

            var preporuceniFilmoviView = _mapper.Map<List<Model.Predstava>>(preporuceniFilmoviDetalji);

            return preporuceniFilmoviView;
        }

    }
}
