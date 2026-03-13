using Microsoft.Extensions.Options;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Text;
using eTheater.Model.SearchObjects;
using eTheater.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;


namespace eTheater.Services
{
    public class OpenAISettings
    {
        public string ApiKey { get; set; } = string.Empty;
    }

    public interface IChatRepository
    {
        Task<string> GetResponseAsync(string prompt, string previousResponse );
    }

    public class ChatRepository : IChatRepository
    {
        private readonly ETheaterContext _db;
        private readonly HttpClient _httpClient;

        private const string GeminiEndpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

        private readonly string systemPrompt = @"
        Budi ljubazan i pristojan.
        Ponašaj se kao asistent u prodaji karata u pozorištu, ali uvijek budi prijatan. Ako ti se neko obrati bez poštovanja i ti budi bahat (istom mjerom).
        Ako ne znaš odgovor, reci:
        'Za detaljnije informacije možete nas kontaktirati na email: etheater209@gmail.com'
        Nemoj izmišljati informacije. 
        Odgovaraj kratko, jasno i prijateljski. Ako konverzacija ima prethodnu poruku ponašaj se tako, nemoj opet pozdravljati korisnika.
    ";

        public ChatRepository(ETheaterContext db, HttpClient httpClient, IConfiguration configuration)
        {
            _db = db;
            _httpClient = httpClient;
            var apiKey = configuration["Gemini:ApiKey"] ?? "";
            if (!_httpClient.DefaultRequestHeaders.Contains("x-goog-api-key"))
                _httpClient.DefaultRequestHeaders.Add("x-goog-api-key", apiKey);
        }

        public async Task<string> GetResponseAsync(string prompt, string previousResponse = "")
        {
            string contextInfo = await BuildContextAsync(prompt);

            var finalPrompt = systemPrompt + "\n\n" +
                              "Prethodna komunikacija:\n" + previousResponse + "\n\n" +
                              "Dodatne informacije:\n" + contextInfo +
                              "\n\nPitanje korisnika: " + prompt;

            var payload = new
            {
                contents = new[]
                {
                new {
                    parts = new[]
                    {
                        new { text = finalPrompt }
                    }
                }
            }
            };

            var jsonPayload = JsonSerializer.Serialize(payload);
            var httpContent = new StringContent(jsonPayload, Encoding.UTF8, "application/json");

            var response = await SendWithRetryAsync(httpContent);
            var responseContent = await response.Content.ReadAsStringAsync();

            using var jsonDoc = JsonDocument.Parse(responseContent);
            var root = jsonDoc.RootElement;

            if (root.TryGetProperty("candidates", out var candidates) &&
                candidates.ValueKind == JsonValueKind.Array)
            {
                return candidates[0]
                    .GetProperty("content")
                    .GetProperty("parts")[0]
                    .GetProperty("text")
                    .GetString() ?? "";
            }

            return "";
        }

        private async Task<string> BuildContextAsync(string prompt, string previousResponse = "")
        {
            var sb = new StringBuilder();
            var today = DateTime.Today;
            string lower = prompt.ToLower();

            if (!string.IsNullOrEmpty(previousResponse))
            {
                sb.AppendLine("Prethodna komunikacija:");
                sb.AppendLine(previousResponse);
                sb.AppendLine();
            }
            var izvedbe = await _db.Izvedbas
                .Include(i => i.Predstava)
                    .ThenInclude(p => p.Zanr)
                .Include(i => i.Predstava)
                    .ThenInclude(p => p.Reziser)
                .Where(i => i.DatumVrijeme >= today && (bool)i.Predstava.IsActive)
                .OrderBy(i => i.DatumVrijeme)
                .ToListAsync();

            if (izvedbe.Any())
            {
                sb.AppendLine("Aktuelni repertoar:");
                foreach (var iz in izvedbe)
                {
                    sb.AppendLine($"{iz.Predstava.Naziv} – {iz.DatumVrijeme:dd.MM.yyyy HH:mm} – {iz.CijenaKarte} KM");
                }
                sb.AppendLine();
            }

            var predstave = await _db.Predstavas
                .Include(p => p.Zanr)
                .Include(p => p.Reziser)
                .Include(p => p.GlumacPredstavas)
                    .ThenInclude(gp => gp.Glumac)
                .Where(p => (bool)p.IsActive)
                .ToListAsync();

            sb.AppendLine("Dostupne predstave i detalji:");
            foreach (var p in predstave)
            {
                sb.AppendLine($@"
Naziv: {p.Naziv}
Žanr: {p.Zanr?.Naziv}
Trajanje: {p.Trajanje} min
Režiser: {p.Reziser?.Ime} {p.Reziser?.Prezime}
Opis: {p.Opis}
Glumci: {string.Join(", ", p.GlumacPredstavas.Select(g => g.Glumac.Ime + " " + g.Glumac.Prezime))}
");
            }

            var topPredstave = await _db.Predstavas
                .Where(p => (bool)p.IsActive)
                .Select(p => new
                {
                    p.Naziv,
                    Rezervacije = _db.Rezervacijas.Count(r =>
                        r.Izvedba.PredstavaId == p.Id &&
                        r.Izvedba.DatumVrijeme >= today),
                    Ocjena = _db.KomentarPrestavas
                        .Where(k => k.PredstavaId == p.Id)
                        .Average(k => (double?)k.Ocjena) ?? 0
                })
                .OrderByDescending(x => x.Rezervacije)
                .ThenByDescending(x => x.Ocjena)
                .Take(5)
                .ToListAsync();

            sb.AppendLine("Preporučene / najgledanije predstave:");
            foreach (var p in topPredstave)
                sb.AppendLine($"{p.Naziv} – rezervacije: {p.Rezervacije}, prosječna ocjena: {p.Ocjena:F1}");

            sb.AppendLine(@"
Kupovina karata:
- Karte možete rezervisati online.
- Plaćanje je moguće online ili lično na blagajni.
- Blagajna radi od 10:00 do 14:00.
");


            sb.AppendLine("Kontakt:");
            sb.AppendLine("Email: etheater209@gmail.com");
            sb.AppendLine("Telefon: 033/123-456");
            sb.AppendLine("Pozorište se nalazi u centru Sarajeva, Kulina Bana 12.");

            return sb.ToString();
        }


        private bool ContainsAny(string text, params string[] keywords)
      => keywords.Any(k => text.Contains(k));


        private async Task<HttpResponseMessage> SendWithRetryAsync(HttpContent httpContent)
        {
            const int maxRetries = 3;
            int delayMs = 500;

            for (int i = 0; i < maxRetries; i++)
            {
                var response = await _httpClient.PostAsync(GeminiEndpoint, httpContent);

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

            throw new Exception("Gemini API is continuously unavailable. Try again later.");
        }

    }


}


