FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-env
WORKDIR /App

# Copy everything
COPY . ./
# Restore as distinct layers
RUN dotnet restore
# Build and publish a release
RUN dotnet publish -c Release -r linux-x64 -o out 

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:7.0
WORKDIR /App

EXPOSE 80

COPY --from=build-env /App/out .
ENTRYPOINT ["dotnet", "ContanerAppsSecretDemo.dll"]