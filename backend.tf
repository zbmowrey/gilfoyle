
# You can freely change this - the file is gitignored. 

terraform {
  backend "remote" {
    organization = "zbmowrey"
    workspaces {
      prefix = "insult-bot-"
    }
  }
  required_providers {
    aws    = "~> 3.6"
    random = ">= 2"
  }
  required_version = ">= 1.0.3"
}
