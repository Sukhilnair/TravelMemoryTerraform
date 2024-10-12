variable "aws_region" {
  description = "This will define the aws region"
  type        = string
  default     = "ap-northeast-2"
}

variable "ami" {
  description = "This is the ami for all the ec2 instances, It's an ubuntu AMI"
  type = string
  default = "ami-056a29f2eddc40520"
}

variable "instance_type" {
  description = "This is the instance type for all the ec2 instances"
  type = string
  default = "t2.micro"
}

variable "bucketname" {
  description = "This will the bucket name"
  type        = string
  default     = "travelmemorysukhil07092024"
}