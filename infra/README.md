# NHN Cloud Terraform Project

이 디렉터리는 NHN Cloud 표준 아키텍처를 Terraform으로 구성하기 위한 코드 골격이다.

## Stack 구분

| Stack | 경로 | 역할 |
|---|---|---|
| Cloud foundation | `envs/dev` | VPC, subnet, security group, object storage, NKS |
| Kubernetes platform | `platform/dev` | NKS 내부 namespace, StorageClass, Argo CD, cert-manager 등 |

## 실행 순서

1. NHN Cloud 콘솔에서 API Endpoint, keypair, external network/subnet, quota를 확인한다.
2. `envs/dev/terraform.tfvars.example`을 참고해 로컬 `terraform.tfvars`를 만든다.
3. `terraform -chdir=infra/envs/dev init -backend=false`
4. `terraform -chdir=infra/envs/dev plan`
5. 승인 후 `terraform -chdir=infra/envs/dev apply`
6. NKS kubeconfig를 발급받는다.
7. `platform/dev/terraform.tfvars.example`을 참고해 kubeconfig 경로를 설정한다.
8. `terraform -chdir=infra/platform/dev init`
9. `terraform -chdir=infra/platform/dev plan`

운영 적용 전에는 `harness/scripts/static-check.ps1`과 plan JSON 리뷰를 수행한다.

