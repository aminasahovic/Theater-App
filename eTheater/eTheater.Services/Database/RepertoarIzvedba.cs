using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class RepertoarIzvedba
{
    public int Id { get; set; }

    public int? RepertoarId { get; set; }

    public int? IzvedbaId { get; set; }

    public virtual Izvedba? Izvedba { get; set; }

    public virtual Repertoar? Repertoar { get; set; }
}
