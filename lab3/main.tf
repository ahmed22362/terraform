module "network" {
  source   = "./network"
  vpc_cidr = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "instances" {
  source              = "./instances"
  instance_type       = var.instance_type
  public_subnet_ids   = module.network.public_subnet_ids
  private_subnet_ids  = module.network.private_subnet_ids
  lab3_vpc_id         = module.network.vpc_id
  lab3_vpc_cidr       = var.vpc_cidr
  key_path            = var.key_path
  ssh_key_name        = var.ssh_key_name
}
module "loadbalancer" {
  source             = "./loadbalancer"
  public_subnets_id  = module.network.public_subnet_ids
  private_subnets_id = module.network.private_subnet_ids
  lab3_vpc_id        = module.network.vpc_id
  public_instance_ids  = module.instances.public_instance_ids
  private_instance_ids = module.instances.private_instance_ids
  lab3_public_sg     = module.instances.public_security_group_id
  lab3_private_sg    = module.instances.private_lb_security_group_id
}

# Configure public instances to redirect to private load balancer
resource "null_resource" "configure_redirect" {
  count = length(module.instances.public_instance_ids)
  depends_on = [module.instances, module.loadbalancer]
  
  triggers = {
    lb_dns = module.loadbalancer.lb_private_dns
    instance_id = module.instances.public_instance_ids[count.index]
    force_run  = timestamp() # Force re-run on every apply
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"  
      private_key = file(var.key_path)
      host        = module.instances.public_instance_ip[count.index]
    }

    inline = [
      "echo 'Configuring redirect to ${module.loadbalancer.lb_private_dns} on instance ${count.index + 1}'",
      "sudo yum update -y",
      "sudo amazon-linux-extras install nginx1 -y",
      "sudo rm -f /etc/nginx/nginx.conf",
      "sudo tee /etc/nginx/nginx.conf > /dev/null <<EOF",
      "events {",
      "    worker_connections 1024;",
      "}",
      "http {",
      "    upstream private_lb {",
      "        server ${module.loadbalancer.lb_private_dns}:80;",
      "    }",
      "    server {",
      "        listen 80;",
      "        server_name _;",
      "        location / {",
      "            proxy_pass http://private_lb;",
      "            proxy_set_header Host \\$host;",
      "            proxy_set_header X-Real-IP \\$remote_addr;",
      "            proxy_set_header X-Forwarded-For \\$proxy_add_x_forwarded_for;",
      "            proxy_set_header X-Forwarded-Proto \\$scheme;",
      "            proxy_connect_timeout 30s;",
      "            proxy_send_timeout 30s;",
      "            proxy_read_timeout 30s;",
      "        }",
      "        location /health {",
      "            return 200 'OK from Public Instance ${count.index + 1}';",
      "            add_header Content-Type text/plain;",
      "        }",
      "    }",
      "}",
      "EOF",
      "sudo nginx -t",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "sudo systemctl status nginx",
      "echo 'Nginx reverse proxy configured successfully on instance ${count.index + 1}'"
    ]
  }
}