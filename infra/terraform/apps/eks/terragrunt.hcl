include {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=20.4.0"
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common_vars.hcl"))
  name = local.common_vars.locals.name
  instance_type = local.common_vars.locals.instance_type
}

dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    vpc_id = "vcp-idpalsudongs"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  cluster_name = "${local.name}-cluster"
  cluster_version = "1.28"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets
  control_plane_subnet_ids = dependency.vpc.outputs.private_subnets

  eks_managed_node_groups = {
    worker = {
      min_size = 1
      max_size = 4
      desired_size = 2

      instance_type = [local.instance_type]
      capacity_type = "SPOT"

      tags = {
        "k8s.io/cluster-autoscaler/enabled"                  = "true"
        "k8s.io/cluster-autoscaler/${local.name}-cluster"    = "owned"
      }
    }
  }

  enable_cluster_creator_admin_permissions = true
}
