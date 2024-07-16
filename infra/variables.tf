variable "aws_region" {
    type = string
    default = "us-east-1"
}

variable "instance_type" {              
    type = string
    default = "t2.micro"  
}

variable "ami_id" {              
    type = string
    # default = ""  
}

# variable "my_ip" {   
#     type = string
# }

variable "key_name" {   
    type = string
}

variable "securityGroup" {   
    type = string
}

variable "name" {   
    type = string
}

