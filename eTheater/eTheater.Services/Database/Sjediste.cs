using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class Sjediste
{
    public int Id { get; set; }

    public int? SalaId { get; set; }

    public int BrojSjedista { get; set; }

    public virtual ICollection<IzvedbaSjediste> IzvedbaSjedistes { get; set; } = new List<IzvedbaSjediste>();

    public virtual Sala? Sala { get; set; }
}
