
region = "eu-west-3"
vpc-cidr = "10.0.0.0/16"
vpc-enable_dns_support = true
vpc-enable_dns_hostnames = true

# RDS
rds-schema = "appschema"
rds-identifier = "rdsidentifier"
rds-username = "username"
rds-password = "password"
rds-port = 3306
rds-multi_az = false
rds-availability_zone = "eu-west-3c"

# Elastic-beanstalk
app-name = "aplicationname"
solution_stack_name =  "Java 8 running on 64bit Amazon Linux/2.11.1"