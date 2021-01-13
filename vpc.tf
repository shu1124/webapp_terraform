# VPC作成
resource "aws_vpc" "webapp" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "webapp"
  }
}

# サブネット
## サブネットpublic
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.webapp.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "public1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.webapp.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1d"
  tags = {
    Name = "public2"
  }
}
## サブネットprivate
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.webapp.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "private1"
  }
}
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.webapp.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-1d"
  tags = {
    Name = "private2"
  }
}

# インターネットゲートウェイの作成
resource "aws_internet_gateway" "webapp" {
  vpc_id = aws_vpc.webapp.id
  tags = {
    Name = "webapp"
  }
}

# ルートテーブル
## ルートテーブルの定義
resource "aws_route_table" "webapp" {
  vpc_id = aws_vpc.webapp.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp.id
  }
  tags = {
    Name = "webapp"
  }
}
## サブネットの関連付けでルートテーブルをパブリックサブネットに紐付け
resource "aws_route_table_association" "public1-subnet-association" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.webapp.id
}
resource "aws_route_table_association" "public2-subnet-association" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.webapp.id
}

# Security Group
##webセキュリティグループ
resource "aws_security_group" "websg" {
  name        = "websg"
  description = "web_sg"
  vpc_id      = aws_vpc.webapp.id
  tags = {
    Name = "webapp"
  }
}
## 80番ポート許可のインバウンドルール
resource "aws_security_group_rule" "inbound_http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
  security_group_id = aws_security_group.websg.id
}
## 22番ポート許可のインバウンドルール
resource "aws_security_group_rule" "inbound_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
  security_group_id = aws_security_group.websg.id
}
## アウトバウンドルール
resource "aws_security_group_rule" "outbound_all" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = -1
  cidr_blocks = [
    "0.0.0.0/0",
  ]
  security_group_id = aws_security_group.websg.id
}