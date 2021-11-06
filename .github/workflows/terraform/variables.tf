variable "organization" {
  type=string
}
variable "workspace" {
  type=string
}
variable "cost-center" {
  type=string
  default="gilfoyle"
}
variable "owner" {
  type=string
  default="gilfoyle"
}
variable "app-name" {
  type=string
  default="gilfoyle"
}
# Name of the DynamoDB Table we're going to use.
variable "gilfoyle-store" {
  type=string
}
# The Slack URL we're going to hit.
variable "gilfoyle-url" {
  type=string
}