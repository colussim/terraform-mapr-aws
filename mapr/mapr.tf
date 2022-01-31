# Set Root access on each Nodes

resource "null_resource" "maprsetroot" {
for_each = toset(var.maprhost)

        provisioner "remote-exec" {
        inline = [
<<EOT

#set -e
sudo -i<<EF
passwd root<<EF1
${var.rootpw}
${var.rootpw}
EF1
EF 

sudo sed -ri 's/^(\s*)(disable_root\s*:\s*1\s*$)/\1disable_root: 0/' /etc/cloud/cloud.cfg
sudo sed -ri 's/^(\s*)(PasswordAuthentication\s*\s*no\s*$)/\1PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo service sshd restart


EOT
                ]
        connection {
                        type        = "ssh"
                        user        = var.useraws
                        host     = each.value 
                        private_key = file(var.private_key)
                }
        }
        
}

# Deploy MAP-R
# Copy cluster config file

resource "null_resource" "maprdeploy" {

    provisioner "file" {
    source      = "../Stanzas/cluster-install.yaml"
    destination = "/tmp/cluster-install.yaml"

    connection {
        type        = "ssh"
        user        = var.useraws
        host     = var.master_ip
        private_key = file(var.private_key)
        }
  }    

    provisioner "remote-exec" {
        inline = [
<<EOT1

sudo wget https://package.mapr.hpe.com/releases/installer/mapr-setup.sh -P /tmp
sudo chmod +x /tmp/mapr-setup.sh

sudo /tmp/mapr-setup.sh -y
sudo /tmp/mapr-setup.sh -y cli install -nv -t /tmp/cluster-install.yaml -o config.cluster_admin_password=mapr

EOT1
         ]
        connection {
                        type        = "ssh"
                        user        = var.useraws
                        host     = var.master_ip
                        private_key = file(var.private_key)
                }
        }

}        