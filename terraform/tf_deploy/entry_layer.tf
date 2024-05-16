# data "aws_ssm_parameter" "ssm_vpc_id" {
#   name = "/platform/sharedvpc/vpc_id"
# }

# data "aws_subnets" "routable_private_subnets" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_ssm_parameter.ssm_vpc_id.value]
#   }
#   tags = {
#     Subnet = "private-routable"
#   }
# }

# resource "aws_security_group" "alb_icgen_sg" {
#   name        = "${local.user_id}-alb-sg"
#   description = "Security group for the ALB"
#   vpc_id      = data.aws_ssm_parameter.ssm_vpc_id.value

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Allow traffic from any source IP
#   }
# }

# resource "aws_servicecatalog_provisioned_product" "private_hosted_zone" {
#   name                       = "${local.user_id}-frontend-hosted-zone"
#   path_name                  = "iaws-platform"
#   product_name               = "iaws-private-hosted-zone"
#   provisioning_artifact_name = "3.0.1"
#   provisioning_parameters {
#     key   = "HostedZoneSubdomain"
#     value = "${local.user_id}-${var.domain_name}"
#   }
# }

# resource "aws_acm_certificate" "private_cert" {
#   domain_name               = "${local.user_id}-${var.domain_name}"
#   certificate_authority_arn = var.certificate_authority_arn
# }

# resource "aws_lb" "alb_frontend" {
#   name               = "${local.user_id}-frontend-alb"
#   internal           = true
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_frontend_sg.id]
#   subnets            = data.aws_subnets.routable_private_subnets.ids
# }

# resource "aws_route53_record" "frontend_lb_alias" {
#   zone_id = [for output in aws_servicecatalog_provisioned_product.private_hosted_zone.outputs : output.value if output.key == "oPrivateHostedZone"][0]
#   name    = var.domain_name
#   type    = "A"

#   alias {
#     name                   = aws_lb.alb_frontend.dns_name
#     zone_id                = aws_lb.alb_frontend.zone_id
#     evaluate_target_health = true
#   }
# }

# resource "aws_lb_listener" "alb_frontend_listener" {
#   load_balancer_arn = aws_lb.alb_frontend.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate.private_cert.arn

#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "application/json"
#       message_body = "{\"message\": \"not found\"}"
#       status_code  = "404"
#     }
#   }
# }
