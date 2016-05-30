
output "ec_address" {
  value = "${aws_instance.kibana.dns_name}"
}