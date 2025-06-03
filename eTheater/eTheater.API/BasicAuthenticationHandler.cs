using eTheater.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text.Encodings.Web;
using System.Text;
using System.Data;

namespace eTheater.API
{
    public class BasicAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
    {
        IKorisnikService _korisnikService;
        ITipKorisnikService _korisnikServiceTip;

        public BasicAuthenticationHandler(IOptionsMonitor<AuthenticationSchemeOptions> options, ILoggerFactory logger, UrlEncoder encoder, ISystemClock clock, IKorisnikService korisniciService, ITipKorisnikService tipKorisnikService) : base(options, logger, encoder, clock)
        {
            _korisnikService = korisniciService;
            _korisnikServiceTip = tipKorisnikService;
        }

        protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
        {
            if (!Request.Headers.ContainsKey("Authorization"))
            {
                return AuthenticateResult.Fail("Missing header");
            }

            var authHeader = AuthenticationHeaderValue.Parse(Request.Headers["Authorization"]);
            var credentialsBytes = Convert.FromBase64String(authHeader.Parameter);
            var credentials = Encoding.UTF8.GetString(credentialsBytes).Split(':');

            var username = credentials[0];
            var password = credentials[1];

            var user = _korisnikService.Login(username, password);

            if (user == null)
            {
                return AuthenticateResult.Fail("Auth failed");
            }
            else
            {
                var claims = new List<Claim>()
                {
                    new Claim(ClaimTypes.Name, user.Ime),
                    new Claim(ClaimTypes.NameIdentifier, user.Username)
                };
                var tip = _korisnikServiceTip.GetById((int)user.TipKorisnikaId).Naziv.ToString();
                claims.Add(new Claim(ClaimTypes.Role, tip));
                
                var identity = new ClaimsIdentity(claims, Scheme.Name);

                var principal = new ClaimsPrincipal(identity);

                var ticket = new AuthenticationTicket(principal, Scheme.Name);
                return AuthenticateResult.Success(ticket);
            }
        }
    }
}
