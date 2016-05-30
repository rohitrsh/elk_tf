# Provider details
provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.aws_region}"
}

# Default security group to access
resource "aws_security_group" "default" {
    name = "ELK_Example"
    description = "Used in ELK Stack"

    # Access from any wheree - Just for demo script not Prod servers
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # outbound internet access
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Elasticsearch node provisioning Using teraform
resource "aws_instance" "ElasticSearch" {
  instance_type = "t1.micro"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.default.name}"]
  source_dest_check = false
  tags = { 
    Name = "ELK_ES_Node_01"
  }
  connection {
    user = "ec2-user"
    key_file = "ssh/ELK_AWS_KP.pem"
  }
provisioner "file" {
      source = "scripts/ES_Install.sh"
      destination = "/tmp/"
  } 
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x ES_Install.sh",
      "sudo sh /tmp/ES_Install.sh"
    ]
  }
}

# Logstash node provisioning Using teraform
resource "aws_instance" "LogStash" {
  instance_type = "t1.micro"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.default.name}"]
  source_dest_check = false
  tags = { 
    Name = "ELK_LS_Node_01"
  }
  connection {
    user = "ec2-user"
    key_file = "ssh/ELK_AWS_KP.pem"
  }
provisioner "file" {
      source = "scripts/LS_Install.sh"
      destination = "/tmp/"
  } 
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x LS_Install.sh",
      "sudo sh /tmp/LS_Install.sh"
    ]
  }
}

# Kibana node provisioning Using teraform
resource "aws_instance" "Kibana" {
  instance_type = "t1.micro"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.default.name}"]
  source_dest_check = false
  tags = { 
    Name = "ELK_KB_Node_01"
  }
  connection {
    user = "ec2-user"
    key_file = "ssh/ELK_AWS_KP.pem"
  }
provisioner "file" {
      source = "scripts/KB_Install.sh"
      destination = "/tmp/"
  } 
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x KB_Install.sh",
      "sudo sh /tmp/KB_Install.sh"
    ]
  }
}