#Security Group pour Management BIG-IP

resource "aws_security_group" "BIG_IP" {
  name   = "${var.user_id}_f5_Mngt_BIG_IP"
  vpc_id = aws_vpc.vpc_lab.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.restrictedMgmtAddress}","${var.bigiq_Mngt_IP}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.restrictedSrcAddress
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${var.restrictedMgmtAddress}","${var.bigiq_Mngt_IP}/32"]
  }


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_lab_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "${var.user_id}_f5_Mngt_bigIP"
  }
}


#####################
#
# Creation of external and internal interfaces for each bigip1
# The tags associated to the external interfaces must be the same ones than the tags defined in the CFE setup
#
#####################

resource "aws_network_interface" "external_int_bigip1" {
    subnet_id = aws_subnet.external_bigip.id
    private_ips = ["${var.external_selfip_bigip1}","${var.IP_VS_1}"]
    attachment {
        instance = aws_instance.bigip1.id
        device_index = 1
    }

    security_groups = [aws_security_group.BIG_IP.id]

    tags = {
        Name			 = "External Interface BIGIP 1"
        owner			 = "${var.user_id}"
        f5_cloud_failover_label  = "${var.cfe_label}"
        f5_cloud_failover_nic_map = "external"
    }
}

resource "aws_network_interface" "internal_int_bigip1" {
    depends_on = [aws_network_interface.external_int_bigip1]
    subnet_id = aws_subnet.internal_bigip.id
    private_ips = ["${var.internal_selfip_bigip1}"]
    attachment {
        instance = aws_instance.bigip1.id
        device_index = 2
    }

   tags = {
        Name   = "Internal Interface BIGIP 1"
        owner  = "${var.user_id}"
   }
}


resource "aws_network_interface" "external_int_bigip2" {
    subnet_id = aws_subnet.external_bigip.id
    private_ips = ["${var.external_selfip_bigip2}"]
    attachment {
        instance = aws_instance.bigip2.id
        device_index = 1
    }
   
    security_groups = [aws_security_group.BIG_IP.id]
 
    tags = {
        Name                     = "External Interface BIGIP 2"
        owner                    = "${var.user_id}"
        f5_cloud_failover_label = "${var.cfe_label}"
        f5_cloud_failover_nic_map = "external"
    }
}


resource "aws_network_interface" "internal_int_bigip2" {
    depends_on = [aws_network_interface.external_int_bigip2]
    subnet_id = aws_subnet.internal_bigip.id
    private_ips = ["${var.internal_selfip_bigip2}"]
    attachment {
        instance = aws_instance.bigip2.id
        device_index = 2
    }

   tags = {
        Name   = "Internal Interface BIGIP 2"
        owner  = "${var.user_id}"
   }
}



#####################
#
# Creation of 1 EIP for the VS. Only usefule in case the VS must be public.
# The EIP for the management of each bigip are directlty created and associated into the instance declaration
#
#####################


resource "aws_eip" "eip_vs" {
  vpc                       = true
#  network_interface         = aws_network_interface.external_int_bigip1.id

  tags  = {
      Name   = "${var.user_id}_EIP-VS-Terraform"
      owner  = "${var.user_id}"
    }
}


resource "aws_eip_association" "eip_vs" {
  
  allocation_id 	= aws_eip.eip_vs.id
  allow_reassociation   = true
  network_interface_id  = aws_network_interface.external_int_bigip1.id
  private_ip_address 	= var.IP_VS_1 

}




data "aws_eip" "eip_vs" {

  filter {
    name   = "tag:owner"
    values = ["${var.user_id}"]

  }

 depends_on = [aws_eip.eip_vs]
}



####################
#
# Configuration of the Cloudinit file for the installation of the F5 toolchain
#
####################

data "template_file" "cloud_init_template" {
  template = "${file("${path.module}/cloudinit_install_tool_chain.yaml")}"

  vars = {
    do_repo_url          = var.do_repo_url
    as3_repo_url         = var.as3_repo_url
    ts_repo_url          = var.ts_repo_url
    cfe_repo_url         = var.cfe_repo_url
  }

}

