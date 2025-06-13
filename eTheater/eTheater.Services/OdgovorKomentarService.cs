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
    public class OdgovorKomentarService : BaseCRUDService<Model.OdgovorKomentar, OdgovorKomentarSearchObject, Database.OdgovorKomentar, OdgovorKomentarInsertRequest, OdgovorKomentarUpdateRequest>, IOdgovorKomentarService
    {
        public OdgovorKomentarService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
        }
        public async Task<PagedResult<KomentarOdgovorDTO>> GetOdgovoriKomentaraAsync(OdgovorKomentarSearchObject search)
        {
            var query = _context.OdgovorKomentars
                .Include(o => o.Korisnik)
                .AsQueryable();

            if (search.KomentariObavijestiId.HasValue)
            {
                query = query.Where(x => x.KomentariObavijestiId == search.KomentariObavijestiId.Value && x.IsDeleted==false);
            }
            query = query.OrderByDescending(x => x.Datum);

            var count = await query.CountAsync();

            if (search.Page.HasValue && search.PageSize.HasValue)
            {
                int skip = (search.Page.Value - 1) * search.PageSize.Value;
                query = query.Skip(skip).Take(search.PageSize.Value);
            }

            var resultList = await query.Select(o => new KomentarOdgovorDTO
            {
                Id = o.Id,
                KomentariObavijestiId = o.KomentariObavijestiId,
                KorisnikId = o.KorisnikId,
                TextOdgovora = o.TextOdgovora,
                Datum = o.Datum,
                ImeKorisnika = o.Korisnik != null ? o.Korisnik.Ime : "",
                PrezimeKorisnika = o.Korisnik != null ? o.Korisnik.Prezime : ""
            }).ToListAsync();

            return new PagedResult<KomentarOdgovorDTO>
            {
                Count = count,
                ResultList = resultList
            };
        }

    }
}
