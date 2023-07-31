#Security groups
resource "aws_security_group" "Web_servers_sg" {
  name        = "Web-Sg"
  vpc_id      = aws_vpc.Web_Vpc.id
  description = "Configure ssh and other ports for web servers"

  ingress {
    description = "Allow ssh"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    description     = "Allow https"
    cidr_blocks     = ["0.0.0.0/0"]
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.Web_alb_sg.id]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  depends_on = [
    aws_security_group.Web_alb_sg
  ]
}
resource "aws_security_group" "Web_alb_sg" {
  name        = "ALB-Sg"
  description = "Configure http, https for application load balancer"
  vpc_id      = aws_vpc.Web_Vpc.id

  ingress {
    description = "Allow http"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    description = "Allow https"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Outgoing"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
}