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

  vpc_cidr_block = var.vpc_cidr_block

  public_subnet_cidr_block = var.public_subnet_cidr_block
  availability_zone        = var.availability_zone

  domain    = var.domain
  subdomain = var.subdomain

  folder = local.folder

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
  filename = "${local.folder}/worker-persistent-volume-0.yaml"

}

resource "local_file" "worker-persistent-volume-1-yaml" {

  content  = templatefile("${path.cwd}/k8s/worker-persistent-volume-1.yaml", { VOLUME_ID = aws_ebs_volume.worker-ebs.id })
  filename = "${local.folder}/worker-persistent-volume-1.yaml"

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
  filename = "${local.folder}/postgresql-persistent-volume-0.yaml"

}

# https://www.terraform.io/docs/providers/random/r/password.html

resource "random_password" "admin-password" {

  length = 25

  lower = true
  min_lower = 5
  upper = true
  min_upper = 5
  number = true
  min_numeric = 5
  special = true
  min_special = 3

}

# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html

resource "aws_s3_bucket_object" "admin-password-txt" {

  bucket  = local.bucket_name
  key     = "/${var.cluster_name}/admin_password.txt"
  content = random_password.admin-password.result
  content_type = "text/*"

}

# Install Concourse on the above Kubernetes cluster...
resource "null_resource" "install-concourse" {

  depends_on = [
    aws_ebs_volume.worker-ebs,
    aws_ebs_volume.postgresql-ebs,
    module.kubernetes-cluster
  ]

  # https://www.terraform.io/docs/provisioners/local-exec.html

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/install_concourse.sh"
    environment = {
      FOLDER          = "${path.cwd}/${local.folder}"
      DEPLOYMENT_NAME = var.deployment_name
      NAMESPACE       = var.namespace
    }
  }

}

# Is Concourse ready...?
resource "null_resource" "is-concourse-ready" {

  depends_on = [
    null_resource.install-concourse
  ]

  # https://www.terraform.io/docs/provisioners/local-exec.html

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/is_concourse_ready.sh"
    environment = {
      FOLDER    = "${path.cwd}/${local.folder}"
      NAMESPACE = var.namespace
    }
  }

}

# Ingress...
resource "null_resource" "concourse-ingress" {

  depends_on = [
    null_resource.is-concourse-ready
  ]

  # https://www.terraform.io/docs/provisioners/local-exec.html

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/concourse_ingress.sh"
    environment = {
      FOLDER    = "${path.cwd}/${local.folder}"
      NAMESPACE = var.namespace
    }
  }

}

# Install Cert-Manager...
resource "null_resource" "install-cert-manager" {

  depends_on = [
    null_resource.is-concourse-ready,
    null_resource.concourse-ingress
  ]

  # https://www.terraform.io/docs/provisioners/local-exec.html

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/install_cert_manager.sh"
    environment = {
      FOLDER    = "${path.cwd}/${local.folder}"
      NAMESPACE = var.cert_manager_namespace
    }
  }

}

# Is Cert-Manager ready...?
resource "null_resource" "is-cert-manager-ready" {

  depends_on = [
    null_resource.install-cert-manager
  ]

  # https://www.terraform.io/docs/provisioners/local-exec.html

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/is_cert_manager_ready.sh"
    environment = {
      FOLDER    = "${path.cwd}/${local.folder}"
      NAMESPACE = var.cert_manager_namespace
    }
  }

}

# Let's Encrypt...
resource "null_resource" "lets-encrypt" {

  depends_on = [
    null_resource.is-cert-manager-ready,
    null_resource.concourse-ingress
  ]

  # https://www.terraform.io/docs/provisioners/local-exec.html

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/lets_encrypt.sh"
    environment = {
      FOLDER    = "${path.cwd}/${local.folder}"
      NAMESPACE = var.namespace
    }
  }

}

# Is Let's Encrypt ready...?
resource "null_resource" "is-lets-encrypt-ready" {

  depends_on = [
    null_resource.lets-encrypt
  ]

  # https://www.terraform.io/docs/provisioners/local-exec.html

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/is_lets_encrypt_ready.sh"
    environment = {
      FOLDER    = "${path.cwd}/${local.folder}"
      NAMESPACE = var.namespace
    }
  }

}

# Configure Route53...
module "route53" {
  
  source = "../terraform-aws-kubernetes-cluster/modules/route53"

  domain    = var.domain
  subdomain = var.subdomain
  public_ip = module.kubernetes-cluster.public_ip

}