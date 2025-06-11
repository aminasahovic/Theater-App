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
        Task<List<PredstavaIdNazivDto>> GetAllPredstaveIdNazivAsync();
        Task<List<Model.Predstava>> GetPreprukuByKorisnikID(int korisnikId);
    }
}
