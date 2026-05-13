param(
  [string]$TerraformRoot = ".",
  [string]$OutDir = "../../harness/out"
)

$ErrorActionPreference = "Stop"

Push-Location $TerraformRoot
try {
  if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
  }

  terraform init -input=false
  terraform plan -out="$OutDir/tfplan"
  terraform show -json "$OutDir/tfplan" | Out-File -FilePath "$OutDir/tfplan.json" -Encoding utf8
}
finally {
  Pop-Location
}

