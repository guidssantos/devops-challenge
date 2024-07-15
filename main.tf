terraform {
  backend "s3" {
    bucket         = "terraform-state-devops-v4"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate"
    encrypt        = true
  }
}


module "aws-prod" {
  source = "./infra"
  instance_type = "t2.micro"
  ami_id = "ami-04a81a99f5ec58529"
  key_name = "devops-challange"
  securityGroup = "aws-prod-sg"
  name = "aws-prod"
  production = true 
}