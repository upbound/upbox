variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "instance_type" {
  type    = string
  default = "t4g.micro"
}

variable "ami_name" {
  type    = string
  default = "upbox-{{timestamp}}"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

source "amazon-ebs" "upbox" {
  region     = var.aws_region

  source_ami_filter {
    filters = {
      "virtualization-type" = "hvm"
      "name"                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"
      "root-device-type"    = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  instance_type = var.instance_type
  ssh_username  = var.ssh_username
  ami_name      = var.ami_name

  # copy to eu region additionally
  ami_regions   = ["eu-west-1"]

  # share with deployment account
  ami_users     = ["609897127049"]


  tags = {
    Name      = "Upbox"
    CreatedBy = "Packer"
  }
}

build {
  sources = ["source.amazon-ebs.upbox"]

  provisioner "file" {
    source      = "./authorized_keys"
    destination = "/tmp/authorized_keys"
  }

  provisioner "file" {
    source      = "./setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "SSH_USER=ubuntu",
      "UP_CLI_VERSION=v0.39.0",
      "XP_CLI_VERSION=v1.19.1",

      "DOCKER_VERSION=5:28.0.4-1~ubuntu.24.04~noble",
      "CONTAINERD_VERSION=1.7.27-1",
      "KUBECTL_VERSION=v1.32.3",
      "NODE_VERSION=22",
      "CLAUDE_CODE_VERSION=latest"
    ]

    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo -E /tmp/setup.sh ${var.ssh_username}",
      "rm /tmp/setup.sh"
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
