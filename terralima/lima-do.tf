variable "do_token" {
  default = ""
}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_droplet" "test" {
  image  = "ubuntu-18-04-x64"
  name   = "web-1"
  region = "nyc2"
  size   = "s-1vcpu-1gb"
}