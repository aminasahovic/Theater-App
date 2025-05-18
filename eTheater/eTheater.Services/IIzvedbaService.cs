using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Model.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eTheater.Services
{
    public interface IIzvedbaService:ICRUDService<Model.Izvedba, IzvedbaSearchObject, IzvedbaInsertRequest, IzvedbaUpdateRequest>
    {
        Task<Izvedba> AddIzvedbaAsync(IzvedbaInsertRequest izvedbaInsert);

        Task<PagedResult<IzvedbaViewModel>> GetAllAsync(IzvedbaSearchObject searchObject);
        Task<List<IzvedbaDTO>> GetIzvedbeByPeriodAsync(IzvedbaDateRangeSearch search);

    }
}
