FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

ARG TARGETARCH

WORKDIR /app

COPY . .

RUN cd Sunrise.Server && dotnet publish Sunrise.Server.csproj -c Release --self-contained --runtime linux-musl-${TARGETARCH} -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -p:DebugSymbols=false -p:DebugType=None -p:EnableCompressionInSingleFile=true -o publish

FROM alpine:3.23 AS pack

WORKDIR /app

RUN apk add --no-cache musl libstdc++ libgcc icu-libs

COPY --from=build /app/Sunrise.Server/publish/Sunrise.Server .
COPY --from=build /app/Sunrise.Server/publish/appsettings.json .

RUN chmod +x ./Sunrise.Server

CMD ["./Sunrise.Server"]