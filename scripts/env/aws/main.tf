provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.region
}

locals {
  instance_home = "/home/${var.ssh_user_name}"
  db_path = "${local.instance_home}/db"
  files_path = "${local.instance_home}/files"
}

resource "aws_instance" "service" {
  ami = var.base_image_id
  instance_type = var.instance_type
  security_groups = [aws_security_group.report_security.id]

  subnet_id = var.subnet_id
  key_name = var.ssh_key_name

  connection {
    type = "ssh"
    user = var.ssh_user_name
    private_key = file(var.private_key)
    host = self.private_ip
  }

  provisioner "file" {
    source = "${path.module}/../../../docker-compose.yaml"
    destination = "${local.instance_home}/docker-compose.yaml"
  }

  provisioner "file" {
    source = "${path.module}/../../../start.sh"
    destination = "${local.instance_home}/start.sh"
  }

  provisioner "file" {
    source = "${path.module}/../../setup.sql"
    destination = "${local.instance_home}/setup.sql"
  }

  tags = {
    Name = "${var.tag_name}-report-service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y docker && sudo service docker start",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.27.0/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
      "mkdir ${local.instance_home}/db",
      "chmod -R 777 ${local.instance_home}/db",
      "mkdir ${local.instance_home}/files",
      "chmod -R 777 ${local.instance_home}/files",
      "chmod a+x ${local.instance_home}/start.sh",
    ]
  }
}
