using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eTheater.Services
{
    public interface IKorisnikService : ICRUDService<Model.Korisnik, KorisniciSearchObject, KorisnikInsertRequest, KorisnikUpdateRequest>
    {
        Model.Korisnik Login(string username, string password);
        Task PosaljiPotvrdniEmailZaKupovinuAsync(
        int korisnikID,
        string nazivPredstave,
        DateTime datumPrikazivanja,
        string sala,
        int brojKarata,
        decimal ukupnaCijena,
        bool isRezervacija);
    }
}
