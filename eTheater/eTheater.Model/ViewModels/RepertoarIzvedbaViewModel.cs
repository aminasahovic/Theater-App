using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.ViewModels
{
    public class RepertoarIzvedbaDTO
    {
        public int RepertoarIzvedbaId { get; set; }
        public int RepertoarId { get; set; }
        public int PredstavaId { get; set; }
        public int IzvedbaId { get; set; }
        public string NazivPredstave { get; set; }
        public DateTime DatumVrijemeIzvedbe { get; set; }
    }

}
