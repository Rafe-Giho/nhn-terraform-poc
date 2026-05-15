# New Project Scripts

표준 blueprint에서 사업별 Terraform workspace를 생성하는 스크립트다.

IaaS 3-tier:

```bash
./tools/new-project/create-iaas-3tier.sh <project-name> <env> [target-dir]
```

Cloud native:

```bash
./tools/new-project/create-cloud-native.sh <project-name> <env> [target-dir]
```

세 번째 인자를 생략하면 `projects/<project-name>/<type>/<env>` 아래에 생성된다. `projects/`는 `.gitignore` 대상이므로 실제 장기 운영 프로젝트는 별도 사업 repository 경로를 세 번째 인자로 지정하는 것을 권장한다.

생성된 workspace에는 실행 root, 필요한 module, `harness/scripts`가 함께 복사된다. `terraform.tfvars`를 만들고 실제 NHN Cloud 계정값을 입력한 뒤 `init`, `validate`, `plan`, `apply` 순서로 진행한다.

`plan` 이후에는 `terraform show -json`으로 plan JSON을 만들고 `./harness/scripts/policy-check.sh`로 공개 SSH/RDP, 공개 전체 egress, 고위험 delete/replace를 확인한다.

Cloud native workspace의 `foundation` stack은 NKS뿐 아니라 선택형 GitLab/Gitea/Jenkins 연동 서버용 VM, data volume, security group도 만들 수 있다. GitLab/Gitea/Jenkins 애플리케이션 설치, 계정, token, credential은 Terraform 밖에서 관리한다.

네트워크는 두 표준 모두 `VPC 1개 + public/private/management routing table + 역할별 subnet` 구조로 생성된다. 다중 VPC가 필요한 사업은 생성된 workspace를 기준으로 별도 설계 검토 후 확장한다.

Security Group은 기본 outbound 전체 허용 rule을 삭제하고 표준 egress만 생성한다. NAT Gateway, Service Gateway, Network ACL, Flow Log는 콘솔 선행 항목으로 따로 검증한다.
