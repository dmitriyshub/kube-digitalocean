terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
terraform {
  backend "s3" {
    endpoint                    = "ams3.digitaloceanspaces.com/" # specify the correct DO region
    region                      = "us-west-1" # not used since it's a DigitalOcean spaces bucket
    key                         = "terraform.tfstate"
    bucket                      = "terraform-space2" # The name of your Spaces

    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_vpc" "vpc" {
  name     = "digitalocean-kube"
  region   = "nyc3"
  ip_range = "10.10.10.0/24"
}


# Create a web server
resource "digitalocean_kubernetes_cluster" "kube-test" {
  name   = "kube-test"
  region = "nyc3"
  vpc_uuid = digitalocean_vpc.vpc.id
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.21.3-do.0"

  node_pool {
    name       = "pool-test"
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}

output "kubeconfig" {
  value = digitalocean_kubernetes_cluster.kube-test.kube_config.0.raw_config
  sensitive = true
}
