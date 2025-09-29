# STEP 1: Create random string for S3 name uniqueness
resource "random_id" "random_hex" {
  byte_length = 8
}

resource "aws_s3_bucket" "this" {
  bucket = format("%s-%s", var.bucket_name, random_id.random_hex.hex)
  tags = {
    Name        = "my-bucket"
    Environment = "Dev"
  }
}

# STEP 2: Upload objects to S3 bucket
resource "aws_s3_object" "test_upload_bucket" {
  for_each               = fileset("./images", "**")
  bucket                 = aws_s3_bucket.this.id
  key                    = each.key # name of the object
  source                 = "${"./images"}/${each.value}"
  etag                   = filemd5("${"./images"}/${each.value}")
  server_side_encryption = "AES256"
  tags = {
    Name        = "my-bucket"
    Environment = "Dev"
  }
}
