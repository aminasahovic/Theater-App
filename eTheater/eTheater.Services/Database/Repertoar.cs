using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class Repertoar
{
    public int Id { get; set; }

    public DateTime PocetakDatum { get; set; }

    public DateTime KrajDatum { get; set; }

    public bool IsDeleted { get; set; }

    public string? Naziv { get; set; }

    public virtual ICollection<RepertoarIzvedba> RepertoarIzvedbas { get; set; } = new List<RepertoarIzvedba>();
}
