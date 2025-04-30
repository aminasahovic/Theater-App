using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;

namespace eTheater.Model
{
    public class IzvedbaSjediste
    {
        public int Id { get; set; }
        public int? IzvedbaId { get; set; }
        public int? SjedisteId { get; set; }
        public bool? IsSlobodno { get; set; }
    }
}
