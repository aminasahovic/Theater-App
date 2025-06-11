using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model
{
    public partial class Recommender
    {
        public int Id { get; set; }
        public int KorisnikId { get; set; }
        public int CoPredstavaId1 { get; set; }
        public int CoPredstavaId2 { get; set; }
        public int CoPredstavaId3 { get; set; }
    }

}
