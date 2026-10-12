provider "aws" {
  region = var.region
}

module "web" {
  source = "../.."

  name          = "web"
  ami_id        = var.ami_id
  instance_type = "t3.micro"
  key_name      = var.key_name
  admin_cidr    = var.admin_cidr
  open_ports    = [80, 443]

  tags = {
    Environment = "lab"
  }
}

output "public_ip" {
  value = module.web.public_ip
}
