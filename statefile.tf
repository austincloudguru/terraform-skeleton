/*
statefile.tf
*/
# Quickly Set the Project
variable "tf_project" {
  type = string
}

# create an S3 bucket to store the state file in
resource "aws_s3_bucket" "terraform-state-storage-s3" {
  bucket = "terraform-${var.tf_project}"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = "S3 Remote Terraform State Store"
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
  name = "terraform-${var.tf_project}-lock"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table"
    Project = "${var.tf_project}"
  }
}
