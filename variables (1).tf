variable "AWS_ACCESS_KEY" {}

variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {

  default = "us-east-1"

}

variable "min_size" {}

variable "max_size" {}

variable "INSTANCE_USERNAME" {
  
  default = "test"

}

variable "PATH_TO_PUBLIC_KEY" {
  
  default = "mykey.pub"

}