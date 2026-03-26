terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "= 5.44.0" }
    tls = { source = "hashicorp/tls", version = ">= 4.0" }
  }
}

provider "aws" {
  region  = var.region
  profile = "goad"
}

{% if not use_existing_vpc %}
data "terraform_remote_state" "core" {
  backend = "local"
  config  = { path = var.core_state_path }
}
{% endif %}
