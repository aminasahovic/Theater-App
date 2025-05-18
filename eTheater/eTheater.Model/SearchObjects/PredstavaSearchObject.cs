using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.SearchObjects
{
    public class PredstavaSearchObject:BaseSearchObject
    {
        public string? Naziv { get; set; } = null!;

        public int? ZanrId { get; set; }
        public int? ReziserId { get; set; }
        public int? Godina { get; set; }

    }
}
