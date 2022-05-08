# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {
}
