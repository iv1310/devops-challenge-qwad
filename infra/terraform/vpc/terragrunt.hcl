include {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.5.1"
}

locals {
  common_vars   = read_terragrunt_config(find_in_parent_folders("common_vars.hcl"))
  name = local.common_vars.locals.name
  cidr = local.common_vars.locals.cidr
  private_subnets = local.common_vars.locals.private_subnets
  public_subnets = local.common_vars.locals.public_subnets
  azs = local.common_vars.locals.azs
}

inputs = {
  name = "${local.name}-vpc"
  cidr = local.cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  single_nat_gateway = true
  enable_nat_gateway = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}-cluster" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}-vluster" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
