resource "aws_launch_template" "liftoff" {
  name_prefix = "liftoff"

  description = "lift off server group"

  image_id = "ami-053b0d53c279acc90"

  instance_type = "t2.micro"

  key_name = var.key_pair

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [aws_security_group.Web_servers_sg.id, aws_security_group.Web_alb_sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "tera-liftoff"
    }
  }

}

resource "aws_autoscaling_group" "liftoff" {
  name                      = "liftoff"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.Web-priv-subnet1.id, aws_subnet.Web-priv-subnet2.id]
  target_group_arns         = [aws_lb_target_group.alb_tg.arn]


  launch_template {
    id      = aws_launch_template.liftoff.id
    version = "$Latest"
  }
}

data "aws_instances" "liftoff" {
  instance_state_names = ["running"]
  instance_tags = {
    # Use whatever name you have given to your instances
    name = "tera-liftoff"
  }
}

output "autoscaling_group_ips" {
  value = data.aws_instances.liftoff.*.private_ips
}


resource "aws_instance" "web3" {
  vpc_security_group_ids = [aws_security_group.Web_alb_sg.id] 
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.main.id
  key_name               = aws_key_pair.Web_keys.key_name
  subnet_id              = aws_subnet.Web-pub-subnet1.id
  root_block_device {
    volume_size = 8
  }
  tags = {
    "Name" = "liftoff-bastion"
  }
}

resource "local_file" "hosts" {
  filename = "hosts"
  content  = data.aws_instances.liftoff.*.public_ips
}
