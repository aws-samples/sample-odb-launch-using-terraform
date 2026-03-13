# Oracle Database@AWS — Terraform Infrastructure as Code

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.6.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-%3E%3D6.15.0-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Terraform modules and examples for deploying **Oracle Database@AWS (ODB)** infrastructure on Exadata X11M within AWS data centers.

> **Active Repository** — This repository is actively monitored and updated as the Terraform AWS provider adds new ODB features. Known provider gaps are documented below with links to tracking issues. Check back for updates or watch the repo for releases.

## Overview

Oracle Database@AWS delivers Oracle Exadata infrastructure, managed by OCI, from within AWS data centers. This repository provides reusable Terraform modules and three deployment scenarios covering the most common use cases.

### Repository Structure

```
├── modules/
│   ├── networking/       # VPC, subnets, NAT gateways, flow logs
│   └── odb/              # ODB network, peering, Exadata, VM clusters
├── examples/
│   ├── scenario1-full-deployment/        # Everything from scratch
│   ├── scenario2-existing-exadata/       # Reuse existing Exadata infra
│   └── scenario3-network-and-peering/    # VPC + ODB network + peering only
├── main.tf               # Original monolithic sample (reference)
├── variables.tf
├── outputs.tf
└── ...
```

### Deployment Scenarios

| Scenario | What it creates | Use case |
|----------|----------------|----------|
| **1 — Full Deployment** | VPC + Exadata + ODB Network + Peering + VM Cluster | Greenfield — build everything from scratch |
| **2 — Existing Exadata** | VPC + ODB Network + Peering + VM Cluster (reuses existing Exadata infra, auto-discovers DB servers) | You already have Exadata provisioned |
| **3 — Network + Peering** | VPC + ODB Network + Peering (no compute) | Pre-provision networking before deploying clusters |

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                          AWS VPC                             │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐                          │
│  │   AZ-a       │  │   AZ-b       │                          │
│  │ Public/Priv  │  │ Public/Priv  │                          │
│  │ NAT Gateway  │  │ NAT Gateway  │                          │
│  └──────────────┘  └──────────────┘                          │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │         ODB-Supported AZ (e.g., usw2-az3)              │  │
│  │                                                        │  │
│  │  ┌───────────────────────────────────────────────┐     │  │
│  │  │  ODB Network (client + backup subnets)        │     │  │
│  │  │                                               │     │  │
│  │  │  ┌──────────────────────────────────────┐     │     │  │
│  │  │  │  Exadata Infrastructure (X11M)       │     │     │  │
│  │  │  │  ├─ VM Cluster (Oracle RAC)          │     │     │  │
│  │  │  │  └─ Autonomous VM Cluster (optional) │     │     │  │
│  │  │  └──────────────────────────────────────┘     │     │  │
│  │  │                                               │     │  │
│  │  │  ODB Peering ←→ VPC                           │     │  │
│  │  └───────────────────────────────────────────────┘     │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

## Prerequisites

- **Terraform** >= 1.6.0
- **AWS CLI** >= 2.0 with valid credentials
- **AWS Provider** >= 6.15.0 (ODB resources require this minimum)
- **AWS Account** with Oracle Database@AWS enabled
- **OCI Tenancy** subscribed to the paired OCI region
- **Service Quotas**: VPCs, EIPs, NAT Gateways, IGWs (request increases if needed)

## Supported Regions

| Region | Name | ODB-Supported AZ IDs |
|--------|------|---------------------|
| `us-east-1` | US East (N. Virginia) | use1-az4, use1-az6 |
| `us-east-2` | US East (Ohio) | use2-az1, use2-az2 |
| `us-west-2` | US West (Oregon) | usw2-az3, usw2-az4 |
| `ca-central-1` | Canada (Central) | cac1-az1, cac1-az4 |
| `eu-central-1` | Europe (Frankfurt) | euc1-az1, euc1-az2 |
| `eu-west-1` | Europe (Ireland) | euw1-az3 |
| `ap-northeast-1` | Asia Pacific (Tokyo) | apne1-az1, apne1-az4 |
| `ap-southeast-2` | Asia Pacific (Sydney) | apse2-az2 |

Each scenario includes pre-built `.tfvars` files for all 8 regions.

## Quick Start

### Scenario 1 — Full Deployment

```bash
cd examples/scenario1-full-deployment
terraform init

SSH_KEY=$(cat ~/.ssh/id_ecdsa.pub)
terraform apply -var-file="us-west-2.tfvars" \
  -var="vm_cluster_ssh_public_keys=[\"${SSH_KEY}\"]"
```

### Scenario 2 — Existing Exadata

```bash
cd examples/scenario2-existing-exadata

# Edit terraform.tfvars — set existing_exadata_infra_id to your Exadata ID
terraform init

SSH_KEY=$(cat ~/.ssh/id_ecdsa.pub)
terraform apply -var-file="terraform.tfvars" \
  -var="vm_cluster_ssh_public_keys=[\"${SSH_KEY}\"]"
```

