resource "aws_lb" "lab3_public_lb" {
  name               = "lab3-public-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lab3_public_sg]
  subnets            = var.public_subnets_id

  enable_deletion_protection = false

  tags = {
    Name = "lab3_public_lb"
  }
}
resource "aws_lb_target_group" "lab3_public_tg" {
  name     = "lab3-public-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.lab3_vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_target_group_attachment" "lab3_public_tg_attachment" {
  count            = length(var.public_instance_ids)
  target_group_arn = aws_lb_target_group.lab3_public_tg.arn
  target_id        = var.public_instance_ids[count.index]
  port             = 80
  depends_on       = [ aws_lb_target_group.lab3_public_tg ]
}
resource "aws_lb_listener" "lab3_public_listener" {
  load_balancer_arn = aws_lb.lab3_public_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lab3_public_tg.arn
  }
}

resource "aws_lb" "lab3_private_lb" {
  name               = "lab3-private-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.lab3_private_sg]
  subnets            = var.private_subnets_id
  enable_deletion_protection = false

  tags = {
    Name = "lab3_private_lb"
  }
}
resource "aws_lb_target_group" "lab3_private_tg" {
  name     = "lab3-private-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.lab3_vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_target_group_attachment" "lab3_private_tg_attachment" {
  count            = length(var.private_instance_ids)
  target_group_arn = aws_lb_target_group.lab3_private_tg.arn
  target_id        = var.private_instance_ids[count.index]
  port             = 80
  depends_on       = [ aws_lb_target_group.lab3_private_tg ]
}
resource "aws_lb_listener" "lab3_private_listener" {
  load_balancer_arn = aws_lb.lab3_private_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lab3_private_tg.arn
  }
  
}