terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_region" {
  default = "ap-southeast-1"
}

variable "ssh_cidr" {
  default = "10.0.0.0/8"
}

variable "include_cost_center" {
  default = true
}

variable "bucket_name" {}

provider "aws" {
  region = var.aws_region
}

locals {
  tags = merge(
    {
      owner               = "platform-team"
      environment         = "lab"
      data-classification = "internal"
    },
    var.include_cost_center ? { cost-center = "CC-001" } : {}
  )
}

resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name
  tags   = local.tags
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket                  = aws_s3_bucket.demo.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_security_group" "demo" {
  name        = "demo-audit-sg"
  description = "Demo compliance"
  tags        = local.tags

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }
}
