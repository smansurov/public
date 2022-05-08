output "vpc_id" {
  value = aws_vpc.myvpc.id
}

#output "aws_av_zones" {
#  value = data.aws_availability_zones.available.names
#}

#output "aws_region" {
#  value = data.aws_region.current.name
#}

#output "aws_region_descr" {
#  value = data.aws_region.current.description
#}
