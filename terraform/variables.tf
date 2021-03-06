variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}
variable "aws_iam_role" {
  default = "arn:aws:iam::875746189822:role/myEcsTaskExecutionRole"
}
variable "SENTRY_SECRET_KEY" {
  default = ""
}
variable "SENTRY_REDIS_PORT" {
  default = "6379"
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





