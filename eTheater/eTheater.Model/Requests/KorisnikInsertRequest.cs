using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.Requests
{
    public class KorisnikInsertRequest
    {
        public string Ime { get; set; } = null!;
        public string Prezime { get; set; } = null!;
        public string Username { get; set; } = null!;
        public string Password { get; set; } = null!;
        public string PasswordPotvrda { get; set; } = null!;
        public string? Email { get; set; }

        public bool? IsActive { get; set; }
        public string? BrojTelefona { get; set; }
        public int? TipKorisnikaId { get; set; }
    }
}
