using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.Requests
{
    public class ObavijestInsertRequest
    {
        public int? KorisnikId { get; set; }
        public string Naslov { get; set; } = null!;
        public string Sadrzaj { get; set; } = null!;
        public DateTime? DatumObjave { get; set; }
        public string? Slika { get; set; }
    }
}
