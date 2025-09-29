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

# STEP 3: Enable the server side encryption using KMS key
resource "aws_kms_key" "s3_bucket_kms_key" {
  description             = "KMS key for S3 bucket"
  deletion_window_in_days = 7
  tags = {
    Name = "KMS key for S3 bucket"
  }
}

resource "aws_kms_alias" "s3_bucket_kms_key_alias" {
  name          = "alias/s3_bucket_kms_key_alias"
  target_key_id = aws_kms_key.s3_bucket_kms_key.key_id
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_encryption_with_kms_key" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_bucket_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
