using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.Requests
{
    public class RepertoarUpdateRequest
    {
        public DateTime PocetakDatum { get; set; }
        public DateTime KrajDatum { get; set; }
        public string? Naziv { get; set; }

    }
}
