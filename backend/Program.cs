using Microsoft.EntityFrameworkCore;
using Backend.Data;
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddCors(); // Cross-origin resource sharing

builder.Services.AddDbContext<BowlingLeagueContext>(options =>
    options.UseSqlite(builder.Configuration["ConnectionStrings:BowlingLeagueConnection"])
);

builder.Services.AddScoped<IBowlingLeagueRepository, EFBowlingLeagueRepository>(); // Everyone gets their own context; ABSTRACTION

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment()) {
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors(p => p.WithOrigins("http://localhost:3000"));

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();


