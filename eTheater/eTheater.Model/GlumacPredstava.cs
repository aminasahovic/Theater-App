using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model
{
    public class GlumacPredstava
    {
        public int Id { get; set; }
        public int? GlumacId { get; set; }
        public int? PredstavaId { get; set; }
        public string? Uloga { get; set; }
    }
}
