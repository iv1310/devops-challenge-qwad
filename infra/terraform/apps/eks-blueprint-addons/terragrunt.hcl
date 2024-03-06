include {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///aws-ia/eks-blueprints-addons/aws?version=1.15.1"
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

dependency "eks" {
  config_path = "../eks"
  mock_outputs = {
    cluster_name = "cluster-namepalsudongs"
    cluster_endpoint = "cluster-endpointpalsudongs"
    oidc_provider_arn = "oidc_provider_arnpalsudongs"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name
  cluster_version = dependency.eks.outputs.cluster_version
  cluster_endpoint = dependency.eks.outputs.cluster_endpoint
  oidc_provider_arn = dependency.eks.outputs.oidc_provider_arn


  enable_aws_load_balancer_controller = true
  enable_cluster_autoscaler = true
  enable_cert_manager                    = true
  enable_kube_prometheus_stack = true
  enable_metrics_server = true
  enable_ingress_nginx = true

  cluster_autoscaler = {
    set = [
      {
        name = "autoDiscovery.clusterName",
        value = dependency.eks.outputs.cluster_name
      }
    ]
  }

  aws_load_balancer_controller = {
    set = [
      {
        name = "vpcId",
        value = dependency.vpc.outputs.vpc_id
      },
      {
        name = "podDisruptionBudget.maxUnavailable",
        value = "1"
      },
      {
        name = "resources.requests.cpu",
        value = "100m"
      },
      {
        name = "resources.requests.memory",
        value = "128Mi"
      },
      {
        name = "clusterName",
        value = dependency.eks.outputs.cluster_name
      },
      {
        name = "serviceAccount.name",
        value = "aws-load-balancer-controller-sa"
      },
      {
        name = "autoDiscoverAwsRegion",
        value = true
      },
      {
        name  = "autoDiscoverAwsVpcID",
        value = true
      }
    ]
  }

  ingress_nginx = {
    name = "ingress-nginx"
    chart_version = "4.6.1"
    repository = "https://kubernetes.github.io/ingress-nginx"
    namespace = "ingress-nginx"
    values = ["${file("values-ingress.yaml")}"]
  }

  kube_prometheus_stack = {
    name = "kube-prometheus-stack"
    chart_version = "51.2.0"
    repository = "https://prometheus-community.github.io/helm-charts"
    namespace = "monitoring"
    values = ["${file("values-mon.yaml")}"]
  }

  metrics_server = {
    name = "metrics-server"
    chart_version = "3.10.0"
    repository = "https://kubernetes-sigs.github.io/metrics-server/"
    namespace = "kube-system"
    values = ["${file("values-metrics.yaml")}"]
  }
}
