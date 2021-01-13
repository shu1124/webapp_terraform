#RDS
##DBのパラメータグループ
resource "aws_db_parameter_group" "webapp" {
  name   = "webapp"
  family = "mysql5.7"
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}
##DBオプション
resource "aws_db_option_group" "webapp" {
  name                 = "webapp"
  engine_name          = "mysql"
  major_engine_version = "5.7"
}
##DBサブネットグループの作成
resource "aws_db_subnet_group" "webapp" {
  name       = "webapp"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}
##DBインスタンス
resource "aws_db_instance" "webapp" {
  identifier            = "webapp"
  engine                = "mysql"
  engine_version        = "5.7.31"
  instance_class        = "db.t2.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  username                   = "admin"
  password                   = "VeryStrongPassword!"
  multi_az                   = true
  publicly_accessible        = false
  backup_window              = "09:10-09:40"
  backup_retention_period    = 30
  maintenance_window         = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  deletion_protection        = true
  skip_final_snapshot        = false
  port                       = 3306
  apply_immediately          = false
  vpc_security_group_ids     = [aws_security_group.dbsg.id]
  parameter_group_name       = aws_db_parameter_group.webapp.name
  option_group_name          = aws_db_option_group.webapp.name
  db_subnet_group_name       = aws_db_subnet_group.webapp.name
  lifecycle {
    ignore_changes = [password]
  }
}
## DBセキュリティグループ
resource "aws_security_group" "dbsg" {
    name        = "dbsg"
    description = "webapp-sg"
    vpc_id      = aws_vpc.webapp.id
    tags = {
      Name = "dbsg"
    }
}
## mysqlインバウンドルール
resource "aws_security_group_rule" "db" {
    type                     = "ingress"
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.websg.id
    security_group_id        = aws_security_group.dbsg.id
}
