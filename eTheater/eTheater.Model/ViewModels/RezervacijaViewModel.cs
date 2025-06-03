using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.ViewModels
{
    public class RezervacijaViewModel
    {
        public int Id { get; set; }
        public int PredstavaId { get; set; }
        public string Naziv { get; set; }
        public DateTime DatumVrijemeIzvedbe { get; set; }
        public string NazivSale { get; set; }
        public string PlakatUrl { get; set; }
        public int? KorisnikId { get; set; }
        public int? IzvedbaId { get; set; }
        public int BrojKarata { get; set; }
        public bool? IsKupljeno { get; set; }
        public string? PaymentId { get; set; }
        public bool? IsUsedTicket { get; set; }

    }
}
