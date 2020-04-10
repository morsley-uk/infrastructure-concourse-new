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

  domain    = "morsley.io"
  subdomain = "concourse"

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

# Using Helm install Concourse on the previously created Kubernetes cluster...
resource "null_resource" "install-concourse" {

  depends_on = [
    aws_ebs_volume.worker-ebs,
    aws_ebs_volume.postgresql-ebs,
    module.kubernetes-cluster #,
    #null_resource.is-istio-ready
  ]

  # https://www.terraform.io/docs/provisioners/local-exec.html

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/install_concourse.sh"
    environment = {
      FOLDER          = local.folder
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
      FOLDER    = local.folder
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
      FOLDER    = local.folder
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
      FOLDER    = local.folder
      NAMESPACE = "cert-manager"
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
      FOLDER    = local.folder
      NAMESPACE = "cert-manager"
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
    command = "bash ${path.module}/scripts/install_lets_encrypt.sh"
    environment = {
      FOLDER    = local.folder
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
      FOLDER    = local.folder
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