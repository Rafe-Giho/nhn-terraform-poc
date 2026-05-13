param(
  [string]$TerraformRoot = "."
)

$ErrorActionPreference = "Stop"

Push-Location $TerraformRoot
try {
  terraform fmt -check -recursive
  terraform init -backend=false -input=false
  terraform validate

  if (Get-Command tflint -ErrorAction SilentlyContinue) {
    tflint --init
    tflint --recursive
  }

  if (Get-Command checkov -ErrorAction SilentlyContinue) {
    checkov -d .
  } elseif (Get-Command tfsec -ErrorAction SilentlyContinue) {
    tfsec .
  } else {
    Write-Warning "checkov/tfsec not found. Security scan skipped."
  }
}
finally {
  Pop-Location
}

