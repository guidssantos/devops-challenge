module "aws-prod" {
  source = "../../infra"
  instance_type = "t2.micro"
  ami_id = "ami-04a81a99f5ec58529"
  key_name = ""
  securityGroup = "aws-prod-sg"
  name = "aws-prod"
  production = true 
  my_ip = ""
}