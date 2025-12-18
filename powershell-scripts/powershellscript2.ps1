$server   = $env:PROD_DB_SERVER
$port     = $env:PROD_DB_PORT
$username = $env:PROD_DB_USERNAME
$password = $env:PROD_DB_PASSWORD
$database = $env:PROD_DB_NAME
$bucket   = $env:S3_BUCKET

if (-not $bucket) {
    throw "S3_BUCKET environment variable not set"
}

$queryFile  = "queryFiles/query3-insert-user.sql"
$outputFile = "output_query3-insert-user.txt"

Write-Host "Starting insertion batch job..."
Write-Host "Server: $server"
Write-Host "Database: $database"

if (-not (Test-Path $queryFile)) {
    throw "Query file not found: $queryFile"
}

# ✅ PowerShell-safe MySQL execution
Get-Content $queryFile | mysql `
    --host=$server `
    --port=$port `
    --user=$username `
    --password=$password `
    --database=$database `
    2>&1 | Tee-Object -FilePath $outputFile

if ($LASTEXITCODE -ne 0) {
    throw "MySQL execution failed"
}

$s3Key = "insertion/$outputFile"
aws s3 cp $outputFile "s3://$bucket/$s3Key"

if ($LASTEXITCODE -ne 0) {
    throw "S3 upload failed"
}

Write-Host "Insertion job completed successfully"
Get-Content $outputFile
