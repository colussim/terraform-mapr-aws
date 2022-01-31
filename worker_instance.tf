#
resource "aws_instance" "worker-nodes" {
  ami           = var.aws_ami
  instance_type = var.aws_instance_type
  key_name      = "admin"
  count =  var.aws_worker
  
  subnet_id = "${aws_subnet.vmtest-a.id}"
  security_groups = [
    "${aws_security_group.sg_infra.id}"
  ]
# Size of root Disk
  root_block_device {
      volume_size = 256
    }

# Add 2 Disks on each Worker instance

  ebs_block_device{
      device_name = "/dev/sdh"
      volume_size = 128
      volume_type = "gp2"
    }
    ebs_block_device{
      device_name = "/dev/sdi"
      volume_size = 128
      volume_type = "gp2"
    }


  provisioner "remote-exec" {
  inline = [
  <<EOH

  set -x
  sudo /usr/sbin/swapoff -a
  sleep 60
  sudo sed -i '/ swap /s/^/#/' /etc/fstab
  sudo dnf -y install wget
  sudo wget https://github.com/mikefarah/yq/releases/download/v4.2.0/yq_linux_amd64.tar.gz -O - | sudo tar xz && sudo mv yq_linux_amd64 /usr/bin/yq

  sudo modprobe overlay
  sudo modprobe br_netfilter
  sudo  sh -c 'echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf'
  sudo  sh -c 'echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf'
  sudo  sh -c 'echo net.ipv4.conf.all.forwarding=1 >> /etc/sysctl.conf'
  sudo  sh -c 'echo net.bridge.bridge-nf-call-iptables=1 >> /etc/sysctl.conf'
  sudo sysctl -p

  sudo yum -y update
  sudo dnf -y install 'dnf-command(copr)'
  sudo dnf -y install java-11-openjdk-devel
  sudo dnf -y copr enable rhcontainerbot/container-selinux
  sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/CentOS_8/devel:kubic:libcontainers:stable.repo
  sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:1.22.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:1.22/CentOS_8/devel:kubic:libcontainers:stable:cri-o:1.22.repo
  sudo curl -L -o /etc/yum.repos.d/kubernetes.repo https://raw.githubusercontent.com/colussim/terraform-mapr-aws/main/k8sdeploy-scripts/kubernetes.repo

  sudo hostnamectl set-hostname --static ${var.worker_index}${count.index}.${var.domain_name} 
  sudo bash -c 'echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg'
  export HOSTNAME="${var.worker_index}${count.index}.${var.domain_name}"
  ssh-keygen -t rsa -f ~/.ssh/id_rsa_$HOSTNAME -P ''  

  sudo yum -y install cri-o cri-tools

  sudo yum -y install podman
  sudo yum -y remove docker

  sudo /usr/bin/systemctl enable --now crio

  sudo yum install -y kubelet kubeadm kubectl
  sudo yum install -y wget
  sudo yum -y install bind-utils
  sudo yum -y install fuse.x86_64 fuse-common.x86_64 fuse-devel.x86_64 fuse-overlayfs.x86_64
  sudo yum -y install iscsi-initiator-utils
  sudo /usr/bin/systemctl enable kubelet.service
  sudo /usr/bin/systemctl restart kubelet
  sudo /usr/bin/systemctl daemon-reload

  sudo ${data.external.kubeadm_join.result.command}
  mkdir -p $HOME/.kube


EOH
]
connection {
                type        = "ssh"
                user        = "${var.useraws}"
                host     = "${self.public_ip}"
                private_key = file(var.private_key)
        }
}
provisioner "local-exec" {
      command    = "./k8sdeploy-scripts/ReverseIP ${var.worker_index}${count.index} ${self.private_ip} 1;./k8sconf/setkubectl.sh ${self.public_ip};\n ./k8sdeploy-scripts/set_ssh.sh ${self.public_ip} ${var.worker_index}${count.index}.${var.domain_name};\n echo '${self.private_ip} ${var.worker_index}${count.index}.${var.domain_name} ${var.worker_index}${count.index}' >> ./k8sdeploy-scripts/hosts.local;\n echo '${self.public_ip} ${var.worker_index}${count.index}' >> ./k8sdeploy-scripts/hosts.pub"
  }

  tags = {
        Name = "${var.worker_index}${count.index}"
    }
  depends_on = [aws_instance.master-nodes]  
} 

# Copy authorized_keys and hosts file un each worker Node

resource "null_resource" "set_host" {
  provisioner "local-exec" {
    command    = "./k8sdeploy-scripts/set_hostname.sh" 
      } 
      depends_on = [aws_instance.worker-nodes]
} 


locals {
  workers_servers = tolist([
    for server in aws_instance.worker-nodes :
    server.private_ip
  ])

}

# Add DNS records A for worker node 

resource "aws_route53_record" "DNS_k8s_workers_A" {
  allow_overwrite = true
  count = "${length(local.workers_servers)}"
  zone_id = "${aws_route53_zone.my_private_zone.id}" 
  name    = "${var.worker_index}${count.index}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = ["${local.workers_servers[count.index]}"]

  depends_on = [aws_instance.worker-nodes]
}

# Add DNS records PTR for worker node

data "external" "worker_reverse_ip" {
     count = "${var.aws_worker}"

     program = ["./k8sdeploy-scripts/PutReverseIP"]

     query = {

        indexnodes="${count.index + 1}"
    }
   depends_on = [aws_instance.worker-nodes]
}

resource "aws_route53_record" "DNS_k8s_workers_PTR" {
    allow_overwrite = true
    count = "${var.aws_worker}"
    zone_id = "${aws_route53_zone.my_private_zone.id}"
    type = "PTR"
    ttl = 1800
    name = "${data.external.worker_reverse_ip.*.result.IPR[count.index]}"

    records = ["${var.worker_index}${count.index}.${var.domain_name}"]


    depends_on = [aws_instance.worker-nodes]
}
