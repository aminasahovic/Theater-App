using Microsoft.ML.Data;
using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model
{
    public class PredstavaPreporuka
    {
        [KeyType(count: 100)]
        public uint PredstavaID { get; set; }
        [KeyType(count: 100)]
        public uint KorisnikID { get; set; }
        public float Ocjena { get; set; }
    }
}
