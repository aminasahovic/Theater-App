using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model
{
    public class Izvedba
    {
        public int Id { get; set; }
        public int? PredstavaId { get; set; }
        public int? SalaId { get; set; }
        public DateTime DatumVrijeme { get; set; }
        public decimal CijenaKarte { get; set; }
    }
}
