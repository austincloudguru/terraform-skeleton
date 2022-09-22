#------------------------------------------------------------------------------
# Setup the backend for the state file
#------------------------------------------------------------------------------
resource "aws_s3_bucket" "terraform-state-storage-s3" {
  #TODO: Need to update to the new bucket pattern and fix some fo the checkov errors
  #checkov:skip=CKV_AWS_28: "Ensure Dynamodb point in time recovery (backup) is enabled"
  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  #checkov:skip=CKV_AWS_19: "Ensure all data stored in the S3 bucket is securely encrypted at rest"
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default
  bucket = "${var.tf_project}-tf"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name    = "S3 Remote Terraform State Store"
    Project = "${var.tf_project}"
  }
}

resource "aws_s3_bucket_public_access_block" "block-tf-s3" {
  bucket                  = aws_s3_bucket.terraform-state-storage-s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  #checkov:skip=CKV_AWS_119: "Ensure DynamoDB Tables are encrypted using a KMS Customer Managed CMK"
  #checkov:skip=CKV2_AWS_16: "Ensure that Auto Scaling is enabled on your DynamoDB tables"
  #checkov:skip=CKV_AWS_28: "Ensure Dynamodb point in time recovery (backup) is enabled"
  name           = "terraform-${var.tf_project}-lock"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "DynamoDB Terraform State Lock Table"
    Project = "${var.tf_project}"
  }
}
