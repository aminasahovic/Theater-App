using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.SearchObjects
{
    public class RepertoarSearchObject:BaseSearchObject
    {
        public string? Naziv { get; set; }
        public DateTime? PocetakDatum { get; set; }
        public bool? IsActive { get; set; } 

    }
}
