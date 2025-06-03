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
    public class IzvedbaSjedisteService : BaseCRUDService<Model.IzvedbaSjediste, IzvedbaSjedisteSearchObject, Database.IzvedbaSjediste, IzvedbaSjedisteInsertRequest, IzvedbaSjedisteUpdateRequest>, IIzvedbaSjedisteService
    {
        private readonly ETheaterContext _context;
        private readonly IMapper _mapper;

        public IzvedbaSjedisteService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<List<Model.IzvedbaSjediste>> GetByIzvedbaIdAsync(int izvedbaId)
        {
            var query = _context.IzvedbaSjedistes.Where(x => x.IzvedbaId == izvedbaId);

            var entityList = await query.ToListAsync();

            return _mapper.Map<List<Model.IzvedbaSjediste>>(entityList);
        
        }


    }
}
