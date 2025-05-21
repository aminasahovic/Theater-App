using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.ViewModels
{
    public class KomentarObavijestDto
    {
        public int Id { get; set; }
        public int? ObavijestId { get; set; }
        public int? KorisnikId { get; set; }
        public string Text { get; set; } = null!;
        public DateTime? Datum { get; set; }

        public string ImeKorisnika { get; set; } = string.Empty;
        public string PrezimeKorisnika { get; set; } = string.Empty;
    }

}
