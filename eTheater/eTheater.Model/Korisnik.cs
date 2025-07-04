using System;
using System.Collections.Generic;

namespace eTheater.Model
{
    public class Korisnik
    {
        public int Id { get; set; }

        public string Ime { get; set; } = null!;

        public string Prezime { get; set; } = null!;

        public string Username { get; set; } = null!;
        public int? TipKorisnikaId { get; set; }
        public string? Email { get; set; }

        public string? BrojTelefona { get; set; }
        public bool? IsActive { get; set; }
        public string? SlikaProfila { get; set; }


    }
}
