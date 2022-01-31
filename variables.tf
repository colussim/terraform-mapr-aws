variable "aws_ami" {
  description = "defaut CentOS 8.3"
  default     = "ami-05d7cb15bfbf13b6d"
}

variable "aws_instance_type" {
  description = "Machine Type"
  default     = "m4.xlarge"
}

variable "aws_worker" {
  default = 3
  description = "Number of Workers"
}
variable "private_key" {
  type        = string
  default     = "ssh-keys/id_rsa_aws"
  description = "The path to your private key"
}

variable "worker_zone" {
  default = "us-east-1a"
}

variable "master_name" {
  default = "master01" 
}

variable "worker_index" {
  default = "k8sworker" 
  description="index name for worker : k8sworker0 , k8sworker1 ...."
}

variable "domain_name" {
  default = "datafabric02.local"
}

variable "vpctag" {
  default = "prodk8s-vpc03"
  description = "VPC Tag"
}

variable "useraws" {
  default = "centos"
  description = "Default user dor Centos Image"
}

