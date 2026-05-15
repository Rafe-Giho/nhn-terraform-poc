# NHN Cloud Terraform Infra

이 디렉터리는 팀 표준 아키텍처를 Terraform blueprint와 공통 module로 제공한다. `blueprints`는 복사해서 실행하는 시작점이고, `modules`는 직접 실행하지 않는 공통 부품이다.

## 구조

| 구분 | 경로 | 역할 |
|---|---|---|
| IaaS 3-tier blueprint | `blueprints/iaas-3tier/examples/dev` | VPC, subnet, security group, compute, load balancer, block storage, object storage |
| Cloud-native foundation blueprint | `blueprints/cloud-native/foundation/examples/dev` | VPC, subnet, security group, object storage, NKS |
| Cloud-native platform blueprint | `blueprints/cloud-native/platform/examples/dev` | NKS 내부 namespace, StorageClass, Argo CD, cert-manager 등 |
| Modules | `modules` | blueprint가 사용하는 재사용 Terraform module |

IaaS 3-tier 전환안은 `compute`, `load-balancer`, `block-storage` 모듈을 사용한다.

## IaaS 3-tier 실행 순서

1. NHN Cloud 콘솔에서 API Endpoint, keypair, external network/subnet, quota를 확인한다.
2. `blueprints/iaas-3tier/examples/dev/terraform.tfvars.example`을 참고해 로컬 `terraform.tfvars`를 만든다.
3. `terraform -chdir=infra/blueprints/iaas-3tier/examples/dev init -backend=false`
4. `terraform -chdir=infra/blueprints/iaas-3tier/examples/dev validate`
5. `terraform -chdir=infra/blueprints/iaas-3tier/examples/dev plan`
6. 승인 후 `terraform -chdir=infra/blueprints/iaas-3tier/examples/dev apply`를 실행한다.

## 클라우드 네이티브 실행 순서

1. NHN Cloud 콘솔에서 API Endpoint, keypair, NKS flavor/image/version, external network/subnet, quota를 확인한다.
2. `blueprints/cloud-native/foundation/examples/dev/terraform.tfvars.example`을 참고해 로컬 `terraform.tfvars`를 만든다.
3. `terraform -chdir=infra/blueprints/cloud-native/foundation/examples/dev init -backend=false`
4. `terraform -chdir=infra/blueprints/cloud-native/foundation/examples/dev validate`
5. `terraform -chdir=infra/blueprints/cloud-native/foundation/examples/dev plan`
6. 승인 후 `terraform -chdir=infra/blueprints/cloud-native/foundation/examples/dev apply`를 실행한다.
7. NKS kubeconfig를 발급받는다.
8. `blueprints/cloud-native/platform/examples/dev/terraform.tfvars.example`을 참고해 kubeconfig 경로를 설정한다.
9. `terraform -chdir=infra/blueprints/cloud-native/platform/examples/dev init`
10. `terraform -chdir=infra/blueprints/cloud-native/platform/examples/dev validate`
11. `terraform -chdir=infra/blueprints/cloud-native/platform/examples/dev plan`

운영 적용 전에는 `harness/scripts/static-check.ps1`과 plan JSON 리뷰를 수행한다.
