FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 7125
ENV ASPNETCORE_URLS=http://+:7125

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .

FROM build AS publish
RUN dotnet publish "eTheater.API/eTheater.API.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .

ENTRYPOINT ["dotnet", "eTheater.API.dll"]