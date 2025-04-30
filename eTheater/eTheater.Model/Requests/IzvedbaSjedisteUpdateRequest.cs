using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.Requests
{
    public class IzvedbaSjedisteUpdateRequest
    {
        public int? IzvedbaId { get; set; }
        public int? SjedisteId { get; set; }
        public bool? IsSlobodno { get; set; }
    }
}
