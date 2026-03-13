using eTheater.API;
using eTheater.API.Filters;
using eTheater.Services;
using eTheater.Services.Database;
using eTheater.Services.RabbitMQConsumer;
using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using Microsoft.EntityFrameworkCore.Storage;
using eTheater.Model;
using Microsoft.Extensions.Options;


var builder = WebApplication.CreateBuilder(args);



builder.Services.AddHttpClient(); 


// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle

builder.Services.AddTransient<IChatRepository, ChatRepository>();
builder.Services.AddTransient<IAdminChatRepository, AdminChatRepository>();
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
builder.Services.AddTransient<IRabbitMQProducer, RabbitMQProducer>();
builder.Services.AddTransient<IRecommenderService, RecommenderService>();


builder.Services.AddControllers(x =>
    x.Filters.Add<ExceptionFilter>());
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
    {
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "basic"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference{Type = ReferenceType.SecurityScheme, Id = "basicAuth"}
            },
            new string[]{}
    } });

});
var connectionString = builder.Configuration.GetConnectionString("eTheaterConnection");
builder.Services.AddDbContext<ETheaterContext>(options =>
    options.UseSqlServer(connectionString));
builder.Services.AddMapster();
builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy
            .AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

var app = builder.Build(); 

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseAuthorization();

app.MapControllers();

using (var scope = app.Services.CreateScope())
{

    Console.WriteLine("Ovdje 2");

    var dataContext = scope.ServiceProvider.GetRequiredService<ETheaterContext>();
    if (dataContext.Database.CanConnect())
    {
        Console.WriteLine("Ovdje 3");

        dataContext.Database.Migrate();

        var recommendResutService = scope.ServiceProvider.GetRequiredService<IRecommenderService>();
        try
        {
            Console.WriteLine("Ovdje 4");
            await recommendResutService.DeleteAllRecommendation();


            await recommendResutService.TrainModelAsync();
        }
        catch (Exception e)
        {
        }
    }
}
app.Run();
