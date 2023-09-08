variable "resource_group_name" {
}
variable "name_part1" {
}

variable "location" {
}

variable "capacity" {
  type        = number
  default     = 1
  description = "Event hub namespace capacity."
}

variable "partition_count" {
  type        = number
  default     = 2
  description = "Event hub partition count."
}
variable "capture_account_id" {
}
variable "capture_container_name" {
} 