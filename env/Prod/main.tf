module "aws-prod" {
  source = "../../infra"
  instance_type = "t2.micro"
  ami_id = "ami-0b72821e2f351e396"
  key_name = "devops-challange"
  securityGroup = "aws-prod-sg"
  name = "aws-prod"
  production = true 
  my_ip = ""
}