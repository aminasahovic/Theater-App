using System.Text;
using System.Text.Json;
using eTheater.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace eTheater.Services
{
    public interface IAdminChatRepository
    {
        Task<string> GetResponseAsync(string prompt, string previousResponse);
    }

    public class AdminChatRepository : IAdminChatRepository
    {
        private readonly ETheaterContext _db;
        private readonly HttpClient _httpClient;

        private const string GeminiEndpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

        private readonly string _systemPrompt = @"
Ti si AI asistent za administratora pozorišta eTheater.

=== TVOJE FUNKCIJE ===
1. Analiza podataka iz sistema (prodaja, ocjene, popularnost)
2. Pomoć u planiranju repertoara
3. Davanje preporuka za poboljšanje poslovanja
4. Pomoć administratoru u navigaciji i korištenju web aplikacije

=== PRAVILA PONAŠANJA ===
- Odgovaraj profesionalno, jasno i kratko.
- Zasnivaj analitičke odgovore isključivo na podacima iz baze koji ti se pruže.
- Nemoj izmišljati podatke. Ako nema dovoljno podataka, naglasi: 'Nema dovoljno podataka u sistemu.'
- Ako konverzacija ima prethodnu poruku, nastavi prirodno bez ponovnog pozdravljanja.
- Kada daješ preporuke, potkrijep ih konkretnim brojevima iz konteksta.

=== STRUKTURA ADMINISTRATORSKOG PANELA ===
Administratorski panel eTheater aplikacije sadrži sljedeće sekcije u bočnom meniju:

1. PREDSTAVE
   - Pregled svih predstava u tabeli (naziv, žanr, trajanje, režiser)
   - Dugme 'Dodaj predstavu' otvara formu za unos
   - Klikom na predstavu otvara se detaljan pregled sa glumcima i izvedbama
   - Na detaljnoj stranici moguće je uređivati ili obrisati predstavu

2. GLUMCI
   - Pregled svih glumaca
   - Dugme 'Dodaj glumca' za unos novog glumca (ime, prezime, biografija, slika)
   - Glumce je moguće dodijeliti predstavi iz detalja predstave

3. REŽISERI
   - Pregled svih režisera
   - Dugme 'Dodaj režisera' za unos novog režisera

4. IZVEDBE
   - Pregled svih izvedbi sa datumom, vremenom i cijenom karte
   - Dugme 'Dodaj izvedbu' za kreiranje nove izvedbe
   - Potrebno je izabrati predstavu, salu, postaviti datum/vrijeme i cijenu karte

5. REPERTOAR
   - Pregled repertoara po periodima
   - Moguće je kreirati novi repertoar sa datumom početka i kraja
   - Izvedbe se dodaju u repertoar iz sekcije Repertoar

6. KORISNICI
   - Pregled svih registrovanih korisnika
   - Moguće je dodati novog korisnika ili promijeniti ulogu

7. NOVOSTI (Obavijesti)
   - Pregled svih objavljenih novosti/obavijesti
   - Dugme 'Dodaj novost' za kreiranje nove obavijesti (naslov, tekst, slika)
   - Moguće je uređivati i brisati novosti

8. KOMENTARI
   - Pregled komentara na predstave i novosti
   - Administrator može brisati neprikladan sadržaj

=== PRIMJERI INSTRUKCIJA ZA NAVIGACIJU ===

Kako dodati novu predstavu:
1. U bočnom meniju kliknite na 'Predstave'
2. Kliknite dugme 'Dodaj predstavu'
3. Unesite naziv, izaberite žanr, unesite trajanje i opis
4. Izaberite režisera (mora biti prethodno dodat)
5. Sačuvajte — pa otvorite detalje predstave da dodate glumce

Kako dodati novu izvedbu:
1. U bočnom meniju kliknite na 'Izvedbe'
2. Kliknite dugme 'Dodaj izvedbu'
3. Izaberite predstavu i salu
4. Postavite datum, vrijeme i cijenu karte
5. Kliknite 'Sačuvaj'

Kako urediti repertoar:
1. U bočnom meniju kliknite na 'Repertoar'
2. Kreirajte novi repertoar ili otvorite postojeći
3. Dodajte izvedbe u repertoar

Kako dodati glumca predstavi:
1. Idite na 'Predstave'
2. Kliknite na željenu predstavu da otvorite detalje
3. U sekciji glumaca kliknite 'Dodaj glumca'
4. Izaberite glumca i unesite ulogu
";

        public AdminChatRepository(ETheaterContext db, HttpClient httpClient, IConfiguration configuration)
        {
            _db = db;
            _httpClient = httpClient;
            var apiKey = configuration["Gemini:ApiKey"] ?? "";
            if (!_httpClient.DefaultRequestHeaders.Contains("x-goog-api-key"))
                _httpClient.DefaultRequestHeaders.Add("x-goog-api-key", apiKey);
        }

        public async Task<string> GetResponseAsync(string prompt, string previousResponse = "")
        {
            string contextInfo = await BuildContextAsync();

            var finalPrompt = _systemPrompt + "\n\n" +
                              "Prethodna komunikacija:\n" + previousResponse + "\n\n" +
                              "Podaci iz baze:\n" + contextInfo +
                              "\n\nPitanje administratora: " + prompt;

            var payload = new
            {
                contents = new[]
                {
                    new
                    {
                        parts = new[]
                        {
                            new { text = finalPrompt }
                        }
                    }
                }
            };

            var jsonPayload = JsonSerializer.Serialize(payload);

            var response = await SendWithRetryAsync(jsonPayload);
            var responseContent = await response.Content.ReadAsStringAsync();

            using var jsonDoc = JsonDocument.Parse(responseContent);
            var root = jsonDoc.RootElement;

            if (root.TryGetProperty("candidates", out var candidates) &&
                candidates.ValueKind == JsonValueKind.Array &&
                candidates.GetArrayLength() > 0)
            {
                var first = candidates[0];

                if (first.TryGetProperty("content", out var content) &&
                    content.TryGetProperty("parts", out var parts) &&
                    parts.GetArrayLength() > 0)
                {
                    return parts[0].GetProperty("text").GetString() ?? "";
                }

                if (first.TryGetProperty("finishReason", out var reason))
                    return $"AI nije mogao generisati odgovor. Razlog: {reason.GetString()}";

                return "AI nije mogao generisati odgovor na ovo pitanje.";
            }

            if (root.TryGetProperty("error", out var error))
            {
                var message = error.TryGetProperty("message", out var msg)
                    ? msg.GetString()
                    : "Nepoznata greška";
                return $"Greška komunikacije s AI servisom: {message}";
            }

            return "AI servis nije vratio odgovor. Pokušajte ponovo.";
        }

        private async Task<string> BuildContextAsync()
        {
            var sb = new StringBuilder();
            var today = DateTime.Today;

            var izvedbe = await _db.Izvedbas
                .Include(i => i.Predstava)
                    .ThenInclude(p => p.Zanr)
                .Include(i => i.Predstava)
                    .ThenInclude(p => p.Reziser)
                .Where(i => i.DatumVrijeme >= today && (bool)i.Predstava.IsActive)
                .OrderBy(i => i.DatumVrijeme)
                .ToListAsync();

            sb.AppendLine("=== PREDSTOJEĆE IZVEDBE ===");
            if (izvedbe.Any())
            {
                foreach (var iz in izvedbe)
                {
                    sb.AppendLine($"Naziv: {iz.Predstava.Naziv} | Datum: {iz.DatumVrijeme:dd.MM.yyyy HH:mm} | Cijena karte: {iz.CijenaKarte} KM | Žanr: {iz.Predstava.Zanr?.Naziv}");
                }
            }
            else
            {
                sb.AppendLine("Nema predstojećih izvedbi.");
            }
            sb.AppendLine();

 
            var predstave = await _db.Predstavas
                .Include(p => p.Zanr)
                .Include(p => p.Reziser)
                .Include(p => p.GlumacPredstavas)
                    .ThenInclude(gp => gp.Glumac)
                .Where(p => (bool)p.IsActive)
                .ToListAsync();

            sb.AppendLine("=== SVE AKTIVNE PREDSTAVE ===");
            foreach (var p in predstave)
            {
                var glumci = p.GlumacPredstavas.Any()
                    ? string.Join(", ", p.GlumacPredstavas.Select(g => $"{g.Glumac.Ime} {g.Glumac.Prezime}"))
                    : "Nije navedeno";

                sb.AppendLine($"Naziv: {p.Naziv} | Žanr: {p.Zanr?.Naziv} | Trajanje: {p.Trajanje} min | Režiser: {p.Reziser?.Ime} {p.Reziser?.Prezime} | Glumci: {glumci}");
            }
            sb.AppendLine();


            var statistika = await _db.Predstavas
                .Where(p => (bool)p.IsActive)
                .Select(p => new
                {
                    p.Naziv,
                    BrojRezervacija = _db.Rezervacijas.Count(r => r.Izvedba.PredstavaId == p.Id),
                    ProsjecnaOcjena = _db.KomentarPrestavas
                        .Where(k => k.PredstavaId == p.Id)
                        .Average(k => (double?)k.Ocjena) ?? 0.0,
                    BrojOcjena = _db.KomentarPrestavas.Count(k => k.PredstavaId == p.Id)
                })
                .ToListAsync();

            sb.AppendLine("=== STATISTIKA PRODAJE PO PREDSTAVI ===");
            foreach (var s in statistika)
            {
                sb.AppendLine($"Naziv: {s.Naziv} | Rezervacije: {s.BrojRezervacija} | Prosječna ocjena: {s.ProsjecnaOcjena:F1} | Broj ocjena: {s.BrojOcjena}");
            }
            sb.AppendLine();

            var najpopularnije = statistika
                .OrderByDescending(x => x.BrojRezervacija)
                .ThenByDescending(x => x.ProsjecnaOcjena)
                .Take(5)
                .ToList();

            sb.AppendLine("=== NAJPOPULARNIJE PREDSTAVE (TOP 5) ===");
            int rank = 1;
            foreach (var p in najpopularnije)
            {
                sb.AppendLine($"{rank++}. {p.Naziv} | Rezervacije: {p.BrojRezervacija} | Prosječna ocjena: {p.ProsjecnaOcjena:F1}");
            }
            sb.AppendLine();

            var najlosije = statistika
                .Where(x => x.BrojOcjena > 0)
                .OrderBy(x => x.ProsjecnaOcjena)
                .ThenBy(x => x.BrojRezervacija)
                .Take(5)
                .ToList();

            sb.AppendLine("=== NAJSLABIJE OCIJENJENE PREDSTAVE ===");
            if (najlosije.Any())
            {
                rank = 1;
                foreach (var p in najlosije)
                {
                    sb.AppendLine($"{rank++}. {p.Naziv} | Prosječna ocjena: {p.ProsjecnaOcjena:F1} | Rezervacije: {p.BrojRezervacija}");
                }
            }
            else
            {
                sb.AppendLine("Nema dovoljno ocjena za analizu.");
            }
            sb.AppendLine();
            var zanrPopularnost = await _db.Rezervacijas
                .Select(r => new { ZanrNaziv = r.Izvedba.Predstava.Zanr.Naziv })
                .GroupBy(x => x.ZanrNaziv)
                .Select(g => new { Zanr = g.Key, BrojRezervacija = g.Count() })
                .OrderByDescending(x => x.BrojRezervacija)
                .ToListAsync();

            sb.AppendLine("=== POPULARNOST ŽANROVA ===");
            if (zanrPopularnost.Any())
            {
                foreach (var z in zanrPopularnost)
                {
                    sb.AppendLine($"Žanr: {z.Zanr ?? "Nepoznat"} | Ukupne rezervacije: {z.BrojRezervacija}");
                }
            }
            else
            {
                sb.AppendLine("Nema podataka o rezervacijama po žanrovima.");
            }

            return sb.ToString();
        }

        private async Task<HttpResponseMessage> SendWithRetryAsync(string jsonPayload)
        {
            const int maxRetries = 3;
            int delayMs = 500;

            for (int i = 0; i < maxRetries; i++)
            {
                var content = new StringContent(jsonPayload, Encoding.UTF8, "application/json");
                var response = await _httpClient.PostAsync(GeminiEndpoint, content);

                if (response.IsSuccessStatusCode)
                    return response;

                if ((int)response.StatusCode == 503)
                {
                    await Task.Delay(delayMs);
                    delayMs *= 2;
                    continue;
                }

                return response;
            }

            throw new Exception("Gemini API je nedostupan. Pokušajte ponovo kasnije.");
        }
    }
}
