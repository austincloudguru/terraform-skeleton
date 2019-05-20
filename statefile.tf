#*********************************************************************************************
# Setup the Statefile
#*********************************************************************************************
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
  /* lifecycle {
    prevent_destroy = true
  }
  */
  tags = {
    Name = "S3 Remote Terraform State Store"
    Project = "${var.tf_project}"
  }
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
