output "private_key_pem" {
  value     = tls_private_key.my_tls_key.private_key_pem
  sensitive = true
}

output "bucketarn" {
  description = "Public IP for EC2"
  value       = aws_s3_bucket.mys3bucket.arn
}

output "ec2_publicip" {
  value = aws_instance.travelmemoryec2.public_ip
}


output "ec2_instanceid" {
  value = aws_instance.travelmemoryec2.id
}