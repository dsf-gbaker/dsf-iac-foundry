packer {
  required_plugins {
    amazon = {
      version = "1.0.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "foundry-version" {
  type = string
}

variable "region" {
  type = string
}

variable "instance-type" {
  type = string
}

variable "ami-source" {
  type = string
}

variable "ssh-user" {
  type = string
}

variable "foundry-dir" {
  type = string
}

variable "group-id" {
  type = number
}

source "amazon-ebs" "foundry" {
  ami_name      = "foundry-v${var.foundry-version}"
  instance_type = "${var.instance-type}"
  region        = "${var.region}"
  source_ami    = "${var.ami-source}"
  ssh_username  = "${var.ssh-user}"
}

build {
  name = "foundry"
  sources = [
    "source.amazon-ebs.foundry"
  ]

  # set user groups
  provisioner "shell" {
    inline = [
      "sudo groupadd foundry",
      "sudo usermod -a -G foundry ${var.ssh-user}",
      "sudo groupmod -g ${var.group-id} foundry"
    ]
  }

  # install application dependencies
  provisioner "shell" {
    script = "./scripts/install-deps.sh"
  }

  # create the foundry directories
  provisioner "shell" {
    inline = [
      "echo -- Create Foundry Directory",
      "sudo mkdir -p ${var.foundry-dir}/server",
      "sudo mkdir -p ${var.foundry-dir}/data",
    ]
  }

  # set foundry dir permissions
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Tutorials.WebServerDB.CreateWebServer.html
  provisioner "shell" {
    inline = [
      "sudo chown -R ${var.ssh-user}:foundry ${var.foundry-dir}",
      "sudo chmod 2775 ${var.foundry-dir}",
      "sudo find ${var.foundry-dir} -type d -exec sudo chmod 2775 {} \\;",
      "sudo find ${var.foundry-dir} -type f -exec sudo chmod 0664 {} \\;"
    ]
  }

  /*
  # create the data directory
  provisioner "shell" {
    inline = [
      "echo -- Create Data Directory",
      "sudo mkdir ${var.data-dir}"
    ]
  }

  # set data dir permissions
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Tutorials.WebServerDB.CreateWebServer.html
  provisioner "shell" {
    inline = [
      "sudo chown -R ${var.ssh-user}:foundry ${var.data-dir}",
      "sudo chmod 2775 ${var.data-dir}",
      "sudo find ${var.data-dir} -type d -exec sudo chmod 2775 {} \\;",
      "sudo find ${var.data-dir} -type f -exec sudo chmod 0664 {} \\;"
    ]
  }
  */

  # copy the server files
  provisioner "file" {
    source      = "../../foundry/server/"
    destination = "${var.foundry-dir}/server"
  }
}
