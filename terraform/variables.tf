variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}
variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}
variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "sentry:9.1.2"
}
variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 9000
}
variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}
variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}
variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}
variable "name_db" {
  default = ""
}
variable "username" {
  default = ""
}
variable "password" {
  default = ""
}
variable "s_key" {
  default = ""

}
variable "redis_host" {
  default = ""
}
variable "db_host" {
  default = ""
}



