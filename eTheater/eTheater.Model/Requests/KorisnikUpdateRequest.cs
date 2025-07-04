using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.Requests
{
    public class KorisnikUpdateRequest
    {
        public string? Ime { get; set; }
        public string? Prezime { get; set; }
        public string? BrojTelefona { get; set; }
        public bool? IsActive { get; set; }
        public string? Email { get; set; }
        public string? Password { get; set; }
        public string? PasswordPotvrda { get; set; }
        public int? TipKorisnikaId { get; set; }
        public string? SlikaProfila { get; set; }

    }
}
