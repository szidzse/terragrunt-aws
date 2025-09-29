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

# STEP 4: Setup READ ONLY policy on S3 bucket
resource "aws_s3_bucket_public_access_block" "enable_public_access" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_read_policy" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.enable_public_access]
}
