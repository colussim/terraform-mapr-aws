output "worker_public_ip" {
  value = aws_instance.worker-nodes.*.public_ip
}

output "worker_private_ip" {
  value = aws_instance.worker-nodes.*.private_ip
}

output "master_public_ip" {
  value = aws_instance.master-nodes.public_ip
}

output "master_private_ip" {
  value = aws_instance.master-nodes.private_ip
}

output "kubeadm_join_command" {
  value = "data.external.kubeadm_join.result['command']"
}

output "worker_awsid" {
  value = aws_instance.worker-nodes.*.id
}


#output "my_reverse_script" {
 # value = data.external.my_reverse_script.result.reversed

#}