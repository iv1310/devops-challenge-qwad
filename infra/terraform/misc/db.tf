module "dynamodb" {
  source = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 3.1.1"

  name = "devops-challenge-adas-tf-state"
  hash_key = "LockID"
  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]
  tags = {
    Terraform = "true"
  }
}
