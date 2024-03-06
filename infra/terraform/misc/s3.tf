module "store-state" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.5.0"

  bucket = "devops-challenge-adas-tf-state"
  tags = {
    Terraform = "true"
  }
}

