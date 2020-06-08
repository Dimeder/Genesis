resource "aws_iam_role" "ecs_role" {
  name               = "ecs_role"
  assume_role_policy = file("modules/IAM/templates/ecs-role.json")
}
resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name     = "ecs_service_role_policy"
  policy   = file("modules/IAM/templates/ecs-policy.json")
  role     = aws_iam_role.ecs_role.id
}