variable "foundry-url" {
  default = ""
  type    = string
}

variable "owner" {
  default = "beerskunk"
  type    = string
}

variable "project-name" {
  default = "foundryvtt"
  type    = string
}

variable "environment" {
  default = "staging"
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

## EBS
variable "ebs-root-size" {
  default = 30
  type    = number
}

variable "ebs-root-type" {
  default = "gp2"
  type    = string
}

variable "ebs-root-snapshot-id" {
  default = ""
  type    = string
}

variable "ebs-root-device-name" {
  default = "/dev/sda1"
  type    = string
}

## EC2
variable "ec2-ami" {
  default = ""
  type    = string
}

variable "ec2-type" {
  default = "t2.micro"
  type    = string
}

# EFS
variable "efs-creation-token" {
  default = "foundry-efs"
  type    = string
}

variable "efs-performance-mode" {
  default = "generalPurpose"
  type    = string
}

variable "efs-lifecycle-policy" {
  default = "AFTER_30_DAYS"
  type    = string
}

variable "efs-port" {
  default = 2049
  type    = number
}

variable "efs-posix-gid" {
  default = 3700
  type    = number
}

variable "efs-posix-uid" {
  default = 3700
  type    = number
}

variable "efs-root-path" {
  default = "/foundry/data"
  type    = string
}

## NETWORK VARIABLES
variable "cidr-vpc" {
  default = "10.0.0.0/16"
  type    = string
}

## FOUNDRY
variable "foundry-port" {
  default = 80
  type    = number
}

variable "foundry-server-dir" {
  default = "/foundry/server"
  type    = string
}

variable "foundry-data-dir" {
  default = "/foundry/data"
  type    = string
}

variable "foundry-major-v" {
  type        = number
  description = "The major version to use when looking up the AMI" 
}

variable "foundry-minor-v" {
  type        = number
  description = "The minor version to use when looking up the AMI"
}