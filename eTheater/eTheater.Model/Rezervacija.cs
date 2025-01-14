using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model
{
    public class Rezervacija
    {
        public int Id { get; set; }
        public int? KorisnikId { get; set; }
        public int? IzvedbaId { get; set; }
        public int BrojKarata { get; set; }
        public bool? IsKupljeno { get; set; }
        public string? PaymentId { get; set; }
        public bool? IsUsedTicket { get; set; }
    }
}
