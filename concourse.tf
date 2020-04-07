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

data "aws_s3_bucket_object" "kube-config-yaml" {

  depends_on = [module.kubernetes-cluster]
  
  bucket = local.bucket_name
  key    = "/${var.cluster_name}/kube_config.yaml"

}

resource "local_file" "kube-config-yaml" {

  depends_on = [module.kubernetes-cluster]
  
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

# Install Istio...

resource "null_resource" "install-istio" {

  depends_on = [
    module.kubernetes-cluster
  ]
  # https://www.terraform.io/docs/provisioners/local-exec.html

  provisioner "local-exec" {
    command = "chmod +x scripts/install_istio.sh && bash scripts/install_istio.sh"
    environment = {
      FOLDER = local.folder
    }
  }

}

# Is Istio ready...?

resource "null_resource" "is-istio-ready" {

  depends_on = [
    null_resource.install-istio
  ]

  # https://www.terraform.io/docs/provisioners/local-exec.html

  provisioner "local-exec" {
    command = "chmod +x scripts/is_istio_ready.sh && bash scripts/is_istio_ready.sh"
    environment = {
      FOLDER = local.folder
    }
  }

}

# Using Helm install Concourse on the previously created Kubernetes cluster...

resource "null_resource" "install-concourse" {

  depends_on = [
    aws_ebs_volume.worker-ebs,
    aws_ebs_volume.postgresql-ebs,
    module.kubernetes-cluster,
    null_resource.is-istio-ready
  ]

  # https://www.terraform.io/docs/provisioners/local-exec.html

  provisioner "local-exec" {
    command = "chmod +x ${path.module}/scripts/install_concourse.sh && bash ${path.module}/scripts/install_concourse.sh"
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
    command = "chmod +x scripts/is_concourse_ready.sh && bash scripts/is_concourse_ready.sh"
    environment = {
      FOLDER = local.folder
    }
  }

}

//module "route53" {
//
//  source = "../terraform-aws-kubernetes-cluster/modules/route53"
//
//  domain = var.domain
//  subdomain = var.subdomain
//  public_ip = module.kubernetes-cluster.public_ip
//  
//}