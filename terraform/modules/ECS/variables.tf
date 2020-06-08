variable "aws_iam_role" {
    default = "arn:aws:iam::875746189822:role/myEcsTaskExecutionRole"
}
variable "private-a" {
}
variable "private-b" {
}
variable "ecs-sg" {
}
variable "sentry-tg" { 
}
variable "app_port" {
  default = 9000
}

variable "SENTRY_SECRET_KEY" {
  default = ""
}
variable "SENTRY_REDIS_PORT" {
  default = "6379"
}
variable "SENTRY_REDIS_HOST" {
}
variable "SENTRY_POSTGRES_HOST" {
}
variable "SENTRY_POSTGRES_PORT" {
  default = "5432"
}
variable "SENTRY_DB_NAME" {
  default = ""
}
variable "SENTRY_DB_USER" {
  default = ""
}
variable "SENTRY_DB_PASSWORD" {
  default = ""
}