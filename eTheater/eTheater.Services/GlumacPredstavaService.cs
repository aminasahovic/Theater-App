using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
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
    public class GlumacPredstavaService : BaseCRUDService<Model.GlumacPredstava, GlumacPredstavaSearchObject, Database.GlumacPredstava, GlumacPredstavaInsertRequest, GlumacPredstavaUpdateRequest>, IGlumacPredstavaService
    {
        public GlumacPredstavaService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<List<Model.GlumacUlogaDto>> GetGlumciZaPredstavuAsync(int predstavaId)
        {
            var glumci = await _context.GlumacPredstavas
                .Where(gp => gp.PredstavaId == predstavaId)
                .Include(gp => gp.Glumac) 
                .Select(gp => new Model.GlumacUlogaDto
                {
                    GlumacId = gp.Glumac.Id,
                    Ime = gp.Glumac.Ime,
                    Prezime = gp.Glumac.Prezime,
                    Uloga = gp.Uloga,
                    Slika=gp.Glumac.Slika
                })
                .ToListAsync();

            return glumci;
        }

    }
}
