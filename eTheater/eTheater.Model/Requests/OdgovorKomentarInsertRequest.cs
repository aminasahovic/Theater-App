using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.Requests
{
    public class OdgovorKomentarInsertRequest
    {
        public int? KomentariObavijestiId { get; set; }
        public int? KorisnikId { get; set; }
        public string TextOdgovora { get; set; } = null!;
        public DateTime? Datum { get; set; }
    }
}
