#    _____             _         _____ ____  
#   |  __ \           | |       | ____|___ \ 
#   | |__) |___  _   _| |_ ___  | |__   __) |
#   |  _  // _ \| | | | __/ _ \ |___ \ |__ < 
#   | | \ \ (_) | |_| | ||  __/  ___) |___) |
#   |_|  \_\___/ \__,_|\__\___| |____/|____/ 
#

# concourse.morsley.io

data "aws_route53_zone" "morsley-io" {

  name         = var.domain
  private_zone = false

}

data "aws_s3_bucket_object" "node-public-ip" {

  bucket = local.bucket_name
  key    = "/${var.cluster_name}/node_public_ip.txt"

}

resource "aws_route53_record" "a-record" {

  zone_id = data.aws_route53_zone.morsley-io.zone_id
  name    = var.subdomain
  type    = "A"
  ttl     = 300
  records = [data.aws_s3_bucket_object.node-public-ip.body]

}

output "route_53_name_servers" {
  value = data.aws_route53_zone.morsley-io.name_servers
}