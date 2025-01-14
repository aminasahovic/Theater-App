using eTheater.Services;
using eTheater.Services.Database;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddTransient<IZanrService, ZanrService>();
builder.Services.AddTransient<ITipKorisnikService, TipKorisnikaService>();
builder.Services.AddTransient<ISjedisteService, SjedisteService>();
builder.Services.AddTransient<ISalaService, SalaService>();
builder.Services.AddTransient<IReziserService, ReziserService>();
builder.Services.AddTransient<IRezervacijaService, RezervacijaService>();
builder.Services.AddTransient<IRepertoarIzvedbaService, RepertoarIzvedbaService>();
builder.Services.AddTransient<IRepertoarService, RepertoarService>();
builder.Services.AddTransient<IPredstavaService, PredstavaService>();
builder.Services.AddTransient<IOdgovorKomentarService, OdgovorKomentarService>();
builder.Services.AddTransient<IObavijestService, ObavijestService>();
builder.Services.AddTransient<IKorisnikService, KorisnikService>();
builder.Services.AddTransient<IKomentarPrestavaService, KomentarPrestavaService>();
builder.Services.AddTransient<IKomentarObavijestService, KomentarObavijestService>();
builder.Services.AddTransient<IIzvedbaSjedisteService, IzvedbaSjedisteService>();
builder.Services.AddTransient<IIzvedbaService, IzvedbaService>();
builder.Services.AddTransient<IGlumacPredstavaService, GlumacPredstavaService>();
builder.Services.AddTransient<IGlumacService, GlumacService>();


var connectionString = builder.Configuration.GetConnectionString("eTheaterConnection");
builder.Services.AddDbContext<ETheaterContext>(options =>
    options.UseSqlServer(connectionString));
builder.Services.AddMapster();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
