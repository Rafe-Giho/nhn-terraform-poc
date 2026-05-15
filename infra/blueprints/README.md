# Terraform Blueprints

이 디렉터리는 팀 표준 아키텍처를 사업별로 복사해서 시작할 수 있는 Terraform blueprint로 제공한다.

| Blueprint | 경로 | 용도 |
|---|---|---|
| IaaS 3-tier | `iaas-3tier/examples/dev` | Web/WAS/DB VM 전환 구조 |
| Cloud-native foundation | `cloud-native/foundation/examples/dev` | VPC, Object Storage, NKS |
| Cloud-native platform | `cloud-native/platform/examples/dev` | NKS 내부 namespace, StorageClass, Helm add-on |

`modules/`는 직접 실행하지 않는다. 실행은 항상 blueprint의 example 디렉터리에서 수행한다.
