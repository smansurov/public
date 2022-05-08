variable "vpc_region" {
  default = "us-east-1"
}

variable "vpc_name" {
  default = "vpc-one"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_subnet" {
  type = list
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "vpc_subnet_type" {
  type = list
  default = ["public", "private"]
}