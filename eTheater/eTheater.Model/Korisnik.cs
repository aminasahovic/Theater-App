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

        public string? BrojTelefona { get; set; }

    }
}
