param(
  [string]$ProviderSource = ".provider-src",
  [string]$OutputPath = "harness/out/nhncloud-provider-inventory.md",
  [string]$SourceRef = ""
)

$ErrorActionPreference = "Stop"

$providerFile = Join-Path $ProviderSource "nhncloud/provider.go"
$resourceDocs = Join-Path $ProviderSource "docs/resources"
$dataDocs = Join-Path $ProviderSource "docs/data-sources"

if (-not (Test-Path $providerFile)) {
  throw "provider.go not found: $providerFile"
}

$outDir = Split-Path -Parent $OutputPath
if ($outDir -and -not (Test-Path $outDir)) {
  New-Item -ItemType Directory -Path $outDir | Out-Null
}

$docResources = @{}
if (Test-Path $resourceDocs) {
  Get-ChildItem $resourceDocs -Filter "*.md" | ForEach-Object {
    $name = $_.BaseName
    if ($name -eq "nhncloud_networking_secgroup_rule") {
      $name = "nhncloud_networking_secgroup_rule_v2"
    }
    $docResources[$name] = $true
  }
}

$docDataSources = @{}
if (Test-Path $dataDocs) {
  Get-ChildItem $dataDocs -Filter "*.md" | ForEach-Object {
    $docDataSources[$_.BaseName] = $true
  }
}

function Get-Area([string]$Name) {
  if ($Name -match "^nhncloud_([^_]+)") {
    return $Matches[1]
  }
  return "unknown"
}

$lines = Get-Content $providerFile
$resources = $lines |
  Select-String '"nhncloud_.*":\s+resource' |
  ForEach-Object {
    if ($_.Line -match '"(nhncloud_[^"]+)"') { $Matches[1] }
  }

$dataSources = $lines |
  Select-String '"nhncloud_.*":\s+dataSource' |
  ForEach-Object {
    if ($_.Line -match '"(nhncloud_[^"]+)"') { $Matches[1] }
  }

$content = New-Object System.Collections.Generic.List[string]
$content.Add("# NHN Cloud Provider Inventory")
$content.Add("")
if ($SourceRef) {
  $content.Add("Generated from ``$($providerFile -replace '\\', '/')`` at ``$SourceRef``.")
} else {
  $content.Add("Generated from ``$($providerFile -replace '\\', '/')``.")
}
$content.Add("")
$content.Add("이 문서는 provider의 ``ResourcesMap``과 ``DataSourcesMap``에 등록된 전체 목록이다. Resource type이 등록되어 있다는 뜻이지, NHN Cloud 운영 환경에서 모두 동일하게 권장된다는 뜻은 아니다.")
$content.Add("")
$content.Add("구분:")
$content.Add("")
$content.Add("- ``provider docs``: provider 저장소의 ``docs/resources`` 또는 ``docs/data-sources``에 문서 파일이 있는 항목")
$content.Add("- ``provider code``: provider 코드에는 등록되어 있으나 docs 파일이 없는 항목")
$content.Add("- 운영 우선순위는 scope 문서의 A/B/C 등급을 따른다.")
$content.Add("")
$content.Add("요약:")
$content.Add("")
$content.Add("- Resources: $($resources.Count)개")
$content.Add("- Data sources: $($dataSources.Count)개")
$content.Add("")
$content.Add("## Resources")
$content.Add("")
$content.Add("| Area | Resource | Source |")
$content.Add("|---|---|---|")
foreach ($resource in $resources) {
  $source = if ($docResources.ContainsKey($resource)) { "provider docs" } else { "provider code" }
  $content.Add("| $(Get-Area $resource) | ``$resource`` | $source |")
}
$content.Add("")
$content.Add("## Data Sources")
$content.Add("")
$content.Add("| Area | Data source | Source |")
$content.Add("|---|---|---|")
foreach ($dataSource in $dataSources) {
  $source = if ($docDataSources.ContainsKey($dataSource)) { "provider docs" } else { "provider code" }
  $content.Add("| $(Get-Area $dataSource) | ``$dataSource`` | $source |")
}

Set-Content -Path $OutputPath -Value $content -Encoding UTF8
Write-Host "Wrote $OutputPath"
