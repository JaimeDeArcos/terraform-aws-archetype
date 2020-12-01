provider "aws" {
  region                  = var.region  # Paris
  shared_credentials_file = "~/.aws/creds"
  profile                 = "default"  # Optional
}