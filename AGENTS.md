# AGENTS.md

이 저장소는 NHN Cloud Terraform PoC와 운영 표준화를 위한 작업 공간이다.

## 기본 원칙

- 답변과 문서는 한국어로 작성한다.
- NHN Cloud Terraform 범위를 말할 때는 반드시 출처를 구분한다.
  - `provider.go`의 `ResourcesMap`/`DataSourcesMap`: provider 코드상 노출된 전체 목록
  - `docs/resources`, `docs/data-sources`, NHN Cloud 사용자 가이드: NHN Cloud에서 문서화된 안전 우선 범위
  - 문서화되지 않은 OpenStack 계열 리소스: provider에는 있으나 NHN Cloud 실사용은 검증 필요
- `terraform apply`, `terraform destroy`, 실제 클라우드 리소스 생성/삭제/변경은 사용자 승인 없이 실행하지 않는다.
- 자격 증명, `*.tfvars`, state, plan JSON, provider schema 출력물은 커밋하지 않는다.
- provider 버전과 리소스 목록을 갱신할 때는 `harness/scripts/extract-provider-inventory.ps1`로 인벤토리를 재생성하거나 동일 기준으로 수동 갱신한다.

## 하네스 운영 규칙

Terraform 변경은 다음 순서로 검증한다.

1. Provider inventory: provider 코드 또는 schema 기준으로 리소스 목록 확인
2. Static check: `terraform fmt`, `terraform validate`, `tflint`, `checkov` 또는 `tfsec`
3. Plan check: `terraform plan -out`, `terraform show -json`
4. Policy review: 공개 인바운드, destroy, 과도한 Floating IP, 운영 `-target` 사용 여부 확인
5. Smoke apply: 비용이 작은 dev 전용 stack부터 수동 승인 후 적용
6. Drift check: 운영 환경은 `terraform plan -refresh-only`만 주기 실행

## 문서 구조

- `docs/standards/terraform-scope.md`: 구축 범위, 운영 판단, 표준 아키텍처
- `docs/reference/provider-inventory.md`: provider 전체 리소스/데이터소스 목록
- `docs/assets/nhn-cloud-standard-architecture.svg`: 표준 아키텍처 그림
- `docs/guides/`: 팀원이 따라 실행하는 구축 가이드
- `infra/blueprints/`: 사업별로 복사/실행하는 표준 Terraform blueprint
- `infra/modules/`: blueprint가 사용하는 공통 Terraform module
- `harness/`: 검증 스크립트와 실행 규칙
