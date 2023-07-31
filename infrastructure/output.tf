
#output of the bastion host instance
resource "local_file" "hosts" {
  filename = "hosts"
  content  = data.aws_instances.liftoff.*.public_ip
}

resource "local_file" "hosts" {
  filename = "hosts"
  content  = data.aws_instances.liftoff.*.private_ips
}
 