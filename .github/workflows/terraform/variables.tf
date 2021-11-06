variable "organization" {
  type=string
}
variable "workspace" {
  type=string
}
variable "cost-center" {
  type=string
  default="insults-bot"
}
variable "owner" {
  type=string
  default="insults-bot"
}
variable "app-name" {
  type=string
  default="insults-bot"
}
# Name of the DynamoDB Table we're going to use.
variable "insults-store" {
  type=string
  default="insults-bot"
}
# The Slack URL we're going to hit.
variable "insults-url" {
  type=string
}