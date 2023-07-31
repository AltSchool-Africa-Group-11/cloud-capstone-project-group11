variable "aws_region" {
  description = "AWS provider region"
  type        = string
  default     = "us-east-1"
}
variable "aws_profile" {
  description = "AWS credentials profile name"
  type        = string
  default     = "vscode"
}
variable "vpc_information" {
  type = object({
    name     = string
    public1  = string
    public2  = string
    private1 = string
    private2 = string
  })
  description = "Value of the Name tag for the vpc and subnets"
  default = {
    name     = "tera-vpc"
    public1  = "tera-public-subnet1"
    public2  = "tera-public-subnet2"
    private1 = "tera-private-subnet1"
    private2 = "tera-private-subnet2"
  }
}

variable "key_pair" {
  description = "name of the key pair"
  type        = string
  default     = "deploy"
}

variable "bucket_name" {
  type    = string
  default = "school-terraform-state"
}

/* variable "docker_ports" {
  type = list(object({
    internal = number
    external = number
    protocol = string
  }))
  default = [
    {
      internal = 8300
      external = 8300
      protocol = "tcp"
    }
  ]
} */
/* variable "user_information" {
  type = object({
    name    = string
    address = string
  })
  sensitive = true
}

resource "some_resource" "a" {
  name    = var.user_information.name
  address = var.user_information.address
} */
