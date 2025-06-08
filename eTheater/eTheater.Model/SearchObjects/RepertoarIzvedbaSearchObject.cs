using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.SearchObjects
{
    public class RepertoarIzvedbaSearchObject:BaseSearchObject
    {
        public string? Naziv { get; set; } = null!;
        public int? ZanrId { get; set; }
    }
}
