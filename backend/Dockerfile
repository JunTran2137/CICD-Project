# --------------------------------------
# Stage 1: restore & build
# --------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

# Copy csproj and restore dependencies
COPY App.csproj ./
RUN dotnet restore App.csproj

# Copy all source files and build
COPY . .
RUN dotnet build App.csproj -c Release -o /app/build

# --------------------------------------
# Stage 2: publish
# --------------------------------------
FROM build AS publish
RUN dotnet publish App.csproj -c Release -o /app/publish /p:UseAppHost=false

# --------------------------------------
# Stage 3: runtime
# --------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final

WORKDIR /app

# (Optional) override URLs so Kestrel listens on port 80
ENV ASPNETCORE_URLS=http://+:80 
#;https://+:443
# Copy published output
COPY --from=publish /app/publish .

# Expose HTTP port
EXPOSE 80

# Launch the API
ENTRYPOINT ["dotnet", "App.dll"]
