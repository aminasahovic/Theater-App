using System;
using System.Collections.Generic;
using System.Text;

namespace eTheater.Model.SearchObjects
{
    public class KorisnikRezervacijaSearchObject:BaseSearchObject
    {
        public int? KorisnikId { get; set; }          
        public string? NazivPredstave { get; set; }    
        public bool? Aktivne { get; set; }             
        public bool? IsUsedTicket { get; set; }   
    }
}
