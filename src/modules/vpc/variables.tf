
variable "vpc_cidr"  { type = string }
variable "enable_dns_support"  { type = string }
variable "enable_dns_hostnames"  { type = string }
variable "routes" { default = "" }
variable "region" { type = string}
variable "app-name" { type = string }