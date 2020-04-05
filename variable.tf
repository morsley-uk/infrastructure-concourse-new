variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "eu-west-2" # London
}
variable "availability_zone" {
  default = "eu-west-2a" # London
}

variable "cluster_name" {
  default = "concourse-k8s"
}

//variable "vpc_name" {
//  default = "concourse-k8s-vpc"
//}
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  default = "10.0.0.0/24"
}
