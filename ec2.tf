################################################################
# Variables
################################################################

variable "type" {
    
    description = "ec2 instance type"
    default = "t2.micro"
}

variable "ami" {
    
    description = "ami id"
    default = "ami-0a0ad6b70e61be944"
}

################################################################
# KeyPair Creation
################################################################

resource "aws_key_pair" "webserver" {
    
  key_name   = "webserverkey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC08T5nry+a0YQw2CfEmDUn+mpBk6LmwAgwzooiamnHPaHpcL2chJABWKwuL4JltlB3daM3izKKWA/lMCGq6ME6SBuc23L0cR/YH3gYNpbdXF7oE00juIiiE20o3XKPL8/vPXZHvQLxwK2I2O8+KCYnbeveYIf0WwrEu4JZ+onQ8toK+PNWr+XYpKHejzvn7NboXrdlUojnW4/2jSZjqxYAblYNlbpQhDk1bnljwc60Dlz0/rKlYZrGs+awM+R02HU405FNT2AQ2szhheqTjkoHCJzGP5NBeon8RvYdoBGOiSDjDO373ZvPIEDnMskAPE4S5/WuoKF8zM/GcfZCFNfN root@ip-172-31-24-202.ec2.internal"  
  tags = {
    Name = "webserverkey"
  } 
}


################################################################
# Security Group Webserver Access
################################################################


resource "aws_security_group" "webservergroup" {
    
    
  name        = "webserver"
  description = "allow 80,443 only"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0"]
  }

    
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webserver"
  }
}

################################################################
# Security Group Remote Access
################################################################

resource "aws_security_group" "remote" {
    
    
  name        = "remotegroup"
  description = "allow 22 only"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0"]
  }
  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "remote"
  }
}


################################################################
# Ec2 Instance
################################################################

resource "aws_instance" "webserver" {
    
  ami                            = var.ami
  instance_type                  = var.type
  associate_public_ip_address    = true
  vpc_security_group_ids         = [ aws_security_group.webservergroup.id , aws_security_group.remotegroup.id ] 
  user_data                      = file("setup.sh") 
  key_name                       = aws_key_pair.webserverkey.id
  tags = {
    Name = "webserver"
  }
  
  lifecycle {
      
      create_before_destroy = true
  }
    
}
