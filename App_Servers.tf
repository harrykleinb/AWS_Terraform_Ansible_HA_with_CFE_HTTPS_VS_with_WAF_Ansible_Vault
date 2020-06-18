#Security Group for AppServers

resource "aws_security_group" "AppServers" {
  name   = "${var.user_id}_AppServers"
  vpc_id = aws_vpc.vpc_lab.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_lab_cidr}","86.242.11.19/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name  = "${var.user_id}_AppServers_SG"
    owner = "${var.user_id}"
  }

}


resource "aws_launch_configuration" "web_conf" {
  name                        = "web_config"
  image_id                    = "ami-07f0057f4527a40ad"
  instance_type               = var.ws_size
  key_name                    = var.aws_keypair
  security_groups             = [aws_security_group.AppServers.id] 
  user_data                   = file("install_arcadia.sh")

  #modify to true in case you need to connect directlty to the servers
  associate_public_ip_address = false
}


resource "aws_autoscaling_group" "web_asg" {
  name                      = "web-layer-autoscale"
  launch_configuration      = aws_launch_configuration.web_conf.id
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 5
  vpc_zone_identifier       = [aws_subnet.internal_bigip.id] 


 tag {
    key                 = "Name"
    value               = "WebApp-AutoScale"
    propagate_at_launch = true
  }

  tag {
    key = "PoolMemberOf"
    value = "F5"
    propagate_at_launch = true
  }

  tag {
    key          = "owner"
    value        = var.user_id
    propagate_at_launch = true
  }
}



