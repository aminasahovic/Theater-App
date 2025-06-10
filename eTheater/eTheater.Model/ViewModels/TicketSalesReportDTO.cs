using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.ViewModels
{
    public class TicketSalesReportDTO
    {
        public int? IzvedbaId { get; set; }
        public int PredstavaId { get; set; }
        public string NazivPredstave { get; set; }
        public DateTime DatumVrijeme { get; set; }
        public int UkupnoRezervacija { get; set; }
        public decimal UkupniPrihod { get; set; }
        public int UkupnoMjesta { get; set; } 
        public int ZauzetaMjesta { get; set; } 
    }
}
