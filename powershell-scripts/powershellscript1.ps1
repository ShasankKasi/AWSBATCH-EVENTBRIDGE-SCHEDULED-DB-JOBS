$server   = $env:PROD_DB_SERVER
$port     = $env:PROD_DB_PORT
$username = $env:PROD_DB_USERNAME
$password = $env:PROD_DB_PASSWORD
$database = $env:PROD_DB_NAME
$bucket   = $env:S3_BUCKET

if (-not $bucket) {
    throw "S3_BUCKET environment variable not set"
}

$queryFiles = @(
    "queryFiles/query1-fetch-inactive-users.sql",
    "queryFiles/query2-log-job-summary.sql"
)

Write-Host "Starting MySQL batch job..."
Write-Host "Server: $server"
Write-Host "Database: $database"
Write-Host "S3 Bucket: $bucket"

foreach ($queryFile in $queryFiles) {

    if (-not (Test-Path $queryFile)) {
        throw "Query file not found: $queryFile"
    }

    $outputFile = "output_$(Split-Path $queryFile -Leaf).txt"

    Write-Host "---------------------------------------"
    Write-Host "Executing $queryFile"

    # ✅ PowerShell-safe execution
    Get-Content $queryFile | mysql `
        --host=$server `
        --port=$port `
        --user=$username `
        --password=$password `
        --database=$database `
        2>&1 | Tee-Object -FilePath $outputFile

    if ($LASTEXITCODE -ne 0) {
        throw "MySQL execution failed for $queryFile"
    }

    $s3Key = "cleanup/$outputFile"
    aws s3 cp $outputFile "s3://$bucket/$s3Key"

    if ($LASTEXITCODE -ne 0) {
        throw "S3 upload failed for $outputFile"
    }

    Write-Host "Uploaded to s3://$bucket/$s3Key"
    Get-Content $outputFile
}

Write-Host "Cleanup batch job completed successfully"
