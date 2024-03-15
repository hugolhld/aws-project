variable "key_name" {
    type = string
    description = "The name of the key pair to use for the EC2 instance"
    # default     = "key"
}

variable "key_path" {
    type = string
    description = "The path to the key pair to use for the EC2 instance"
    # default     = "key.pem"
}

# variable "ec2-instance" {
#   type    = string
# #   default = "i-03e485bc335b9a58a"
# }