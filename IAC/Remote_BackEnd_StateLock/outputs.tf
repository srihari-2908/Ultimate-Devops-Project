output "s3_bucket_name" {
  value       = aws_s3_bucket.bkend_s3.id
  description = "The name of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.dynamodb.id
  description = "The name of the DynamoDB table"
}