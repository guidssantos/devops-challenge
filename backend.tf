terraform {
    backend "s3" {
      bucket = "terraform-state-devops-v4"
      key = "terraform.tfstate"
      region = "us-east-1"
      dynamodb_table = "tfstate"
        encrypt        = true
    }
}