using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class IzvedbaSjediste
{
    public int Id { get; set; }

    public int? IzvedbaId { get; set; }

    public int? SjedisteId { get; set; }

    public string? Status { get; set; }

    public virtual Izvedba? Izvedba { get; set; }

    public virtual Sjediste? Sjediste { get; set; }
}
