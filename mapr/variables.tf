
variable "private_key" {
  type        = string
  default     = "../ssh-keys/id_rsa_aws"
  description = "The path to your private key"
}

variable "master_ip" {
  default = "107.20.97.62" 
}

variable "rootpw" {
  default = "Bench123"
  description = "Root passwd"
}

variable "useraws" {
  default = "centos"
  description = "Default user dor Centos Image"
}

variable "maprhost" {
    type = list
    default = ["107.20.97.62", "54.161.133.187", "54.209.64.65", "3.94.187.194"]
    description = "IP public for maprcluster"
}
