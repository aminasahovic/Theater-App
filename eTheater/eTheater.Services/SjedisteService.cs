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
    public class SjedisteService : BaseCRUDService<Model.Sjediste, SjedisteSearchObject, Database.Sjediste, SjedisteInsertRequest, SjedisteUpdateRequest>, ISjedisteService
    {
        private readonly ETheaterContext _context;
        private readonly IMapper _mapper;
        public SjedisteService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
        }


        public async Task<List<Model.Sjediste>> GetAllBySalaAsync(int id)
        {
            var entityList = await _context.Sjedistes.Where(x => x.SalaId == id).ToListAsync();
            return _mapper.Map<List<Model.Sjediste>>(entityList);
        }
    }
}
