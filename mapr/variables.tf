
variable "private_key" {
  type        = string
  default     = "../ssh-keys/id_rsa_aws"
  description = "The path to your private key"
}

variable "master_ip" {
  default = "x.x.x.x" 
  description = "The IP address for master node"
}

variable "rootpw" {
  default = "xxxx"
  description = "Root passwd"
}

variable "useraws" {
  default = "centos"
  description = "Default user dor Centos Image"
}

variable "maprhost" {
    type = list
    default = ["x.x.x.x", "x.x.x.x", "x.x.x.x", "x.x.x.x"]
    description = "IP public for maprcluster node"
}
