FROM mcr.microsoft.com/azure-powershell:14.3.0-alpine-3.20

WORKDIR /app

RUN apk add --no-cache \
    aws-cli \
    curl \
    mariadb-client

COPY powershell-scripts/ ./powershell-scripts/
COPY queryFiles/ ./queryFiles/

ENTRYPOINT ["pwsh", "-Command", "\
    Install-Module -Name SqlServer -Force -AllowClobber -Scope CurrentUser; \
    Write-Host 'Fetching Prod secrets from AWS Secrets Manager...'; \
    $prod_secret = aws secretsmanager get-secret-value --secret-id 'prod/secret1' --query SecretString --output text; \
    $prod_creds = $prod_secret | ConvertFrom-Json; \
    $env:PROD_DB_SERVER   = $prod_creds.host; \
    $env:PROD_DB_PORT     = $prod_creds.port; \
    $env:PROD_DB_USERNAME = $prod_creds.username; \
    $env:PROD_DB_PASSWORD = $prod_creds.password; \
    $env:PROD_DB_NAME     = $prod_creds.dbname; \
    Write-Host 'Prod Secrets loaded. Running Batch command...'; \
    pwsh -File /app/powershell-scripts/powershellscript2.ps1"]
