using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class GlumacPredstava
{
    public int Id { get; set; }

    public int? GlumacId { get; set; }

    public int? PredstavaId { get; set; }

    public string? Uloga { get; set; }

    public virtual Glumac? Glumac { get; set; }

    public virtual Predstava? Predstava { get; set; }
}
