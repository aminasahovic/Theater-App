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
    public interface IRezervacijaService:ICRUDService<Model.Rezervacija, RezervacijaSearchObject, RezervacijaInsertRequest, RezervacijaUpdateRequest>
    {
      Task<PagedResult<RezervacijaViewModel>> GetRezervacijeByKorisnikAsync(KorisnikRezervacijaSearchObject search);
      Task<Boolean> KreirajRezervaciju(RezervacijaInsertRequest insertRequest);
      Task<bool> ObrisiRezervacijuAsync(int rezervacijaId);
      Task<TicketSalesReportDTO> GetTicketSalesReportAsync(int izvedbaId);
      Task<bool> OznaciKaoIskoristenoAsync(int rezervacijaId);

    }
}
