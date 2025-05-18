using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.SearchObjects
{
    public class ObavijestSearchObject:BaseSearchObject
    {
        public string? Naslov { get; set; } = null!;
        public DateTime? DatumObjave { get; set; }


    }
}
