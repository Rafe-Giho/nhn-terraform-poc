# Optional remote state backend example.
# NHN Cloud Object Storage S3-compatible backend must be verified before production use.
# Backend bucket/container must be created before terraform init.

bucket                      = "replace-with-precreated-state-bucket"
key                         = "nhn-terraform/dev/terraform.tfstate"
region                      = "KR1"
endpoint                    = "https://kr1-api-object-storage.nhncloudservice.com"
skip_credentials_validation = true
skip_metadata_api_check     = true
skip_region_validation      = true
force_path_style            = true

