using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.ViewModels
{
    public class KomentarOdgovorDTO
    {
        public int Id { get; set; }
        public int? KomentariObavijestiId { get; set; }
        public int? KorisnikId { get; set; }
        public string TextOdgovora { get; set; } = null!;
        public DateTime? Datum { get; set; }
        public string ImeKorisnika { get; set; } = null!;
        public string PrezimeKorisnika { get; set; } = null!;

    }
}
