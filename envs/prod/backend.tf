terraform {
  backend "s3" {
    bucket         = "customer-feedback-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
  }
}
