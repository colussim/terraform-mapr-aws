# 


resource "aws_instance" "master-nodes" {
  ami           = var.aws_ami
  instance_type = var.aws_instance_type
  key_name      = "admin"
  subnet_id = "${aws_subnet.vmtest-a.id}"
  
  
  security_groups = [
    "${aws_security_group.sg_infra.id}"
  ]
  root_block_device {
      volume_size = 128
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

  sudo hostnamectl set-hostname --static ${var.master_name}.${var.domain_name}
  sudo bash -c 'echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg'
  export HOSTNAME="${var.master_name}.${var.domain_name}"
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

  sudo wget https://raw.githubusercontent.com/colussim/terraform-mapr-aws/main/k8sconf/setk8sconfig.yaml -O /tmp/setk8sconfig.yaml
  sudo /usr/bin/kubeadm init --config /tmp/setk8sconfig.yaml

  mkdir -p $HOME/.kube && sudo /bin/cp /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

 /usr/bin/kubectl apply -f https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')
 /usr/bin/kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml
 /usr/bin/kubectl apply -f https://raw.githubusercontent.com/colussim/terraform-aws-infra/main/k8sconf/clusteradmin.yaml


EOH
]
connection {
                type        = "ssh"
                user        = "${var.useraws}"
                host     = aws_instance.master-nodes.public_ip
                private_key = file(var.private_key)
        }
}
provisioner "local-exec" {
      command    = "./k8sdeploy-scripts/ReverseIP ${var.master_name} ${self.private_ip} 0;rm -f k8sdeploy-scripts/authorized_keys;\n rm -f k8sdeploy-scripts/hosts.local;\n ./k8sconf/getkubectl-conf.sh ${self.public_ip};\n ./k8sdeploy-scripts/set_ssh.sh ${self.public_ip} ${var.master_name}.${var.domain_name};\n echo '${self.private_ip}  ${var.master_name}.${var.domain_name} ${var.master_name}' > ./k8sdeploy-scripts/hosts.local;\n echo '${self.public_ip} ${var.master_name}' > ./k8sdeploy-scripts/hosts.pub"
  }

  tags= {
        Name = "${var.master_name}"
    }
}


# SET Command to join k8s cluster
data "external" "kubeadm_join" {
  program = ["./k8sconf/kubeadm-token.sh"]

  query = {
    host = aws_instance.master-nodes.public_ip
  }
  depends_on = [aws_instance.master-nodes]

}

# Add DNS records A for master node

resource "aws_route53_record" "DNS_k8s_master_A" {
  allow_overwrite = true
  zone_id = "${aws_route53_zone.my_private_zone.id}" 
  name    = "${var.master_name}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.master-nodes.private_ip}"]

  depends_on = [aws_instance.master-nodes]
}



# Add DNS records PTR for master node


data "external" "master_reverse_ip" {


     program = ["./k8sdeploy-scripts/PutReverseIP"]

     query = {

        indexnodes="0"
    }
   depends_on = [aws_instance.master-nodes]
}

resource "aws_route53_record" "DNS_k8s_master_PTR" {
    allow_overwrite = true
    count = 1
    zone_id = "${aws_route53_zone.my_private_zone.id}"
    name = "${data.external.master_reverse_ip.*.result.IPR[0]}"
 
    type = "PTR"
    ttl = 1800
    records = ["${var.master_name}.${var.domain_name}"]

    depends_on = [aws_instance.master-nodes]
}

