using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using App.Models;                               // namespace chứa DataContext

var builder = WebApplication.CreateBuilder(args);

// 1. Cấu hình sources (CreateDefaultBuilder đã load appsettings & env vars)
builder.Configuration
       .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
       .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json",
                    optional: true, reloadOnChange: true)
       .AddEnvironmentVariables();

// 2. Đăng ký CORS
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod());
});

// 3. Đăng ký Controllers
builder.Services.AddControllers();

// 4. Lấy connection string và đăng ký DbContext
var connStr = builder.Configuration.GetConnectionString("Database");
if (string.IsNullOrWhiteSpace(connStr))
{
    throw new InvalidOperationException(
        "ConnectionStrings:Database không được cấu hình. " +
        "Hãy set biến env 'ConnectionStrings__Database'."
    );
}

builder.Services.AddDbContext<DataContext>(options =>
    options.UseNpgsql(connStr);
);

var app = builder.Build();

// 5. Pipeline
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.UseHttpsRedirection();
app.UseCors();
app.MapControllers();

app.Run();