DB servers are auto-discovered from the Exadata infrastructure — no need to hardcode them.

### Scenario 3 — Network + Peering Only

```bash
cd examples/scenario3-network-and-peering
terraform init
terraform apply -var-file="terraform.tfvars"
```

### Deploy in a Different Region

Each scenario has regional `.tfvars` files. Just swap the file:

```bash
terraform apply -var-file="eu-central-1.tfvars"
terraform apply -var-file="ap-northeast-1.tfvars"
```

### Post-Apply: Add ODB Peering Routes (Required)

After `terraform apply` completes, you must manually add routes from your VPC private route tables to the ODB network. ODB peering does **not** automatically create VPC routes.

```bash
# Get outputs from Terraform
ODB_ARN=$(terraform output -raw odb_network_arn)
ODB_CIDR="<your-odb-client-subnet-cidr>"  # e.g., 172.2.0.0/24

# Add route to each private route table
for RTB in $(terraform output -json private_route_table_ids | jq -r '.[]'); do
  aws ec2 create-route \
    --route-table-id "$RTB" \
    --destination-cidr-block "$ODB_CIDR" \
    --odb-network-arn "$ODB_ARN"
done
```

See [Known Terraform Provider Gaps](#known-terraform-provider-gaps) for why this is not automated.

## Modules

### `modules/networking`

Creates a production-ready VPC with:
- Public and private subnets across 2 AZs
- NAT gateways (one per AZ)
- Internet gateway
- VPC flow logs with CloudWatch + IAM role
- Unique resource names via random suffix (avoids IAM/CloudWatch collisions across deployments)

### `modules/odb`

Creates Oracle Database@AWS resources with feature flags:

| Flag | Default | Description |
|------|---------|-------------|
| `create_exadata_infra` | `true` | Create new Exadata infrastructure |
| `create_odb_network` | `true` | Create ODB network |
| `create_peering_connection` | `true` | Create ODB peering to VPC |
| `create_vm_cluster` | `false` | Create VM cluster |
| `create_autonomous_vm_cluster` | `false` | Create Autonomous VM cluster |
| `delete_associated_oci_resources` | `false` | Delete OCI VCN when ODB network is destroyed |

When `create_exadata_infra = false`, provide `existing_exadata_infra_id`. DB servers are auto-discovered from the Exadata infrastructure via the `aws_odb_db_servers` data source.

#### ODB Network Deletion and OCI Cleanup

When you destroy an ODB network via Terraform, the associated OCI VCN (Virtual Cloud Network) is **not** deleted by default. This is controlled by the `delete_associated_oci_resources` variable:

- `false` (default) — OCI VCN and related resources remain intact after ODB network deletion
- `true` — OCI VCN and associated networking resources are cleaned up automatically

If you replace an ODB network (e.g., change CIDRs which forces recreation), the old OCI VCN from the previous ODB network will remain in your OCI tenancy unless you set `delete_associated_oci_resources = true`. The AWS Console provides a checkbox for this during manual deletion; in Terraform, use this variable.

## Known Terraform Provider Gaps

The Terraform AWS provider is actively adding ODB support, but several features are not yet available. This section tracks known gaps with links to GitHub issues. We will update the code as these are resolved.

### `aws_route` does not support `odb_network_arn` target

The EC2 API and AWS CLI support `OdbNetworkArn` / `--odb-network-arn` as a route target for directing traffic to an ODB network. However, the Terraform `aws_route` resource has not yet added this attribute.

- **Impact**: VPC routes to the ODB network cannot be created natively in Terraform. You must use the AWS CLI after `terraform apply` (see [Post-Apply: Add ODB Peering Routes](#post-apply-add-odb-peering-routes-required)).
- **Tracking**: [hashicorp/terraform-provider-aws#44672](https://github.com/hashicorp/terraform-provider-aws/issues/44672) — please +1 this issue
- **AWS CLI reference**: [aws ec2 create-route --odb-network-arn](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-route.html)
- **AWS docs**: [Configuring VPC route tables for ODB peering](https://docs.aws.amazon.com/odb/latest/UserGuide/configuring.html)

### `aws_odb_cloud_vm_cluster` documentation: `db_servers` parameter

The `db_servers` parameter accepts DB Server **IDs** (e.g., `dbs-abcdef1234`), not DB Server **names**. The provider documentation is unclear on this.

- **Tracking**: [hashicorp/terraform-provider-aws#45102](https://github.com/hashicorp/terraform-provider-aws/issues/45102)
- **Workaround**: This module auto-discovers DB server IDs via `aws_odb_db_servers` data source, so you typically don't need to set this manually.

### `aws_odb_network_peering_connection` missing Peer Network CIDRs

The `aws_odb_network_peering_connection` resource does not yet support the `peer_network_cidrs` argument. In the AWS Console and CLI, you can specify which VPC CIDR ranges are allowed to reach the ODB network (acts as a network-level ACL). This is not yet available in Terraform.

- **Tracking**: [hashicorp/terraform-provider-aws#45141](https://github.com/hashicorp/terraform-provider-aws/issues/45141)
- **Workaround**: After creating the peering via Terraform, update peer CIDRs using the AWS CLI:
  ```bash
  aws odb update-odb-peering-connection \
    --odb-peering-connection-id odbpcx-xxxx \
    --peer-network-cidrs-to-be-added "10.0.1.0/24,10.0.2.0/24"
  ```

### `aws_odb_cloud_vm_cluster` missing `system_version` argument

The Exadata Image Version (`system_version`) is not available as an input argument on `aws_odb_cloud_vm_cluster`. It is only exposed as a computed output attribute. You cannot pin or select a specific Exadata system version during VM cluster creation via Terraform.

- **Tracking**: [hashicorp/terraform-provider-aws#46880](https://github.com/hashicorp/terraform-provider-aws/issues/46880)

### VM Cluster behavioral notes

- **CPU core count (X11M)**: The default per-VM is 8 ECPUs, so a 2-node VM cluster should specify `cpu_core_count = 16` minimum.
- **Duplicate cluster names**: The provider allows creating VM clusters with duplicate `display_name` values. This is an AWS/OCI service behavior, not a Terraform bug. Use unique naming conventions (the module prepends `name_prefix`) to avoid confusion.

## Key Design Decisions

- **Random suffix on globally-unique names**: IAM roles, CloudWatch log groups, and IAM policies in the networking module get a 6-character random suffix appended. This prevents name collisions when deploying multiple scenarios in the same account.
- **Auto-discovery of DB servers**: The ODB module uses `aws_odb_db_servers` to discover AVAILABLE DB servers from the Exadata infrastructure, eliminating hardcoded server IDs.
- **Conditional Exadata lookup**: When no clusters are being created (scenario 3), the module skips the Exadata data source entirely via `local.needs_exadata`.
- **OCI cleanup on destroy**: The `delete_associated_oci_resources` flag controls whether the mapped OCI VCN is cleaned up when the ODB network is destroyed. Defaults to `false` for safety.

## IP Address Planning

| Subnet | Formula | 2 VMs | 4 VMs | 8 VMs |
|--------|---------|-------|-------|-------|
| Client | 6 + 3/cluster + 4/VM | /27 | /27 | /26 |
| Backup | 3 + 3/VM | /28 | /28 | /27 |

## Outputs

Each scenario exposes relevant outputs:

```bash
terraform output vpc_id
terraform output odb_network_id
terraform output odb_network_arn           # Needed for manual route creation
terraform output private_route_table_ids   # Route tables that need ODB routes
terraform output peering_connection_id
terraform output vm_cluster_id
terraform output vm_cluster_system_version
```

## Original Sample Code

The root-level `.tf` files (`main.tf`, `variables.tf`, `outputs.tf`, `iam.tf`, `security_groups.tf`, etc.) are the original monolithic sample from the upstream repository. They are preserved as reference. The modular approach in `modules/` and `examples/` supersedes them.

## Troubleshooting

| Error | Solution |
|-------|----------|
| No ODB routes in VPC route tables after peering | ODB peering does NOT auto-create VPC routes. Use `aws ec2 create-route --odb-network-arn` (see [Post-Apply](#post-apply-add-odb-peering-routes-required)) |
| OCI VCN remains after ODB network destroy | Set `delete_associated_oci_resources = true` in the ODB module, or delete manually from OCI Console |
| VM cluster limit reached | Max 8 clusters per Exadata (VM + Autonomous combined). Delete unused clusters or request increase from OCI |
| IAM role name collision | The networking module auto-appends a random suffix — ensure you're using the latest module version |
| Service quota exceeded (VPC, EIP, NAT, IGW) | Request increases via AWS Service Quotas console |
| `db_servers` validation error | Ensure you're passing DB Server IDs (e.g., `dbs-xxxx`), not names. The module auto-discovers these by default |

## References

- [Oracle Database@AWS User Guide](https://docs.aws.amazon.com/odb/latest/UserGuide/)
- [Configuring ODB Peering](https://docs.aws.amazon.com/odb/latest/UserGuide/configuring.html)
- [Network Connectivity Patterns for ODB@AWS](https://aws.amazon.com/blogs/database/implement-network-connectivity-patterns-for-oracle-databaseaws/)
- [Terraform AWS Provider — ODB Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/odb_network)
- [Oracle Terraform Code Samples](https://docs.oracle.com/iaas/Content/database-at-aws-exadata-awscs/awscs-code-samples-terraform.html)

## Authors

- [Sharath Chandra Kampili](https://www.linkedin.com/in/kampili/)
- [Javeed Mohammed](https://www.linkedin.com/in/javeedmohammed86/)
- [Nishanth Sodum](https://www.linkedin.com/in/nishanthsodum/)

## License

MIT — see [LICENSE](LICENSE).
