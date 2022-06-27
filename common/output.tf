# output "public_ip" {
#   value       = aws_instance.webserver.public_ip
#   description = "The public IP of the web server"
# }
# output "elb_dns_name" {
#   value       = aws_elb.webserver.dns_name
#   description = "The domain name of the load balancer"
# }

output "simple_user_access_secret" {
  value     = aws_iam_access_key.simple_user_access_key.secret
  sensitive = true
}
output "simple_user_access_enc_secret" {
  value = aws_iam_access_key.simple_user_access_key.encrypted_secret
}
output "simple_user_access_id" {
  value = aws_iam_access_key.simple_user_access_key.id
}
output "cnb_windows" {
  value = aws_instance.cnb_windows_ad.id

}
