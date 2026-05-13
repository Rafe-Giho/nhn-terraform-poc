param(
  [string]$ProviderVersion = "1.0.8",
  [string]$WorkDir = "harness/out/registry-schema-check"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $WorkDir)) {
  New-Item -ItemType Directory -Path $WorkDir | Out-Null
}

$ResolvedWorkDir = (Resolve-Path $WorkDir).Path

$providerTf = @"
terraform {
  required_providers {
    nhncloud = {
      source  = "nhn-cloud/nhncloud"
      version = "= $ProviderVersion"
    }
  }
}
"@

Set-Content -Path (Join-Path $ResolvedWorkDir "providers.tf") -Value $providerTf -Encoding UTF8

terraform "-chdir=$ResolvedWorkDir" init -backend=false -input=false
$schemaJson = terraform "-chdir=$ResolvedWorkDir" providers schema -json
$schemaPath = Join-Path $ResolvedWorkDir "schema.json"
Set-Content -Path $schemaPath -Value $schemaJson -Encoding UTF8

$schema = $schemaJson | ConvertFrom-Json
$providerKey = "registry.terraform.io/nhn-cloud/nhncloud"
$providerSchema = $schema.provider_schemas.$providerKey

if (-not $providerSchema) {
  throw "Provider schema not found for $providerKey"
}

$resourceCount = @($providerSchema.resource_schemas.PSObject.Properties).Count
$dataSourceCount = @($providerSchema.data_source_schemas.PSObject.Properties).Count

Write-Output "provider=$providerKey"
Write-Output "version=$ProviderVersion"
Write-Output "resource_schemas=$resourceCount"
Write-Output "data_source_schemas=$dataSourceCount"
Write-Output "schema_path=$schemaPath"
