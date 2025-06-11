using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.Requests
{
    public class RecommenderInsert
    {
        public int? KorisnikId { get; set; }

        public int? CoPredstavaId1 { get; set; }

        public int? CoPredstavaId2 { get; set; }

        public int? CoPredstavaId3 { get; set; }
    }
}
