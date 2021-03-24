#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0-alpine AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:5.0-alpine AS build
WORKDIR /src
COPY ["CoreDockerImageSizeTest/CoreDockerImageSizeTest.csproj", "CoreDockerImageSizeTest/"]
RUN dotnet restore "CoreDockerImageSizeTest/CoreDockerImageSizeTest.csproj"
COPY . .
WORKDIR "/src/CoreDockerImageSizeTest"
RUN dotnet build "CoreDockerImageSizeTest.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CoreDockerImageSizeTest.csproj" -c Release -o /app/publish \
    --runtime alpine-x64 \
    --self-contained true \
    /p:PublishTrimmed=true \
    /p:PublishSingleFile=true

FROM mcr.microsoft.com/dotnet/runtime-deps:5.0-alpine AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["./CoreDockerImageSizeTest"]