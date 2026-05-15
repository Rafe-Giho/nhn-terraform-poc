# NHN Cloud Terraform Harness

이 디렉터리는 NHN Cloud Terraform 작업을 반복 가능하게 검증하기 위한 하네스다.

## 실행 순서

```bash
# 1. provider 코드 기준 리소스 인벤토리 생성
pwsh ./harness/scripts/extract-provider-inventory.ps1 \
  -ProviderSource ./.provider-src \
  -OutputPath ./harness/out/nhncloud-provider-inventory.md

# 2. 정적 검증
pwsh ./harness/scripts/static-check.ps1 -TerraformRoot ./infra/blueprints/iaas-3tier/examples/dev
pwsh ./harness/scripts/static-check.ps1 -TerraformRoot ./infra/blueprints/cloud-native/foundation/examples/dev
pwsh ./harness/scripts/static-check.ps1 -TerraformRoot ./infra/blueprints/cloud-native/platform/examples/dev

# 3. Terraform Registry provider schema 검증
pwsh ./harness/scripts/verify-registry-schema.ps1 -ProviderVersion 1.0.8

# 4. plan JSON 생성
pwsh ./harness/scripts/plan-json.ps1 -TerraformRoot ./infra/blueprints/iaas-3tier/examples/dev
pwsh ./harness/scripts/plan-json.ps1 -TerraformRoot ./infra/blueprints/cloud-native/foundation/examples/dev
pwsh ./harness/scripts/plan-json.ps1 -TerraformRoot ./infra/blueprints/cloud-native/platform/examples/dev
```

## 승인 기준

- `apply`, `destroy`, NKS/NAS/DB 같은 비용성 리소스 생성은 사용자 승인을 받은 뒤 실행한다.
- `harness/out/` 결과물은 재생성 가능한 파일이므로 커밋하지 않는다.
- provider 문서와 코드가 다르면 코드 기준 목록을 우선 기록하되, 운영 권장 범위는 NHN Cloud 문서화 여부를 함께 본다.
