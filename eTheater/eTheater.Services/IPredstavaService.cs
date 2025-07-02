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
    public interface IPredstavaService:ICRUDService<Model.Predstava, PredstavaSearchObject, PredstavaInsertRequest, PredstavaUpdateRequest>
    {
        Task<PagedResult<PredstavaIdNazivDto>> GetAllPredstaveIdNazivAsync(PredstavaLovSearchObject predstavaLovSearchObject);
        Task<List<PredstavaPreporukaDTO>> GetPreprukuByKorisnikID(int korisnikId);
    }
}
