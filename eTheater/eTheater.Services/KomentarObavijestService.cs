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
    public class KomentarObavijestService : BaseCRUDService<Model.KomentarObavijest, KomentarObavijestSearchObject, Database.KomentarObavijest, KomentarObavijestInsertRequest, KomentarObavijestUpdateRequest>, IKomentarObavijestService
    {
        public KomentarObavijestService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
        }
        public async Task<PagedResult<KomentarObavijestDto>> GetKomentariObavijestiAsync(KomentarObavijestiSearchObjectVM search)
        {
            var query = _context.KomentarObavijests
                .Include(k => k.Korisnik)
                .AsQueryable();

            if (int.TryParse(search.ObavijestiId, out int obavijestId))
            {
                query = query.Where(x => x.ObavijestId == obavijestId && x.IsDeleted==false);
            }

            int totalCount = await query.CountAsync();

            if (search.Page.HasValue && search.PageSize.HasValue)
            {
                int skip = (search.Page.Value - 1) * search.PageSize.Value;
                query = query.Skip(skip).Take(search.PageSize.Value);
            }

            var list = await query
                .Select(k => new KomentarObavijestDto
                {
                    Id = k.Id,
                    ObavijestId = k.ObavijestId,
                    KorisnikId = k.KorisnikId,
                    Text = k.Text,
                    Datum = k.Datum,
                    ImeKorisnika = k.Korisnik != null ? k.Korisnik.Ime : "",
                    PrezimeKorisnika = k.Korisnik != null ? k.Korisnik.Prezime : ""
                })
                .ToListAsync();

            return new PagedResult<KomentarObavijestDto>
            {
                Count = totalCount,
                ResultList = list
            };
        }


    }
}
