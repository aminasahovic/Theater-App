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
    public class RepertoarIzvedbaService : BaseCRUDService<Model.RepertoarIzvedba, RepertoarIzvedbaSearchObject, Database.RepertoarIzvedba, RepertoarIzvedbaInsertRequest, RepertoarIzvedbaUpdateRequest>, IRepertoarIzvedbaService
    {
        ETheaterContext context;
        public RepertoarIzvedbaService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
            this.context = context;
        }

        public async Task<List<RepertoarIzvedbaDTO>> GetRepertoarIzvedbeWithDetails(int repertoarId)
        {
            var query = from ri in context.RepertoarIzvedbas
                        join i in context.Izvedbas on ri.IzvedbaId equals i.Id
                        join p in context.Predstavas on i.Predstava.Id equals p.Id
                        where ri.RepertoarId == repertoarId && ri.IsDeleted == false && i.IsDeleted==false && p.IsDeleted==false
                        orderby ri.Izvedba.DatumVrijeme
                        select new RepertoarIzvedbaDTO
                        {
                            RepertoarIzvedbaId = ri.Id,
                            RepertoarId = ri.Repertoar.Id,
                            NazivPredstave = p.Naziv,
                            DatumVrijemeIzvedbe = ri.Izvedba.DatumVrijeme,
                            PredstavaId=p.Id,
                            IzvedbaId= i.Id,
                            Plakat=p.Plakat
                        };
       

            return await query.ToListAsync();
        }
    }
}
