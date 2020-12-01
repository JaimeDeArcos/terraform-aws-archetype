
# VPC - Subnets - gateway
module "vpc"  {
  source = "./modules/vpc"
  region = var.region
  app-name = var.app-name
  vpc_cidr = var.vpc-cidr
  enable_dns_support = var.vpc-enable_dns_support
  enable_dns_hostnames = var.vpc-enable_dns_hostnames
  routes = [
    {
      # VPC with 65,536 addresses
      cidr_block     = "0.0.0.0/0"
      instance_id    = null
      nat_gateway_id = null
    }
  ]
}

# Last Java 8 AMI
data "aws_elastic_beanstalk_solution_stack" "java8" {
  most_recent = true
  name_regex = "64bit Amazon Linux (.*) running Java 8$"
}

# Security Groups
resource "aws_security_group" "eb-sg" {
  name = "eb-sg"
  description = "SecurityGroup for ElasticBeanstalk environment."
  vpc_id = module.vpc._.vpc_id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port = 587
    to_port = 587
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "EB_sg"
  }
}
resource "aws_security_group" "rds-sg" {

  name = "rds-sg"
  description = "RDS (terraform-managed)"
  vpc_id = module.vpc._.vpc_id

  # Only MySQL in
  ingress {
    from_port   = var.rds-port
    to_port     = var.rds-port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = var.rds-port
    to_port         = var.rds-port
    protocol        = "tcp"
    security_groups = [aws_security_group.eb-sg.id]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS_sg"
  }
}

# RDS
resource "aws_db_instance" "rds-db" {

  name                    = var.rds-schema
  identifier              = var.rds-identifier

  allocated_storage       = 20
  backup_retention_period = 7
  backup_window           = "10:46-11:16"
  maintenance_window      = "Mon:00:00-Mon:03:00"
  engine                  = "mysql"
  engine_version          = "8.0.15"
  instance_class          = "db.t2.micro"
  username                = var.rds-username
  password                = var.rds-password
  port                    = var.rds-port
  publicly_accessible     = true
  storage_type            = "gp2"

  allow_major_version_upgrade  = false
  auto_minor_version_upgrade   = true
  performance_insights_enabled = false
  skip_final_snapshot          = true
  final_snapshot_identifier = "database-${var.rds-schema}-snapshot"

  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  availability_zone         = var.rds-availability_zone
  multi_az                  = var.rds-multi_az
  //snapshot_identifier     = var.snapshot_identifier
  //db_subnet_group_name    = aws_db_subnet_group._.id
  //final_snapshot_identifier = "prod-trademerch-website-db-snapshot"
  //storage_encrypted       = var.storage_encrypted
}

# ElasticBeanstalk - Application
resource "aws_elastic_beanstalk_application" "eb-application" {
  name = var.app-name
  depends_on = [aws_db_instance.rds-db]
}

# ElasticBeanstalk - Environment
resource "aws_elastic_beanstalk_environment" "eb-env-prod" {

  depends_on = [aws_db_instance.rds-db]

  name                = "${var.app-name}-prod"
  application         = aws_elastic_beanstalk_application.eb-application.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.java8.name
  cname_prefix        = var.app-name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.micro"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "EnvironmentType"
    value = "SingleInstance"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.micro"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "SPRING_PROFILES_ACTIVE"
    value = "prod"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "SPRING_DATASOURCE_URL"
    value = "jdbc:mysql://${aws_db_instance.rds-db.endpoint}/${aws_db_instance.rds-db.name}?useSSL=false"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "SPRING_DATASOURCE_USERNAME"
    value = aws_db_instance.rds-db.username
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "SPRING_DATASOURCE_PASSWORD"
    value = aws_db_instance.rds-db.password
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SecurityGroups"
    value = aws_security_group.eb-sg.id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = module.vpc._.vpc_id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = module.vpc._.subnet_a
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "VPCId"
    value = module.vpc._.vpc_id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "true"
  }
}

