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
    public class RepertoarIzvedbaService : BaseCRUDService<Model.RepertoarIzvedba, RepertoarIzvedbaSearchObject, Database.RepertoarIzvedba, RepertoarIzvedbaInsertRequest, RepertoarIzvedbaUpdateRequest>, IRepertoarIzvedbaService
    {
        ETheaterContext context;
        public RepertoarIzvedbaService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
            this.context = context;
        }

        public async Task<PagedResult<RepertoarIzvedbaDTO>> GetRepertoarIzvedbeWithDetails(int repertoarId, RepertoarIzvedbaSearchObject search)
        {
            var query = from ri in context.RepertoarIzvedbas
                        join i in context.Izvedbas on ri.IzvedbaId equals i.Id
                        join p in context.Predstavas on i.Predstava.Id equals p.Id
                        where ri.RepertoarId == repertoarId &&
                              !ri.IsDeleted &&
                              !i.IsDeleted &&
                              !p.IsDeleted
                        select new
                        {
                            ri.Id,
                            RepertoarId = ri.Repertoar.Id,
                            p.Naziv,
                            DatumVrijeme = i.DatumVrijeme,
                            PredstavaId = p.Id,
                            IzvedbaId = i.Id,
                            p.Plakat,
                            p.ZanrId
                        };

            if (!string.IsNullOrWhiteSpace(search?.Naziv))
            {
                query = query.Where(x => x.Naziv.Contains(search.Naziv));
            }

            if (search?.ZanrId != null)
            {
                query = query.Where(x => x.ZanrId == search.ZanrId);
            }

            var totalCount = await query.CountAsync();

            query = query.OrderBy(x => x.Id);

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                int skip = (search.Page.Value - 1) * search.PageSize.Value;
                query = query.Skip(skip).Take(search.PageSize.Value);
            }

            var list = await query.Select(x => new RepertoarIzvedbaDTO
            {
                RepertoarIzvedbaId = x.Id,
                RepertoarId = x.RepertoarId,
                NazivPredstave = x.Naziv,
                DatumVrijemeIzvedbe = x.DatumVrijeme,
                PredstavaId = x.PredstavaId,
                IzvedbaId = x.IzvedbaId,
                Plakat = x.Plakat
            }).ToListAsync();

            return new PagedResult<RepertoarIzvedbaDTO>
            {
                Count = totalCount,
                ResultList = list
            };
        }


    }
}
