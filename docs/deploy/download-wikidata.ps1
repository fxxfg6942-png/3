<#
.SYNOPSIS
    Downloads the English Wikipedia title list and the 24 hourly page view files of one day into the wikidata folder.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\docs\deploy\download-wikidata.ps1 -Date 2026-11-20 -ContactEmail you@example.com
#>
param(
    [Parameter(Mandatory = $true)][string]$Date,
    [string]$OutputFolder = '',
    [string]$ContactEmail = 'your-email@example.com'
)

$ErrorActionPreference = 'Stop'
# Windows PowerShell 5.1 leaves $PSScriptRoot empty inside param(), so the default is set here.
if ([string]::IsNullOrWhiteSpace($OutputFolder)) {
    $OutputFolder = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'wikidata'
}
$day = [datetime]::ParseExact($Date, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
# Wikimedia asks every tool to send a User-Agent with a way to contact its owner.
$userAgent = "QuerySuggestionTraining/1.0 (contact: $ContactEmail)"
$pageviewFolder = Join-Path $OutputFolder 'pageviews'
New-Item -ItemType Directory -Force -Path $pageviewFolder | Out-Null

function Get-WikiFile([string]$url, [string]$path) {
    if (Test-Path $path) {
        Write-Host "Already downloaded: $(Split-Path $path -Leaf)"
        return
    }

    Write-Host "Downloading $url"
    curl.exe --fail --location --retry 3 --user-agent $userAgent --output "$path.part" $url
    if ($LASTEXITCODE -ne 0) { throw "Download failed: $url" }
    Move-Item "$path.part" $path
}

# The title list of the same day, so titles and views describe the same Wikipedia.
$titleListName = 'enwiki-{0:yyyyMMdd}-all-titles-in-ns-0.gz' -f $day
$titleListUrl = 'https://dumps.wikimedia.org/other/pagetitles/{0:yyyyMMdd}/{1}' -f $day, $titleListName
Get-WikiFile $titleListUrl (Join-Path $OutputFolder $titleListName)

for ($hour = 0; $hour -lt 24; $hour++) {
    $fileName = 'pageviews-{0:yyyyMMdd}-{1:D2}0000.gz' -f $day, $hour
    $url = 'https://dumps.wikimedia.org/other/pageviews/{0:yyyy}/{0:yyyy-MM}/{1}' -f $day, $fileName
    Get-WikiFile $url (Join-Path $pageviewFolder $fileName)
}

Write-Host ''
Write-Host 'Done. Check the DatasetBuilder section of QuerySuggestion.Api/appsettings.json:'
Write-Host "  `"TitleListFile`": `"../wikidata/$titleListName`""
Write-Host '  "PageviewFolder": "../wikidata/pageviews"'
Write-Host "  `"PageviewDate`": `"$Date`""
Write-Host 'Then build the dataset:  cd QuerySuggestion.Api;  dotnet run -- build-dataset'
