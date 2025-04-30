provider "aws" {
  region = "ap-south-1"
}

 resource "aws_s3_bucket" "bkend_s3" {
   bucket = "demo-terraform-eks-state-s3-bucket-srihari-${formatdate("YYYYMMDD-HHmmss", timestamp())}"

   lifecycle {
     prevent_destroy = false
   }
 }

 resource "aws_s3_bucket_versioning" "versioning_example" {
   bucket = aws_s3_bucket.bkend_s3.id
   versioning_configuration {
     status = "Enabled"
   }
 }

 resource "aws_dynamodb_table" "dynamodb" {
   name           = "terraform-eks-state-locks"
   billing_mode   = "PAY_PER_REQUEST"
   hash_key       = "LockID"

   attribute {
     name = "LockID"
     type = "S"
   }
 }