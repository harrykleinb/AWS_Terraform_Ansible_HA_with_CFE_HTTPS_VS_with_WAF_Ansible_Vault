#################

#GLOBAL VARIABLES

################

variable "profile" {
  description = "AWS credentials you want to use"
}

variable "aws_region" {
  description = "aws region (default is eu-west-3 ie Paris)"
  default     = "eu-west-3"
}

variable "aws_keypair" {
  description = "The name of an existing key pair. In AWS Console: NETWORK & SECURITY -> Key Pairs"
  default     = "HarryK_Key_Pair"
}

variable "private_key_path" {
  default = "./HarryK_Key_Pair.pem"
}

variable "user_id" {
  description = "ID of the user which is deploying the Infrastructure"
  default     = "harryk"
}

variable "account_id_aws" {
  default     = "643019619955"
}


#################

#FOR Cloudinit

#################

variable "cfe_repo_url" {
# default     = "https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v1.2.0/f5-cloud-failover-1.2.0-0.noarch.rpm" 
  default     = "https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v1.3.0/f5-cloud-failover-1.3.0-0.noarch.rpm"
}


variable "as3_repo_url" {
 default     = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.19.1/f5-appsvcs-3.19.1-1.noarch.rpm"
}


variable "ts_repo_url" {
 default     = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.11.0/f5-telemetry-1.11.0-1.noarch.rpm"
}


variable "do_repo_url" {
  default    = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.12.0/f5-declarative-onboarding-1.12.0-1.noarch.rpm"
}


variable "cfe_file" {
 default     = "f5-cloud-failover-1.2.0-0.noarch.rpm"
}


variable "as3_file" {
 default     = "f5-appsvcs-3.19.1-1.noarch.rpm"
}


variable "ts_file" {
 default     = "f5-telemetry-1.11.0-1.noarch.rpm"
}


variable "do_file" {
 default     = "f5-declarative-onboarding-1.12.0-1.noarch.rpm"
}




#################

#FOR DO Declaration

#################


variable "host1" {
 default     = "bigip1"
}


variable "host2" {
  default    = "bigip2"
}


variable "timezone" {
  default    = "Europe/Paris"
}


variable "color_bigip1" {
  default    = "blue"
}


variable "color_bigip2" {
  default    = "orange"
}


variable "advisory_bigip1" {
  default    = "GUI_OF_BIGIP_1"
}


variable "advisory_bigip2" {
  default    = "GUI_OF_BIGIP_2"
}



#################

#INFRA

#################

variable "vpc_lab_cidr" {
  description = "CIDR of the LAB"
  default     = "172.42.0.0/16"
}

variable "mgmt_subnet" {
  description = "CIDR of the Management Subnet"
  default     = "172.42.10.0/24"
}

variable "mgmt_subnet_b" {
  description = "CIDR of the Management Subnet in us-east-1b"
  default     = "172.42.11.0/24"
}


variable "mgmt_sub_list" {
  type        = list(string)
  description = "Format List to be used into Securty Groups "

  default = ["172.42.10.0/24"]
}


variable "restrictedSrcAddress" {
  type        = list(string)
  description = "Lock down management access by source IP address or network. Format is subnet/mask between []. Use a comma to separate several adresses. "

  #That is the Client Public IP addresses used to manage the BIGIPs

  default = ["109.7.65.101/32","109.7.65.102/32","86.242.11.19/32","172.42.10.0/24","92.184.97.175/32"]
}


/*
var restrictedMgmtAddress in string format instead of list. 
List isn't allowed into the CFT which is used to deploy the bigips
That is the Client Public IP addresses used to manage the BIGIPs
*/

variable "restrictedMgmtAddress" {
  description = "Format IP/Masklength. In string format."
  default     = "0.0.0.0/0"
}



#################

#FOR BIG_IQ BYOL 7.0.0.1 Oct, 4 2019

#################


variable "bigiq_ami" {
  description = "AMI based on AWS Region"
  type = map(string)
  default = {
    us-east-1    = "ami-09cd0faf029ac7746"
    us-west-1    = "aami-05e14d844b0b28686"
    eu-central-1 = "ami-0f40f1ea8191faa1a"
    eu-west-1    = "ami-046af572233671cec"
  }
}

variable "bigiq_Mngt_IP" {
  description = "Management IP address of the BigIQ License Manage. Must be into the Management Subnet defined in section INFRA above."
  default     = "172.42.10.42"
}

variable "Licenses_Pool" {
  description = "Name of the License Pool on the BIG-IQ"
  default     = "Pool_BEST_1G"
}


#################

#FOR BIG_IP

#################

variable "internal_subnet_bigip" {
  description = "CIDR of the private Subnet of BIG_IPs"
  default     = "172.42.20.0/24"
}

variable "external_subnet_bigip" {
  description = "CIDR of the Subnet for external Subnet of BIG_IPs"
  default     = "172.42.30.0/24"
}


variable "external_selfip_bigip1" {
  default    = "172.42.30.11"
}


variable "external_selfip_bigip2" {
  default    = "172.42.30.12"
}


variable "internal_selfip_bigip1" {
  default    = "172.42.20.11"
}


variable "internal_selfip_bigip2" {
  default    = "172.42.20.12"
}


variable "management_bigip1" {
  default    = "172.42.10.51"
}


variable "management_bigip2" {
  default    = "172.42.10.52"
}


variable "IP_VS_1" {
  default   = "172.42.30.80"
}


variable "admin_user" {
  default    = "admin"
}

variable "bigip_admin_password" {
  default    = "Admin4ever1!"
}



#################

#FOR CFE Declaration

#################

variable "cfe_label" {
  default  = "harryk-cfe"
}




#################

#FOR Application Servers

#################

variable "ws_size" {
  default = "t2.micro" 
}



