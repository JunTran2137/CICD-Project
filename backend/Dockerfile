# Build stage
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

# Copy solution and project files
COPY ["ECommerce.Api/Api.csproj", "ECommerce.Api/"]
COPY ["ECommerce.Application/Application.csproj", "ECommerce.Application/"]
COPY ["ECommerce.Domain/Domain.csproj", "ECommerce.Domain/"]
COPY ["ECommerce.Infrastructure/Infrastructure.csproj", "ECommerce.Infrastructure/"]
COPY ["ECommerce-App.sln", "./"]

# Restore dependencies
RUN dotnet restore

# Copy all source code
COPY . .

# Build the application
WORKDIR "/src/ECommerce.Api"
RUN dotnet build "Api.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Final stage
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS final
WORKDIR /app

# Copy published files from publish stage
COPY --from=publish /app/publish .

# Environment variables
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production

# Expose port 80
EXPOSE 80

ENTRYPOINT ["dotnet", "Api.dll"]
