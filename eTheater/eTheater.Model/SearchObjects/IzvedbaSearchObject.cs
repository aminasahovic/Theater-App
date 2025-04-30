using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.SearchObjects
{
    public class IzvedbaSearchObject : BaseSearchObject
    {
        public int? SalaId { get; set; }
        public String? NazivPredstave { get; set; }
        public DateTime? DatumIzvodjenja { get; set; }
    }
}
