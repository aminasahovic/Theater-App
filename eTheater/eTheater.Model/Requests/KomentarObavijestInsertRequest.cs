using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.Requests
{
    public class KomentarObavijestInsertRequest
    {
        public int? ObavijestId { get; set; }
        public int? KorisnikId { get; set; }
        public string Text { get; set; } = null!;
        public DateTime? Datum { get; set; }
    }
}
