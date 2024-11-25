using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class Repertoar
{
    public int Id { get; set; }

    public DateOnly PocetakDatum { get; set; }

    public DateOnly KrajDatum { get; set; }

    public virtual ICollection<RepertoarIzvedba> RepertoarIzvedbas { get; set; } = new List<RepertoarIzvedba>();
}
