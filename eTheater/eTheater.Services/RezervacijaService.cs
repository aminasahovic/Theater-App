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
    public class RezervacijaService : BaseCRUDService<Model.Rezervacija, RezervacijaSearchObject, Database.Rezervacija, RezervacijaInsertRequest, RezervacijaUpdateRequest>, IRezervacijaService
    {
        readonly IMapper mapper;
        public RezervacijaService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
            this.mapper = mapper;
        }
        public async Task<PagedResult<RezervacijaViewModel>> GetRezervacijeByKorisnikAsync(KorisnikRezervacijaSearchObject search)
        {
            var query = _context.Rezervacijas
                .Include(r => r.Izvedba)
                .ThenInclude(i => i.Predstava)
                .Include(r => r.Izvedba)
                    .ThenInclude(i => i.Sala)
                .AsQueryable();

            if (search.KorisnikId.HasValue)
                query = query.Where(r => r.KorisnikId == search.KorisnikId);

            if (!string.IsNullOrEmpty(search.NazivPredstave))
                query = query.Where(r => r.Izvedba.Predstava.Naziv.Contains(search.NazivPredstave));

            if (search.Aktivne.HasValue)
            {
                if (search.Aktivne.Value)
                    query = query.Where(r => r.Izvedba.DatumVrijeme >= DateTime.Now);
                else
                    query = query.Where(r => r.Izvedba.DatumVrijeme < DateTime.Now);
            }

            if (search.IsUsedTicket.HasValue)
            {
                query = query.Where(r => r.IsUsedTicket == search.IsUsedTicket.Value);
            }

            var totalCount = await query.CountAsync();
            var page = search.Page ?? 1;
            var pageSize = search.PageSize ?? 10;
            var skip = (page - 1) * pageSize;

            var entities = await query
                .OrderBy(r => r.Izvedba.DatumVrijeme)
                .Skip((int)skip)
                .Take((int)search.PageSize)
                .ToListAsync();

            var resultItems = entities.Select(r => new RezervacijaViewModel
            {
                Id = r.Id,
                PredstavaId = r.Izvedba.Predstava.Id,
                Naziv = r.Izvedba.Predstava.Naziv,
                DatumVrijemeIzvedbe = r.Izvedba.DatumVrijeme,
                NazivSale = r.Izvedba.Sala.Naziv,
                PlakatUrl = r.Izvedba.Predstava.Plakat,
                KorisnikId = r.KorisnikId,
                IzvedbaId = r.IzvedbaId,
                BrojKarata = r.BrojKarata,
                IsKupljeno = r.IsKupljeno,
                PaymentId = r.PaymentId,
                IsUsedTicket = r.IsUsedTicket,
            }).ToList();

            return new PagedResult<RezervacijaViewModel>
            {
                Count = totalCount,
                ResultList = resultItems
            };
        }

        public async Task<Boolean> KreirajRezervaciju(RezervacijaInsertRequest insertRequest)
        {
            Database.Rezervacija rezervacija = new Database.Rezervacija
            {
                BrojKarata = insertRequest.BrojKarata,
                KorisnikId= insertRequest.KorisnikId,
                DatumVrijemeKupovine=DateTime.Now,
                IzvedbaId= insertRequest.IzvedbaId,
                PaymentId= insertRequest.PaymentId,
                IsKupljeno=insertRequest.PaymentId!=null,
                IsUsedTicket=insertRequest.IsUsedTicket,
            };
            try
            {
                _context.Rezervacijas.Add(rezervacija);
                await _context.SaveChangesAsync();
                var zadnjaRezervacija = await _context.Rezervacijas
                    .OrderByDescending(r => r.Id)
                    .FirstOrDefaultAsync();

                int rezervacijaId = zadnjaRezervacija?.Id ?? 0;

                var sjedistaids = insertRequest.odabranaSjedista?.Select(s => s.SjedisteId).ToList();
                var projekcijeSjedista = await _context.IzvedbaSjedistes.Where(r => r.IzvedbaId == insertRequest.IzvedbaId)
                .Where(s => sjedistaids.Contains((int?)s.SjedisteId))
                .ToListAsync();
                foreach (var projekcijaSjediste in projekcijeSjedista)
                {
                    projekcijaSjediste.RezervacijaId = rezervacijaId;
                    projekcijaSjediste.IsSlobodno = false;
                    projekcijaSjediste.Status = "Zauzeto";
                }
                await _context.SaveChangesAsync();
                return true;

            }
            catch (Exception)
            {

                return false;
            }
            
            
            
        }

        public async Task<bool> ObrisiRezervacijuAsync(int rezervacijaId)
        {
            try
            {
                var rezervacija = await _context.Rezervacijas.FindAsync(rezervacijaId);
                if (rezervacija == null)
                    return false;

                var sjedista = await _context.IzvedbaSjedistes
                    .Where(s => s.RezervacijaId == rezervacijaId)
                    .ToListAsync();

                await _context.SaveChangesAsync();
                _context.Rezervacijas.Remove(rezervacija);

                foreach (var sjediste in sjedista)
                {
                    sjediste.RezervacijaId = null;  
                    sjediste.IsSlobodno = true;    
                    sjediste.Status = "Slobodno";  
                }

                await _context.SaveChangesAsync();

                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }



    }
}
