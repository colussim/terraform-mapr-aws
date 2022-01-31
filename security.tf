resource "aws_security_group" "sg_infra" {
 name = "sg_infra"
 description = "standard ssh &amp; monitoring"
 vpc_id = "${aws_vpc.vpc01.id}"

 ingress {
   from_port = 22
   to_port = 22
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
 ingress {
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port = 9443
    to_port = 9443 
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port = 8443 
    to_port = 8443 
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8042 
    to_port = 8042
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port = 8047
    to_port = 8047
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8088
    to_port = 8088
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port = 8888 
    to_port = 8888
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port = 18080 
    to_port = 18080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port = 19888 
    to_port = 19888
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


ingress {
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 3260
    to_port = 3260
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
 ingress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
 egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
 }
}
