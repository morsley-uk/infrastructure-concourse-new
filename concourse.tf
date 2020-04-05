#     _____                                          
#    / ____|                                         
#   | |     ___  _ __   ___ ___  _   _ _ __ ___  ___ 
#   | |    / _ \| '_ \ / __/ _ \| | | | '__/ __|/ _ \
#   | |___| (_) | | | | (_| (_) | |_| | |  \__ \  __/
#    \_____\___/|_| |_|\___\___/ \__,_|_|  |___/\___|
#                                                   

# Create a Kubernetes cluster for Concourse...
module "kubernetes-cluster" {

  #source  = "john-morsley/kubernetes-cluster/aws"
  #version = "0.0.1"

  source = "../terraform-aws-kubernetes-cluster"

  region = var.region

  cluster_name = var.cluster_name

  #vpc_name = var.vpc_name
  vpc_cidr_block = var.vpc_cidr_block

  public_subnet_cidr_block = var.public_subnet_cidr_block
  availability_zone        = var.availability_zone

  domain = "morsley.io"

}

locals {

  bucket_name = replace(var.domain, ".", "-")

  #key_name = replace("${var.region}_${var.cluster_name}", ".", "_")

  #cluster_id = "kubernetes.io/cluster/${var.cluster_name}"

}

data "aws_s3_bucket_object" "kube-config-yaml" {

  bucket = local.bucket_name
  key    = "/${var.cluster_name}/kube_config.yaml"

}

resource "local_file" "kube-config-yaml" {

  content  = data.aws_s3_bucket_object.kube-config-yaml.body
  filename = "${path.cwd}/${var.cluster_name}/kube_config.yaml"

}

# Concourse needs 2 AWS EBS...
resource "aws_ebs_volume" "worker-ebs" {

  availability_zone = var.availability_zone
  size              = var.worker_storage_size

  tags = {
    Name = "worker-storage-ebs"
  }

}

resource "local_file" "worker-persistent-volume-0-yaml" {

  content  = templatefile("${path.cwd}/k8s/worker-persistent-volume-0.yaml", { VOLUME_ID = aws_ebs_volume.worker-ebs.id })
  filename = "${path.cwd}/${var.cluster_name}/worker-persistent-volume-0.yaml"

}

resource "local_file" "worker-persistent-volume-1-yaml" {

  content  = templatefile("${path.cwd}/k8s/worker-persistent-volume-1.yaml", { VOLUME_ID = aws_ebs_volume.worker-ebs.id })
  filename = "${path.cwd}/${var.cluster_name}/worker-persistent-volume-1.yaml"

}

resource "aws_ebs_volume" "postgresql-ebs" {

  availability_zone = var.availability_zone
  size              = var.postgresql_storage_size

  tags = {
    Name = "postgresql-storage-ebs"
  }

}

resource "local_file" "postgresql-persistent-volume-0-yaml" {

  content  = templatefile("${path.cwd}/k8s/postgresql-persistent-volume-0.yaml", { VOLUME_ID = aws_ebs_volume.postgresql-ebs.id })
  filename = "${path.cwd}/${var.cluster_name}/postgresql-persistent-volume-0.yaml"

}

# Using Helm install Concourse on the previously created Kubernetes cluster...
resource "null_resource" "install-concourse" {

  depends_on = [
    aws_ebs_volume.worker-ebs,
    aws_ebs_volume.postgresql-ebs,
    data.aws_s3_bucket_object.kube-config-yaml
  ]

  # https://www.terraform.io/docs/provisioners/local-exec.html

  provisioner "local-exec" {
    command = "chmod +x scripts/install_concourse.sh && bash scripts/install_concourse.sh"
    environment = {
      FOLDER    = "${var.cluster_name}"
      NAME      = "${var.cluster_name}"
      NAMESPACE = "${var.cluster_name}"
    }
  }

}