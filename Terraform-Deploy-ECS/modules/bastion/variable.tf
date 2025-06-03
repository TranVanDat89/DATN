variable "instance_type" {
  type        = string
  description = "Type of EC2 instance to launch. Example: t2.small"
  default = "t3.small"
}
variable "region" {
  type = string
  default = "ap-southeast-2"
}
variable security_groups {
  type = list(string)
  nullable = false
}
variable "subnet_id" {
  type = string
}
variable "amis" {
  type = map(any)
  default = {
    "ap-southeast-2" : "ami-0f5d1713c9af4fe30" #Ubuntu 20.04 Jammy
  }
}