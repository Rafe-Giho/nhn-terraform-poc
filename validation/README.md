# Validation Workspaces

이 디렉터리는 표준 blueprint를 실제 NHN Cloud 계정으로 검증하기 위한 작업 공간이다.

검증 원칙:

- 표준 원본은 `infra/blueprints`와 `infra/modules`에 둔다.
- 검증 작업은 전환 유형별 하위 디렉터리에서 독립적으로 진행한다.
- `terraform.tfvars`, state, plan 파일은 커밋하지 않는다.
- `terraform apply`와 `terraform destroy`는 사용자 승인 후 실행한다.

