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
    public class IzvedbaService : BaseCRUDService<Model.Izvedba, IzvedbaSearchObject, Database.Izvedba, IzvedbaInsertRequest, IzvedbaUpdateRequest>, IIzvedbaService
    {
        private readonly ETheaterContext _context;
        private readonly IMapper _mapper;
        private readonly ISjedisteService _sjedista;

        public IzvedbaService(ETheaterContext context, IMapper mapper,ISjedisteService sjedisteService) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
            _sjedista = sjedisteService;

        }

        public async Task<Model.Izvedba> AddIzvedbaAsync(IzvedbaInsertRequest izvedbaInsert)
        {
            var existingIzvedbe = await _context.Izvedbas
                     .Where(p => p.SalaId == izvedbaInsert.SalaId &&
                                 p.DatumVrijeme.Date == izvedbaInsert.DatumVrijeme.Date)
                     .ToListAsync();

            foreach (var existingIzvedba in existingIzvedbe)
            {
                var krajPostojeceProjekcije = existingIzvedba.DatumVrijeme.AddMinutes(180);

                if (izvedbaInsert.DatumVrijeme >= existingIzvedba.DatumVrijeme &&
                    izvedbaInsert.DatumVrijeme <= krajPostojeceProjekcije)
                {
                    throw new Exception("Sala je već zauzeta za odabrani datum i vrijeme.");
                }
            }
            var newIzvedba = new Database.Izvedba();
            _mapper.Map(izvedbaInsert, newIzvedba);
            _context.Add(newIzvedba);
            await _context.SaveChangesAsync();

            var sjedista = await _sjedista.GetAllBySalaAsync((int)izvedbaInsert.SalaId);
            foreach (var sjediste in sjedista)
            {
                var izvedbasjediste = new Database.IzvedbaSjediste
                {
                    SjedisteId = sjediste.Id,
                    IzvedbaId = newIzvedba.Id,
                    IsSlobodno = true,
                    IsDeleted=false
                };
                _context.Add(izvedbasjediste);
            }
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Izvedba>(newIzvedba);
        }
        public override IQueryable<Database.Izvedba> AddFilter(IzvedbaSearchObject search, IQueryable<Database.Izvedba> query)
        {
            if (search.SalaId.HasValue)
            {
                query = query.Where(x => x.SalaId == search.SalaId);
            }
            if (!string.IsNullOrWhiteSpace(search.NazivPredstave))
            {
                query = query.Where(x => x.Predstava.Naziv.Contains(search.NazivPredstave));
            }

            if (search.DatumIzvodjenja.HasValue)
            {
                query = query.Where(x => x.DatumVrijeme.Date == search.DatumIzvodjenja.Value.Date);
            }
            query = query.OrderByDescending(x => x.Id);
            return query;
        }
        public async Task<PagedResult<IzvedbaViewModel>> GetAllAsync(IzvedbaSearchObject searchObject)
        {
            var query = Context.Set<Database.Izvedba>()
                .Include(x => x.Sala)
                .Include(x => x.Predstava)
                .Where(x => !x.IsDeleted)
                .AsQueryable();

            query = AddFilter(searchObject, query);

            var totalCount = await query.CountAsync();

            if (searchObject?.Page.HasValue == true && searchObject?.PageSize.HasValue == true)
            {
                query = query
                    .Skip((searchObject.Page.Value - 1) * searchObject.PageSize.Value)
                    .Take(searchObject.PageSize.Value);
            }

            query = query.OrderByDescending(x => x.Id);
            var list = await query.ToListAsync();

            var resultList = list.Select(item => new IzvedbaViewModel
            {
                Id = item.Id,
                SalaNaziv = item.Sala?.Naziv,
                NazivPredstave = item.Predstava?.Naziv,
                PredstavaSlika = item.Predstava?.Plakat,
                CijenaKarte = item.CijenaKarte,
                DatumVrijeme = item.DatumVrijeme,
                PredstavaId=item.Predstava.Id,
                SalaId=item.Sala.Id
            }).ToList();

            return new PagedResult<IzvedbaViewModel>
            {
                Count = totalCount,
                ResultList = resultList
            };
        }
        public async Task<List<IzvedbaDTO>> GetIzvedbeByPeriodAsync(IzvedbaDateRangeSearch search)
        {
            var query = _context.Izvedbas
                .Include(x => x.Predstava)
                .AsQueryable();

            if (search.DatumOd.HasValue)
                query = query.Where(x => x.DatumVrijeme >= search.DatumOd && x.IsDeleted==false);

            if (search.DatumDo.HasValue)
                query = query.Where(x => x.DatumVrijeme <= search.DatumDo && x.IsDeleted == false);

            return await query.Select(x => new IzvedbaDTO
            {
                IzvedbaId = x.Id,
                NazivPredstave = x.Predstava.Naziv,
                DatumVrijemeIzvodjenja = x.DatumVrijeme
            }).ToListAsync();
        }



    }
}
