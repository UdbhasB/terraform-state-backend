provider "aws" {
  region = "us-east-1"
  
}

# Resource to create an S3 bucket. Stores the terraform state files.
resource "aws_s3_bucket" "terraform_state" {
  bucket = "udbhas-terraform-state-20250607"
  tags = {
    Name        = "UDBHAS-TERRAFORM-PROJECT"
    Environment = "Production"
  }
}

 # Block all public access to the S3 bucket.
resource "aws_s3_bucket_public_access_block" "terraform_state_publinc_access_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Resource to enable versioning on the S3 bucket.
resource "aws_s3_bucket_versioning" "terraform_state_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Resource to create a DynamoDB table for state locking. so that multiple users can work on the same state file without conflicts.
resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "UDBHAS-TERRAFORM-STATE-LOCK"
  billing_mode = "PAY_PER_REQUEST"

  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S" #S for String
  }

  tags = {
    Name        = "UDBHAS-TERRAFORM-STATE-LOCK"
    Environment = "Production"
  }
}

# Output the ID of the created S3 bucket.
output "s3_bucket_id" {
  description = "The ID od the S3 bucckekt where Terraform state is stored."
  value = aws_s3_bucket.terraform_state.id
}

# Output the name of the created DynamoDB table.
output "dynamodb_table_name" {
  description = "The name of the DynamoDB table used for state locking."
  value = aws_dynamodb_table.terraform_state_lock.name
}