data "template_cloudinit_config" "install_tool_chain" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloud_init_template.rendered}"
  }
}




####################
#
# Creation of the two BIGIP instances 
# Management IP with its attached EIP are directly declared into the definition
# Cloudinit is used for the toolchain installation
# The IAM Role is attached for CFE 
# 
####################


resource "aws_instance" "bigip1" {

    availability_zone = "${var.aws_region}a"

# AMI 15.0.1 BEST 25 Mbps PAYG in Paris eu-west-3
    ami = "ami-0d5ed4812e96ef2fd"
    
    instance_type = "m5.2xlarge"

    vpc_security_group_ids = [aws_security_group.BIG_IP.id]

    subnet_id = aws_subnet.management.id

    key_name = var.aws_keypair

    associate_public_ip_address = true

    private_ip = var.management_bigip1

#For CFE
#    iam_instance_profile = "aws_iam_instance_profile.profile_cfe.${var.user_id}_profile_cfe"
    iam_instance_profile = "${var.user_id}_profile_cfe"
    depends_on = [aws_iam_instance_profile.profile_cfe]

    tags = {
      Name           = "${var.user_id}_BIGIP_1-Terraform"
      owner          = "${var.user_id}"
    }

user_data = data.template_cloudinit_config.install_tool_chain.rendered
}



resource "aws_instance" "bigip2" {

    availability_zone = "${var.aws_region}a"

# AMI 15.0.1 BEST 25 Mbps PAYG in Paris eu-west-3
    ami = "ami-0d5ed4812e96ef2fd"

    instance_type = "m5.2xlarge"

    vpc_security_group_ids = [aws_security_group.BIG_IP.id]

    subnet_id = aws_subnet.management.id

    key_name = var.aws_keypair
    
    associate_public_ip_address = true
    
    private_ip = var.management_bigip2 

#For CFE
#    iam_instance_profile = "aws_iam_instance_profile.profile_cfe.${var.user_id}_profile_cfe"
    iam_instance_profile = "${var.user_id}_profile_cfe"
    depends_on = [aws_iam_instance_profile.profile_cfe]


    tags = {
      Name           = "${var.user_id}_BIGIP_2-Terraform"
      owner	     = "${var.user_id}"
    }
user_data = data.template_cloudinit_config.install_tool_chain.rendered
}


data "aws_instance" "bigip1" {

  filter {
    name   = "tag:Name"
    values = ["${var.user_id}_BIGIP_1-Terraform"]
  }
 
 depends_on = [aws_instance.bigip1]
 
}


data "aws_instance" "bigip2" {

  filter {
    name   = "tag:Name"
    values = ["${var.user_id}_BIGIP_2-Terraform"]
  }

 depends_on = [aws_instance.bigip2]

}



#####################
#
# Initialisation of the BIGIPS : Admin PWD and Disable DHCP (bug https://github.com/F5Networks/f5-declarative-onboarding/issues/129)
#
#####################


resource "null_resource" "system_init_bigip1" {

  provisioner "local-exec" {

  command = "ansible-playbook --user ${var.admin_user} --private-key ${var.private_key_path} ./PlayBook_Ansible_Reset_Pwd.yml -e \"bigip_ip=${data.aws_instance.bigip1.public_ip}\" -i ${data.aws_instance.bigip1.public_ip},"

  }

  depends_on = [aws_instance.bigip1]

}


resource "null_resource" "system_init_bigip2" {

  provisioner "local-exec" {

  command = "ansible-playbook --user ${var.admin_user} --private-key ${var.private_key_path} ./PlayBook_Ansible_Reset_Pwd.yml -e \"bigip_ip=${data.aws_instance.bigip2.public_ip}\" -i ${data.aws_instance.bigip2.public_ip},"

  }

  depends_on = [aws_instance.bigip2]

}


###################
# 
# Send DO Declaration with DSC setup 
#
####################


