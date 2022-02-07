variable "foundry-url" {
  default = ""
  type    = string
}

variable "owner" {
  default = "beerskunk"
  type    = string
}

variable "project-name" {
  default = "dsf-foundryvtt"
  type    = string
}

variable "environment" {
  default = ""
  type    = string
}

variable "region" {
  default = "us-east-1"
  type    = string
}

variable "availability-zone" {
  default = "us-east-1a"
  type    = string
}

variable "hosted-zone-id" {
  default = ""
  type    = string
}

## EBS
variable "ebs-data-size" {
  default = 20
  type    = number
}

variable "ebs-data-type" {
  default = "gp2"
  type    = string
}

variable "ebs-data-fstype" {
  default = "xfs"
  type    = string
}

variable "ebs-data-device-name" {
  default = "/dev/xvdf"
  type    = string
}

## EC2
variable "ec2-type" {
  default = "t4g.micro"
  type    = string
}

## NETWORK VARIABLES
variable "cidr-vpc" {
  default = "10.0.0.0/16"
  type    = string
}

## FOUNDRY
## The following values are passed into the User Data
## startup template for the EC2 instance and are used
## when the instance starts or reboots
variable "foundry-port" {
  default = 80
  type    = number
}

variable "foundry-server-dir" {
  default = "/foundry/server"
  type    = string
}

variable "foundry-data-dir" {
  default = "/foundrydata"
  type    = string
}

variable "foundry-major-v" {
  type        = number
  description = "The major version to use when looking up the AMI" 
}

variable "foundry-service-filename" {
  default = "foundry.service"
  type    = string
}