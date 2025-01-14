using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.Requests
{
    public class GlumacPredstavaInsertRequest
    {
        public int? GlumacId { get; set; }
        public int? PredstavaId { get; set; }
        public string? Uloga { get; set; }

    }
}