resource "null_resource" "send_DO_declaration_bigip1" {

  provisioner "local-exec" {

  command = "ansible-playbook ./PlayBook_Ansible_DO.yml -e \"bigip=${data.aws_instance.bigip1.public_ip}\" -e host=${var.host1} -e timezone=${var.timezone} -e internal_self=${var.internal_selfip_bigip1} -e external_self=${var.external_selfip_bigip1} -e banner_color=${var.color_bigip1} -e banner_advisory=${var.advisory_bigip1} -e member_1=${data.aws_instance.bigip1.private_ip} -e member_2=${data.aws_instance.bigip2.private_ip} -e remote_host=${data.aws_instance.bigip2.private_ip} -i ${data.aws_instance.bigip1.public_ip},"

  }

  depends_on = [null_resource.system_init_bigip1]

}



resource "null_resource" "send_DO_declaration_bigip2" {

  provisioner "local-exec" {

  command = "ansible-playbook ./PlayBook_Ansible_DO.yml -e \"bigip=${data.aws_instance.bigip2.public_ip}\" -e host=${var.host2} -e timezone=${var.timezone} -e internal_self=${var.internal_selfip_bigip2} -e external_self=${var.external_selfip_bigip2} -e banner_color=${var.color_bigip2} -e banner_advisory=${var.advisory_bigip2} -e member_1=${data.aws_instance.bigip1.private_ip} -e member_2=${data.aws_instance.bigip2.private_ip} -e remote_host=${data.aws_instance.bigip1.private_ip} -i ${data.aws_instance.bigip2.public_ip},"

  }

  depends_on = [null_resource.system_init_bigip2]

}




###################@
# Send CFE Declaration
####################


resource "null_resource" "send_CFE_declaration_bigip1" {

  provisioner "local-exec" {

  command = "ansible-playbook --user ${var.admin_user} --private-key ${var.private_key_path} ./PlayBook_Ansible_CFE.yml -e \"bigip=${data.aws_instance.bigip1.public_ip}\" -e host=${var.host1} -e label=${var.cfe_label} -e ext_self_bigip1=${var.external_selfip_bigip1} -e ext_self_bigip2=${var.external_selfip_bigip2} -e log_level=silly -i ${data.aws_instance.bigip1.public_ip},"
  }

  depends_on = [null_resource.send_DO_declaration_bigip1]

}


resource "null_resource" "send_CFE_declaration_bigip2" {

  provisioner "local-exec" {

  command = "ansible-playbook --user ${var.admin_user} --private-key ${var.private_key_path} ./PlayBook_Ansible_CFE.yml -e \"bigip=${data.aws_instance.bigip2.public_ip}\" -e host=${var.host2} -e label=${var.cfe_label} -e ext_self_bigip1=${var.external_selfip_bigip1} -e ext_self_bigip2=${var.external_selfip_bigip2} -e log_level=silly -i ${data.aws_instance.bigip2.public_ip},"

  }

  depends_on = [null_resource.send_DO_declaration_bigip2]

}



#####################
#
# Send AS3 Declaration which includes a WAF Policy
#
####################


resource "null_resource" "AS3_Declaration" {

  provisioner "local-exec" {

  command = "ansible-playbook ./PlayBook_Ansible_AS3.yml -e \"bigip=${data.aws_instance.bigip1.public_ip}\" -e Tenant_Name=Team_A -e App_Name=WebApp -e VIP=${var.IP_VS_1} -e Region=${var.aws_region} -i ${data.aws_instance.bigip1.public_ip},"


  }

  depends_on = [null_resource.send_CFE_declaration_bigip1,null_resource.send_CFE_declaration_bigip2]

}



#####################
#
# Output some Values after the deployment 
#
#####################


output "Public_IP_Management_BIGIP_1" {
    value = "${data.aws_instance.bigip1.public_ip}"
  depends_on = [aws_instance.bigip1]
}


output "Public_IP_Management_BIGIP_2" {
    value = "${data.aws_instance.bigip2.public_ip}"
 depends_on = [aws_instance.bigip2] 
}


output "Public_IP_For_VS" {
    value = "${data.aws_eip.eip_vs.public_ip}"
 depends_on = [aws_eip.eip_vs]
}


output "Private_IP_for_VS" {
    value = "${var.IP_VS_1}"
}
