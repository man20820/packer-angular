variable "ami_id" {
  type    = string
  default = "ami-01855c90f88c94d7c"
}

locals {
  app_name = "angular-node"
}

source "amazon-ebs" "node" {
  ami_name      = "packer-${local.app_name}"
  instance_type = "t3.micro"
  region        = "ap-southeast-3"
  source_ami    = "${var.ami_id}"
  ssh_username  = "ubuntu"
  tags = {
    Env  = "dev"
    Name = "packer-${local.app_name}"
  }
}

build {

  sources = ["source.amazon-ebs.node"]

  provisioner "shell" {
    script = "deployments/node-pre.sh"
  }

  provisioner "file" {
    source      = "angular/"
    destination = "/usr/share/workspace/"
  }

  provisioner "shell" {
    script = "deployments/nginx-pre.sh"
  }

  provisioner "file" {
    source      = "deployments/nginx.conf"
    destination = "/usr/share/workspace/nginx.conf"
  }

  provisioner "shell" {
    script = "deployments/nginx-post.sh"
  }

  provisioner "shell" {
    script = "deployments/node-post.sh"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}