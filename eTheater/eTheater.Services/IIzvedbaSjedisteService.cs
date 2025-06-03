using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eTheater.Services
{
    public interface IIzvedbaSjedisteService:ICRUDService<Model.IzvedbaSjediste, IzvedbaSjedisteSearchObject, IzvedbaSjedisteInsertRequest, IzvedbaSjedisteUpdateRequest>
    {
        Task<List<Model.IzvedbaSjediste>> GetByIzvedbaIdAsync(int izvedbaId);

    }
}
