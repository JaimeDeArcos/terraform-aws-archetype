variable "region" { type = string }

# VPC
variable "vpc-cidr"   { type = string }
variable "vpc-enable_dns_support"   { type = bool }
variable "vpc-enable_dns_hostnames" { type = bool }

# RDS
variable "rds-schema"     { type = string }
variable "rds-identifier" { type = string }
variable "rds-username"   { type = string }
variable "rds-password"   { type = string }
variable "rds-port"       { type = string }
variable "rds-multi_az"   { type = string }
variable "rds-availability_zone" { type = string  }

# EB
variable "app-name" { type = string }

variable "solution_stack_name" {
  default = "64bit Amazon Linux 2016.03 v2.1.6 running Java 8"
}


