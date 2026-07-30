resource "aws_ecr_repository" "techchallenge2_app" {
  name = "techchallenge2-app"

  image_tag_mutability = "MUTABLE"

  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = "TechChallenge2"
  }
}