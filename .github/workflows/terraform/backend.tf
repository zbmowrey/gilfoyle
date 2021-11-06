
# You can freely change this - the file is gitignored. 

terraform {
  backend "remote" {
    organization = "zbmowrey-aws"
    workspaces {
      prefix = "zbmowrey-com-gilfoyle-"
    }
  }
  required_providers {
    aws    = ">= 2.67"
    random = ">= 2"
  }
  required_version = ">= 1.0.3"
}