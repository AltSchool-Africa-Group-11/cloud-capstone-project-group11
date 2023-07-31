#Elastic load balancer
resource "aws_lb" "default" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Web_alb_sg.id]
  subnets            = [aws_subnet.Web-priv-subnet1.id, aws_subnet.Web-priv-subnet2.id]

  enable_deletion_protection = false

}

resource "aws_lb_listener" "Web_alb_http" {
  load_balancer_arn = aws_lb.default.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb_listener" "web_alb_https" {
  load_balancer_arn = aws_lb.default.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:290437845429:certificate/715e192e-9122-41da-b3ec-06d98d26bce9" //make custom

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name        = "alb-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.Web_Vpc.id

}

# Route 53 to load balancer
resource "aws_route53_zone" "main" {
  name = "groupeleven.me"
  tags = {
    Environment = "capstone"
  }
}
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "liftoff.groupeleven.me"
  type    = "A"

  alias {
    name                   = aws_lb.default.dns_name
    zone_id                = aws_lb.default.zone_id
    evaluate_target_health = true
  }
}