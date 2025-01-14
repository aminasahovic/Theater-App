using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model
{
    public class Predstava
    {
        public int Id { get; set; }
        public string Naziv { get; set; } = null!;
        public int? ZanrId { get; set; }
        public string? Opis { get; set; }
        public int? Trajanje { get; set; }
        public int? Godina { get; set; }
        public string? Plakat { get; set; }
        public bool? IsActive { get; set; }
        public int? ReziserId { get; set; }
    }
}
