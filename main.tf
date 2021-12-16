

#Need to provide cloud provider
 
provider "aws" {

 profile = "demo"
  region = "us-east-1"
}


resource "aws_vpc" "demo-vpc" {               #created a custom VPC
  cidr_block = "10.0.0.0/16"
  
}

resource "aws_subnet" "public-subnet-1" {             #created public subnets for webserver
  vpc_id                  = "${aws_vpc.demo-vpc.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = "${aws_vpc.demo-vpc.id}"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}


resource "aws_subnet" "pivate-subnet" {                #created private subnets for application server
  vpc_id                  = "${aws_vpc.demo-vpc.id}"
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet"
  }
}




resource "aws_subnet" "db-subnet-1" {                #created private subnets for database instance
  vpc_id            = "${aws_vpc.demo-vpc.id}"
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "db-subnet-1"
  }
}
resource "aws_subnet" "db-subnet-2" {
  vpc_id            = "${aws_vpc.demo-vpc.id}"
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "db-subnet-2"
  }
}


resource "aws_internet_gateway" "vpc-igw" {           #created internet gatway 
  vpc_id = "${aws_vpc.demo-vpc.id}"

}


resource "aws_route_table" "demo-rt" {                   #Put it's entry in route table
  vpc_id = "${aws_vpc.demo-vpc.id}"


  route {
    cidr_block = "0.0.0.0/0"                              
    gateway_id = "aws_internet_gateway.vpc-igw.id"
  }

 
}


resource "aws_route_table_association" "public-subnet-1" {          #Did network association for public subnet
  subnet_id      = "${aws_subnet.public-subnet-1.id}"
  route_table_id = "${aws_route_table.demo-rt.id}"
}

resource "aws_route_table_association" "public-subnet-2" {
  subnet_id      = "${aws_subnet.public-subnet-2.id}"
  route_table_id = "${aws_route_table.demo-rt.id"}
}



resource "aws_security_group" "webserver-sg" {                   # Created security group for webserver
  name        = "Web-sg"
  description = "Security group for webserver"
  vpc_id      = "${aws_vpc.demo-vpc.id}"

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_security_group" "app-sg" {                          # Create  Security Group for application server
  name        = "app-SG"
  description = "Allow inbound traffic from ALB"
  vpc_id      = "${aws_vpc.demo-vpc.id}"
  ingress {
    description     = "Allow traffic from web layer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web-sg.id}"]
  }

    
resource "aws_security_group" "lb-sg" {                             # Created security group for load balancer
  name        = "Web-sg"
  name        = "Load-Balancer-SG"
  description = "Allow inbound traffic from ALB"
  vpc_id      = "${aws_vpc.demo-vpc.id}"
  ingress {
    description     = "Allow traffic from web layer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
 
  egress {
    description     = "Allow traffic from web layer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  
}

resource "aws_security_group" "db-sg" {                             # Created security group for RDS insstance
  name        = "db-SG"
  description = "Security group for Mysql RDS instance"
  vpc_id      = "${aws_vpc.demo-vpc.id}"

  ingress {
    description     = "Allow traffic from application layer"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver-sg.id]
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database-SG"
  }
}

resource "aws_instance" "webserver1" {                                           #Created EC2 Instances for web server
  ami                    = "ami-0b898040803850657"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  vpc_security_group_ids = ["${aws_security_group.webserver-sg.id}"]
  key_name               = "gl"
  subnet_id              = "${aws_subnet.public-subnet-1.id}"
  user_data              = file("script.sh")

  tags = {
    Name = "Web Server-1"
  }

}

resource "aws_instance" "webserver2" {                                            #Created EC2 Instances for a wev server
  ami                    = "ami-0b898040803850657"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1b"
  vpc_security_group_ids = ["${aws_security_group.webserver-sg.id}"]
  subnet_id              = "${aws_subnet.public-subnet-2.id}"
  user_data              = file("script2.sh")

  tags = {
    Name = "Web Server-2"
  }
  
resource "aws_instance" "app-server" {                                                   #Created EC2 Instances for app server but not installing any app now
  ami                    = "ami-0b898040803850657"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  vpc_security_group_ids = ["${aws_security_group.webserver-sg.id}"]
  subnet_id              = "${aws_subnet.private-subnet.id}"
  #user_data              = file("script2.sh")

  tags = {
    Name = "app Server"
  }
}



resource "aws_lb" "web-lb" {                                                       # Created web load balancer
  name               = "web_lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.lb-sg.id}"]
  subnets            = ["${aws_subnet.public-subnet-1}", "${aws_subnet.public-subnet-2.id}"]
}

resource "aws_lb_listener" "web-lb-listener" {                         # Created listner for it
  load_balancer_arn = "${aws_lb.web-lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.web-tg.arn}"
  }
}


resource "aws_lb_target_group" "web-tg" {                          # Created target group for it
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.demo-vpc.id}"
}

resource "aws_lb_target_group_attachment" "web-tg-attach-1" {             # Attached resources to target group
  target_group_arn = "${aws_lb_target_group.web-tg.arn}"
  target_id        = "${aws_instance.webserver1.id}"
  port             = 80

 
}

resource "aws_lb_target_group_attachment" "web-tg-attach-2" {
  target_group_arn = "${aws_lb_target_group.web-tg.arn}"
  target_id        = "${aws_instance.webserver2.id}"
  port             = 80


}
resource "aws_db_subnet_group" "mysql-subnet-group" {                     # creat security group for mysql
  name        = "mysql-subnet-group"
  subnet_ids  = ["${aws_subnet.db-subnet-1.id}", "${aws_subnet.db-subnet-2.id}"]
}

resource "aws_db_instance" "mysql-db" {                        #creat RDS instace
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7.22"
  instance_class         = "db.t2.micro"
  multi_az               = true
  name                   = "mysqldb"
  username               = "mysql_user"
  password               = "mysql_password"
  skip_final_snapshot    = true
  subnet_ids 			 =  "${aws_db_subnet_group.mysql-subent-group.id.id}"
  vpc_security_group_ids = ["${aws_security_group.db-sg.id}"]
}

}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.web_lb.dns_name
}