variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "eu-west-2" # London
}
variable "availability_zone" {
  default = "eu-west-2a" # London
}

variable "domain" {
  default = "morsley.io"
}

variable "subdomain" {
  default = "concourse"
}

variable "cluster_name" {
  default = "concourse-k8s"
}

variable "namespace" {
  default = "concourse"
}

variable "cert_manager_namespace" {
  default = "cert-manager"
}

variable "deployment_name" {
  default = "concourse"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  default = "10.0.0.0/24"
}

variable "worker_storage_size" {
  default = 20 # In GiBs
}

variable "postgresql_storage_size" {
  default = 10 # In GiBs
}