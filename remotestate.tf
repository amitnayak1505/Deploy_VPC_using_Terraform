resource "random_id" "tc-rmstate" {
  byte_length = 2
}
resource "aws_s3_bucket" "tfrmstate" {
  bucket = "tc-remotestate-${random_id.tc-rmstate.dec}"
  /*  acl           = "private"     */
  force_destroy = true

  tags = {
    Name = "tf remote state"
  }
}

resource "aws_s3_bucket_object" "rmstate_folder" {
  bucket = aws_s3_bucket.tfrmstate.id
  key    = "terraform-aws/"
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = var.aws_dynamodb_table
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
