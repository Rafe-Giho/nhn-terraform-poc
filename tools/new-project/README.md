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

생성된 workspace에서 `terraform.tfvars`를 만들고 실제 NHN Cloud 계정값을 입력한 뒤 `init`, `validate`, `plan`, `apply` 순서로 진행한다.

