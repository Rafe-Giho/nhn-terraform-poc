# Project Examples

이 디렉터리는 `tools/new-project` 스크립트로 생성되는 사업별 Terraform workspace의 형태를 설명한다.

생성 명령:

```bash
./tools/new-project/create-iaas-3tier.sh customer-a dev
./tools/new-project/create-cloud-native.sh customer-a dev
```

기본 생성 위치:

```text
projects/
  customer-a/
    iaas-3tier/dev/
      terraform/
      modules/
    cloud-native/dev/
      foundation/
      platform/
      modules/
```

`projects/`는 실제 계정값, state, plan 산출물이 생기는 작업 디렉터리라 기본적으로 커밋하지 않는다. 장기 운영 프로젝트는 생성된 workspace를 별도 사업 repository로 옮겨 관리한다.

