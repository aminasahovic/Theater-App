using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.Requests
{
    public class IzvedbaSjedisteInsertRequest
    {
        public int? IzvedbaId { get; set; }
        public int? SjedisteId { get; set; }
        public string? Status { get; set; }
    }
}
