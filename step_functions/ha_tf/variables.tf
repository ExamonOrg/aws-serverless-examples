variable "email" {
  default = "jarroddalefolino+123@gmail.com"
}

variable "step_fn_approval_name" {
  type    = string
  default = "step_fn_approval_tf2"
}
variable "step_fn_approval_arn" {
    type    = string
  default = "arn:aws:iam::478119378221:policy/state-machine-send-success-failure-tf"
}