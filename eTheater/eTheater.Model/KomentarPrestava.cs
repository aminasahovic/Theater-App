using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model
{
    public class KomentarPrestava
    {
        public int Id { get; set; }
        public int? KorisnikId { get; set; }
        public int? PredstavaId { get; set; }
        public int Ocjena { get; set; }
        public DateTime? Datum { get; set; }
        public string? Komentar { get; set; }
    }
}
