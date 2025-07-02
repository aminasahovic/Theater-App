using eTheater.Model;
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
        public async Task<PagedResult<PredstavaIdNazivDto>> GetAllPredstaveIdNazivAsync(PredstavaLovSearchObject predstavaLovSearchObject)
        {
            var query = _context.Predstavas
                .Where(x => x.IsActive == true && x.IsDeleted == false);

            if (!string.IsNullOrWhiteSpace(predstavaLovSearchObject.Naziv))
            {
                query = query.Where(p => p.Naziv.Contains(predstavaLovSearchObject.Naziv));
            }

            var totalCount = await query.CountAsync();

            List<PredstavaIdNazivDto> items;

            if (predstavaLovSearchObject.Page.HasValue && predstavaLovSearchObject.PageSize.HasValue)
            {
                int page = predstavaLovSearchObject.Page.Value;
                int pageSize = predstavaLovSearchObject.PageSize.Value;

                items = await query
                    .OrderBy(p => p.Naziv)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(p => new PredstavaIdNazivDto
                    {
                        Id = p.Id,
                        Naziv = p.Naziv
                    })
                    .ToListAsync();
            }
            else
            {
                items = await query
                    .OrderBy(p => p.Naziv)
                    .Select(p => new PredstavaIdNazivDto
                    {
                        Id = p.Id,
                        Naziv = p.Naziv
                    })
                    .ToListAsync();
            }

            return new PagedResult<PredstavaIdNazivDto>
            {
                ResultList = items,
                Count = totalCount,
            };
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
        public async Task<List<PredstavaPreporukaDTO>> GetPreprukuByKorisnikID(int korisnikId)
        {
            var preporuka = await _context.Recommenders
                .Where(x => x.KorisnikId == korisnikId)
                .ToListAsync();

            var listaId = new List<int>();

            if (preporuka.Any())
            {
                foreach (var p in preporuka)
                {
                    if (p.CoPredstavaId1.HasValue) listaId.Add(p.CoPredstavaId1.Value);
                    if (p.CoPredstavaId2.HasValue) listaId.Add(p.CoPredstavaId2.Value);
                    if (p.CoPredstavaId3.HasValue) listaId.Add(p.CoPredstavaId3.Value);
                }
            }
            else
            {
                var svePreporuke = await _context.Recommenders
                    .Select(r => new { r.CoPredstavaId1, r.CoPredstavaId2, r.CoPredstavaId3 })
                    .ToListAsync();  

                var sveIds = svePreporuke
                    .SelectMany(r => new int?[] { r.CoPredstavaId1, r.CoPredstavaId2, r.CoPredstavaId3 })
                    .Where(id => id.HasValue)       
                    .GroupBy(id => id.Value)        
                    .OrderByDescending(g => g.Count())  
                    .Take(3)                      
                    .Select(g => g.Key)           
                    .ToList();

                listaId = sveIds;

            }
            var preporuceniFilmoviDetalji = await _context.Predstavas
                .Where(x => listaId.Contains(x.Id))
                .Include(z => z.Zanr)
                .Include(r => r.Reziser)
                .ToListAsync();

            var preporuceniDTO = new List<PredstavaPreporukaDTO>();

            foreach (var predstava in preporuceniFilmoviDetalji)
            {
                var izvedba = await _context.Izvedbas
                    .Where(x => x.PredstavaId == predstava.Id && x.DatumVrijeme > DateTime.Now)
                    .OrderBy(x => x.DatumVrijeme)
                    .FirstOrDefaultAsync();

                var dto = new PredstavaPreporukaDTO
                {
                    Id = predstava.Id,
                    Naziv = predstava.Naziv,
                    ZanrId = predstava.ZanrId,
                    Opis = predstava.Opis,
                    Trajanje = predstava.Trajanje,
                    Godina = predstava.Godina,
                    Plakat = predstava.Plakat,
                    IsActive = predstava.IsActive,
                    ReziserId = predstava.ReziserId,
                    IzvedbaId = izvedba?.Id ?? 0
                };

                preporuceniDTO.Add(dto);
            }

            return preporuceniDTO;
        }


    }
}
