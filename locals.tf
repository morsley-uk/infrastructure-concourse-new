locals {

  bucket_name = replace(var.domain, ".", "-")

  folder = replace("${var.domain}-${var.subdomain}-files", ".", "-")

}