locals {
  apps = {
    "gqbooks"   = { "port" : 7080 }
    "gqbooksui" = { "port" : 80 }
  }
}

resource "aws_ecr_repository" "app_ecr_repo" {
  for_each = local.apps
  name     = each.key
}

# resource "aws_ecs_cluster" "app_cluster" {
#   name = "${local.env}-${local.project}"
# }

# resource "aws_ecs_task_definition" "app_task" {
#   for_each = local.apps

#   family                   = "${local.env}-${each.key}"
#   container_definitions    = <<EOD
#   [
#     {
#         "name": "${local.env}-${each.key}",
#         "image": "${aws_ecr_repository.app_ecr_repo[each.key].repository_url}",
#         "essential": true,
#         "portMappings": [
#           {
#             "containerPort": ${each.value.port},
#             "hostPort": ${each.value.port}
#           }
#         ],
#         "logConfiguration": {
#         "logDriver": "awslogs",
#         "options": {
#             "awslogs-region": "${local.region}",
#             "awslogs-group": "stream-to-log-fluentd",
#             "awslogs-stream-prefix": "project"
#           }
#         },
#         "cpu": 128,
#         "memory": 256,
#         "environment": [
#           {
#             "name": "PORT",
#             "value": "${each.value.port}"
#           },
#           {
#             "name": "ENV",
#             "value": "${local.env}"
#           }
#         ]
#     }
#   ]
#   EOD
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   memory                   = 512
#   cpu                      = 256
#   execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
# }

# resource "aws_iam_role" "task_execution" {
#   name               = "${local.env}-ecs-task-execution"
#   assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
# }

# data "aws_iam_policy_document" "assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
#   role       = aws_iam_role.assume_role_policy.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# resource "aws_alb" "application_load_balancer" {
#   name               = "${local.env}-${local.project}-load-balancer"
#   load_balancer_type = "application"
#   subnets            = module.vpc.public_subnets
#   security_groups    = ["${aws_security_group.load_balancer_security_group.id}"]
# }

# resource "aws_security_group" "load_balancer_security_group" {
#   vpc_id      = module.vpc.id
#   name        = "${local.env}-loadbalancer-access"
#   description = "Allow ${local.env} loadbalancer access"

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_lb_target_group" "target_group" {
#   name        = "${local.env}-target-group"
#   port        = 80
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = module.vpc.id
# }

# resource "aws_lb_listener" "listener" {
#   load_balancer_arn = aws_alb.application_load_balancer.arn
#   port              = "80"
#   protocol          = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target_group.arn
#   }
# }

# resource "aws_ecs_service" "app_service" {
#   for_each        = local.apps
#   name            = "${local.env}-${each.key}"
#   cluster         = aws_ecs_cluster.app_cluster.id
#   task_definition = aws_ecs_task_definition.app_task[each.key].arn
#   launch_type     = "FARGATE"
#   desired_count   = 1

#   load_balancer {
#     target_group_arn = aws_lb_target_group.target_group.arn
#     container_name   = aws_ecs_task_definition.app_task[each.key].family
#     container_port   = each.value.port
#   }

#   network_configuration {
#     subnets          = module.vpc.public_subnets
#     assign_public_ip = true
#     security_groups  = [aws_security_group.service_security_group.id]
#   }
# }

# resource "aws_security_group" "service_security_group" {
#   vpc_id      = module.vpc.id
#   name        = "${local.env}-service-access"
#   description = "Allow ${local.env} service access"

#   ingress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# output "app_url" {
#   value = aws_alb.application_load_balancer.dns_name
# }
