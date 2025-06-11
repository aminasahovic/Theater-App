using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.ViewModels
{
    public class PredstavaView
    {
        public int ID { get; set; }

        public string? NazivPredstave { get; set; }

        public String? Zanr { get; set; }

        public string? Opis { get; set; }

        public int? Trajanje { get; set; }

        public int? GodinaIzdanja { get; set; }

        public String Reziser { get; set; }

        public String Plakat { get; set; }

        public bool? Aktivan { get; set; }
    }
}
