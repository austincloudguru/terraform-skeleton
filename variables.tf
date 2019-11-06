#------------------------------------------------------------------------------
# Variables that need to be set
#------------------------------------------------------------------------------
variable "aws_region" {
  description = "The AWS region to work in"
  type        = string
  default     = "us-east-1"
}
variable "tf_project" {
  description = "The name of the project folder that inputs.tfvars is in"
  type        = string
}
