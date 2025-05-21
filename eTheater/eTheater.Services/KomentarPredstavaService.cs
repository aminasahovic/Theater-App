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
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace eTheater.Services
{
    public class KomentarPrestavaService : BaseCRUDService<Model.KomentarPrestava, KomentarPrestavaSearchObject, Database.KomentarPrestava, KomentarPrestavaInsertRequest, KomentarPrestavaUpdateRequest>, IKomentarPrestavaService
    {
        private readonly ETheaterContext _context;
        private readonly IMapper _mapper;
        public KomentarPrestavaService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
        }
        public async Task<PagedResult<KomentarPrestavaDTO>> GetByPredstavaIdAsync(KomentarPrestavaSearchObject searchObject)
        {
            var page = searchObject.Page ?? 1;
            var pageSize = searchObject.PageSize ?? 10;

            if (page <= 0) page = 1;
            if (pageSize <= 0) pageSize = 10;

            var query = _context.KomentarPrestavas
                .Include(x => x.Korisnik)
                .Where(x => x.PredstavaId == searchObject.PredstavaId && x.IsDeleted == false) 
                .OrderByDescending(x => x.Datum);

            var totalCount = await query.CountAsync();

            var entityList = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var dtoList = entityList.Select(x => new KomentarPrestavaDTO
            {
                Id = x.Id,
                KorisnikId = x.KorisnikId,
                PredstavaId = x.PredstavaId,
                Ocjena = x.Ocjena,
                Datum = x.Datum,
                Komentar = x.Komentar,
                ImeKorisnika = x.Korisnik?.Ime,
                PrezimeKorisnika = x.Korisnik?.Prezime
            }).ToList();

            return new PagedResult<KomentarPrestavaDTO>
            {
                Count = totalCount,
                ResultList = dtoList
            };
        }


    }
}
