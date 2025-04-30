using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.ViewModels
{
    public class IzvedbaViewModel
    {
        public int Id { get; set; }
        public string NazivPredstave { get; set; }
        public int PredstavaId { get; set; }
        public string? PredstavaSlika { get; set; }
        public int SalaId { get; set; }
        public string SalaNaziv {  get; set; }
        public decimal CijenaKarte { get; set; }
        public DateTime DatumVrijeme { get; set; }

    }
}
