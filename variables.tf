variable "image_url" {
  description = <<-EOT
    Address of RockyLinux (or compatible) image to use. If null then an image
    must already exist on the cloud.
  EOT
  type        = string
  default     = "https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base-9.6-20250531.0.x86_64.qcow2"
}

variable "image_format" {
  description = <<-EOT
    Format for downloaded image. Default is to use use extension from image_url.
  EOT
  type = string
  default = null
}

variable "image_name" {
  description = <<-EOT
    Name of image in the cloud. Default takes it from image URL.
  EOT
  type        = string
  default     = null
}

variable "ssh_user" {
  description = "SSH user to create and jump through as"
  type        = string
  default     = "ansible"
}

variable "authorised_keys" {
  description = "List of SSH public keys allowed through jumphost as var.ssh_user"
  type        = list(string)
}

variable "debug" {
  description = "Set true to create the distro's default (rocky) user, e.g. to allow debugging and locally template cloud-init userdata"
  type        = bool
  default     = false
}

variable "default_key_pair" {
  description = "Name of keypair for default (rocky) user, only used in debug mode"
  type        = string
  default     = null
}

variable "floating_ip" {
  description = "IP to use for floating IP, must already be allocated to the project"
  type        = string
}

variable "flavor" {
  description = "Name of instance flavor"
  type        = string
}

variable "network" {
  description = "Name of network"
  type        = string
}

variable "security_group_names" {
  description = "Name of pre-existing security groups to apply"
  type        = list(string)
  default     = ["default", "SSH"]
}

variable "bantime" {
  description = "Time (s) to ban users repeatedly failing to authenticate"
  default = 3600
}