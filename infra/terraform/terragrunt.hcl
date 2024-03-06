remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "devops-challenge-adas-tf-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "devops-challenge-adas-tf-state"
    profile        = "aws-uwu"
  }
}

generate "provider" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
  provider "aws" {
    profile = "aws-uwu"
    region = "us-east-1"

    default_tags {
      tags = {
        Terraform = "true"
      }
    }
  }

  provider "kubernetes" {
    config_path = "~/.kube/cluster-uwu-app/kubeconfig"
  }

  provider "helm" {
    kubernetes {
      config_path = "~/.kube/cluster-uwu-app/kubeconfig"
    }
  }
  EOF
}
