using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model
{
    public class Glumac
    {
        public int Id { get; set; }
        public string Ime { get; set; } = null!;
        public string Prezime { get; set; } = null!;
        public string? Slika { get; set; }
    }
}
