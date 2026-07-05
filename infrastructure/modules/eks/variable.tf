variable "cluster_name" {
  type    = string
  default = "ob-lab-eks"
}

variable "cluster_version" {
  type    = string
  default = "1.35"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}