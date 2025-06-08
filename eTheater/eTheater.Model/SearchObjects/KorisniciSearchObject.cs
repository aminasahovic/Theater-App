using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.SearchObjects
{
    public class KorisniciSearchObject:BaseSearchObject
    {
        public string? ImeGTE { get; set; }
        public string? PrezimeGTE { get; set; }

        public string? Email { get; set; }

        public string? KorisnickoIme { get; set; }
        public int? IsTipKorisnika { get; set; }

        public bool? IsActive { get; set; }

    }
}
